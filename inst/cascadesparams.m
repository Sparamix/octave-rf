## -*- texinfo -*-
## @deftypefn {Function File} {@var{s_out} =} cascadesparams (@var{s1}, @var{s2}, @dots{})
## Cascade two or more 2-port S-parameter networks in series.
##
## Each input is either a sparameters struct or a 2x2xK raw array.
## Returns a sparameters struct (or raw array if all inputs are raw arrays).
## At least two inputs are required.
##
## All inputs must have the same frequency vector.
##
## @strong{Algorithm:} For each pair, convert to T-parameters, multiply,
## convert back to S-parameters.  T-parameters are the natural
## representation for cascading:
## @verbatim
##   T_cascade = T1 * T2 * ... * Tn
##   S_cascade = t2s(T_cascade)
## @end verbatim
##
## @strong{Mathematical basis:}
## @verbatim
##   Pupalaikis, P.J., "S-Parameters for Signal Integrity",
##     Cambridge University Press, 2020.  [PRIMARY]
##     Section 3.7 "Cascading" (p.69): T_total = TL * TR —
##     S-parameters of cascaded 2-port T-parameter devices via
##     T-matrix multiplication.
##     Section 3.7.1, Eq. 3.35 (p.69): explicit cascade formula.
##     Chapter 10 "De-embedding" (p.282) for comprehensive treatment of
##     cascade/de-embed operations.
##
##   Pozar, D.M., "Microwave Engineering", 4th ed., Wiley, 2012.
##     Section 4.4, Eq. 4.71 (p.189): ABCD cascade property
##       [ABCD]_cascade = [ABCD]_1 * [ABCD]_2
##     (analogous concept — ABCD cascades for two-port networks the same
##     way T-parameters do, differing only in which independent/dependent
##     variables are used).
##
##   Hall, S.H. and Heck, H.L., "Advanced Signal Integrity for High-Speed
##     Digital Designs", Wiley-IEEE Press, 2009.
##     Section 9.2.4 "Cascading S-Parameters" (p.390).
##
##   Resso, M. and Bogatin, E., "Signal Integrity Characterization
##     Techniques", IEC, 2009.  Chapter on cascade/de-embed.
## @end verbatim
##
## @seealso{deembedsparams, embedsparams, s2t, t2s}
## @end deftypefn

function s_out = cascadesparams (varargin)

  narginchk (2, Inf);

  %% Extract raw arrays and check that we have sparameters or arrays
  params = cell (nargin, 1);
  freqs  = [];
  all_raw = true;

  for i = 1:nargin
    v = varargin{i};
    if isstruct (v) && isfield (v, 'Parameters')
      params{i} = v.Parameters;
      if isempty (freqs)
        freqs = v.Frequencies;
      end
      all_raw = false;
    elseif isnumeric (v)
      params{i} = v;
    else
      error ('cascadesparams: argument %d is not a sparameters struct or numeric array', i);
    end
    if size (params{i}, 1) ~= 2 || size (params{i}, 2) ~= 2
      error ('cascadesparams: argument %d is not a 2x2xK array (cascade only defined for 2-port networks)', i);
    end
  endfor

  %% Check consistent frequency axis
  K = size (params{1}, 3);
  for i = 2:nargin
    if size (params{i}, 3) ~= K
      error ('cascadesparams: all inputs must have the same number of frequency points');
    end
  endfor

  %% Cascade via T-matrix multiplication
  T_total = s2t (params{1});
  for i = 2:nargin
    Ti = s2t (params{i});
    for k = 1:K
      T_total(:,:,k) = T_total(:,:,k) * Ti(:,:,k);
    endfor
  endfor

  P_out = t2s (T_total);

  if all_raw
    s_out = P_out;
  else
    s_out.Parameters  = P_out;
    s_out.Frequencies = freqs;
  end

endfunction

%!test
%! %% Two ideal thrus -> thru
%! K  = 10;
%! p  = zeros(2,2,K);  p(1,2,:) = 1;  p(2,1,:) = 1;
%! s  = sparameters(p, linspace(1e9,10e9,K).');
%! s2 = cascadesparams(s, s);
%! assert (s2.Parameters, p, 1e-13);

%!test
%! %% Self-cascade is NOT the identity: two 6dB attenuators -> 12dB
%! z0 = 50;
%! %% 6dB attenuator S21 ~ 0.5 (approximately)
%! S = reshape([0.1, 0.5, 0.5, 0.1], 2, 2, 1);
%! R = cascadesparams(S, S);
%! %% S21 of cascade = S21^2 / (1 - S22*S11) approximately (ignoring reflections)
%! %% For small reflections: ~S21_1 * S21_2
%! assert (abs(R(2,1,1)) < abs(S(2,1,1)));  % cascade is more attenuated

%!test
%! %% Three networks cascaded: order matters
%! K = 5;
%! p1 = zeros(2,2,K);  p1(1,2,:) = 1;  p1(2,1,:) = 0.9;  p1(1,1,:) = 0.1;
%! p2 = zeros(2,2,K);  p2(1,2,:) = 0.8; p2(2,1,:) = 0.8;
%! p3 = zeros(2,2,K);  p3(1,2,:) = 1;  p3(2,1,:) = 0.95; p3(2,2,:) = 0.05;
%! r12 = cascadesparams(p1, p2);
%! r123a = cascadesparams(r12, p3);
%! r23  = cascadesparams(p2, p3);
%! r123b = cascadesparams(p1, r23);
%! assert (r123a, r123b, 1e-12);  %% associativity

%!test
%! %% Raw array input returns raw array (numeric, not struct)
%! %% Note: size() drops trailing singleton dims; use size(A,dim) to check K=1.
%! p = reshape([0 1 1 0], 2, 2, 1);
%! r = cascadesparams(p, p);
%! assert (isnumeric(r));
%! assert (size(r,1), 2);
%! assert (size(r,2), 2);
%! assert (size(r,3), 1);

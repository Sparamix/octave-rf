## -*- texinfo -*-
## @deftypefn {Function File} {@var{s_dut} =} deembedsparams (@var{s_measured}, @var{s_fix1}, @var{s_fix2})
## De-embed fixture S-parameters from a measured fixture-DUT-fixture cascade.
##
## @var{s_measured} is the measured cascade (fixture1 - DUT - fixture2),
## @var{s_fix1} is the left fixture error box, and @var{s_fix2} is the right
## fixture error box.  All three are either sparameters structs or 2x2xK arrays.
## Returns the de-embedded DUT as a sparameters struct (or raw array).
##
## @strong{Algorithm:}
## @verbatim
##   T_DUT = inv(T_fix1) * T_measured * inv(T_fix2)
## @end verbatim
## where T = s2t(S) are the corresponding T (chain scattering) parameters.
## Inversion is performed per-frequency using @code{linsolve} for numerical
## stability.
##
## @strong{Mathematical basis:}
## @verbatim
##   Pupalaikis, P.J., "S-Parameters for Signal Integrity",
##     Cambridge University Press, 2020.  [PRIMARY]
##     Section 3.8 "Inverse and Identity Sections" (p.69-70):
##     T_identity = I2x2 and inverse section definition.
##     Section 3.9 "De-embedding S-Parameters" (p.70): T_R = T_L^-1 * T
##     removes a known left section from a cascade.  This implementation
##     removes both left and right fixtures symmetrically:
##       T_DUT = T_fix1^-1 * T_measured * T_fix2^-1.
##     Chapter 10 "De-embedding" (p.282) for comprehensive treatment
##     including one-port, two-port, fixture, and two-port-tip cases.
##
##   Hall, S.H. and Heck, H.L., "Advanced Signal Integrity for High-Speed
##     Digital Designs", Wiley-IEEE Press, 2009.
##     Section 9.2.5 "Calibration and Deembedding" (p.395).
##
##   Resso, M. and Bogatin, E., "Signal Integrity Characterization
##     Techniques", IEC, 2009.  Chapter on de-embedding for
##     measurement-based fixture removal.
## @end verbatim
##
## @seealso{embedsparams, cascadesparams, s2t, t2s}
## @end deftypefn

function s_dut = deembedsparams (s_measured, s_fix1, s_fix2)

  narginchk (3, 3);

  [P_m, P_f1, P_f2, freqs, use_struct] = _unpack3 (s_measured, s_fix1, s_fix2);

  K = size (P_m, 3);
  T_m  = s2t (P_m);
  T_f1 = s2t (P_f1);
  T_f2 = s2t (P_f2);

  T_dut = zeros (2, 2, K);
  for k = 1:K
    %% T_DUT = inv(T_f1) * T_m * inv(T_f2)
    %% Use linsolve for numerical stability:
    %%   inv(T_f1)*T_m  <=>  T_f1 \ T_m    (left-divide)
    %%   result * inv(T_f2) <=> (T_f2.' \ result.').    no — use right-divide
    Lhs = T_f1(:,:,k) \ T_m(:,:,k);     %% inv(T_f1) * T_m
    T_dut(:,:,k) = Lhs / T_f2(:,:,k);   %% * inv(T_f2)
  endfor

  P_dut = t2s (T_dut);

  if use_struct
    s_dut.Parameters  = P_dut;
    s_dut.Frequencies = freqs;
  else
    s_dut = P_dut;
  end

endfunction

%!test
%! %% Identity fixtures: deembed(S, I_fix, I_fix) == S
%! %% Identity fixture has S = [0 1; 1 0] (T = eye(2))
%! K = 10;
%! f = linspace(1e9, 10e9, K).';
%! p_id = zeros(2,2,K);  p_id(1,2,:) = 1;  p_id(2,1,:) = 1;
%! p_m  = rand(2,2,K)*0.1 + 1j*rand(2,2,K)*0.05;
%! p_m(2,1,:) += 0.85;  p_m(1,2,:) = p_m(2,1,:);
%! s_id  = sparameters(p_id, f);
%! s_m   = sparameters(p_m, f);
%! s_dut = deembedsparams(s_m, s_id, s_id);
%! assert (s_dut.Parameters, p_m, 1e-12);

%!test
%! %% Self-consistency: deembed(cascade(f1, dut, f2), f1, f2) == dut
%! K = 8;
%! f = linspace(1e9, 8e9, K).';
%! p_f  = zeros(2,2,K);  p_f(2,1,:)  = exp(-1j*linspace(0,pi,K));  p_f(1,2,:)  = p_f(2,1,:);
%! p_dut = zeros(2,2,K); p_dut(2,1,:) = 0.8*exp(-1j*linspace(0,0.5*pi,K)); p_dut(1,2,:) = p_dut(2,1,:);
%! s_f   = sparameters(p_f, f);
%! s_dut_orig = sparameters(p_dut, f);
%! s_cas = cascadesparams(s_f, s_dut_orig, s_f);
%! s_dut_recovered = deembedsparams(s_cas, s_f, s_f);
%! assert (s_dut_recovered.Parameters, p_dut, 1e-10);

%!test
%! %% Raw array input returns raw array
%! p = reshape([0 1 1 0], 2, 2, 1);
%! r = deembedsparams(p, p, p);
%! assert (isnumeric(r));

%% Internal helper: unpack 3 arguments (sparameters structs or raw arrays)
function [P1, P2, P3, freqs, use_struct] = _unpack3 (a1, a2, a3)
  use_struct = false;
  freqs = [];
  if isstruct (a1) && isfield (a1, 'Parameters')
    P1 = a1.Parameters;  freqs = a1.Frequencies;  use_struct = true;
  else
    P1 = a1;
  end
  if isstruct (a2) && isfield (a2, 'Parameters')
    P2 = a2.Parameters;  if isempty(freqs); freqs = a2.Frequencies; end
    use_struct = true;
  else
    P2 = a2;
  end
  if isstruct (a3) && isfield (a3, 'Parameters')
    P3 = a3.Parameters;  if isempty(freqs); freqs = a3.Frequencies; end
    use_struct = true;
  else
    P3 = a3;
  end
endfunction

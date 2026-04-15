## -*- texinfo -*-
## @deftypefn  {Function File} {@var{S_new} =} renormsparams (@var{S}, @var{z_new})
## @deftypefnx {Function File} {@var{S_new} =} renormsparams (@var{S}, @var{z_new}, @var{z_old})
## Renormalize N-port S-parameters to a new reference impedance.
##
## @var{S} is an NxNxK complex array of S-parameters referenced to @var{z_old}
## (scalar, default 50 ohms).  Returns S-parameters referenced to @var{z_new}
## (scalar, in ohms).
##
## @strong{Algorithm} (via Z-parameters):
## @verbatim
##   Z     = z_old * (I + S) * inv(I - S)
##   S_new = (Z - z_new*I) * inv(Z + z_new*I)
## @end verbatim
##
## This is valid for N-port networks with uniform (scalar) reference impedance.
## For per-port renormalization with different impedances at each port, see
## Pupalaikis Chapter 5 for the generalized bilinear transform.
##
## @strong{Mathematical basis:}
## @verbatim
##   Pupalaikis, P.J., "S-Parameters for Signal Integrity",
##     Cambridge University Press, 2020.  [PRIMARY]
##     Chapter 5, Section 5.1 "Basic Reference Impedance Transformation"
##     (p.134): renormalization via Z intermediate:
##       Z     = sqrt(Z0)*(I+S)*(I-S)^-1*Z0*sqrt(Z0)^-1
##       S_new = sqrt(Z0')^-1*(Z-Z0')*(Z+Z0')^-1*sqrt(Z0')
##     reduces to the uniform-Z0 form implemented here when the
##     normalization factor is uniform.
##
##   Pozar, D.M., "Microwave Engineering", 4th ed., Wiley, 2012.
##     Section 4.3, Eq. 4.44-4.45 (p.181): the S<->Z relations used as
##     the intermediate step in renormalization.
##
##   Hall, S.H. and Heck, H.L., "Advanced Signal Integrity for High-Speed
##     Digital Designs", Wiley-IEEE Press, 2009.
##     Section 9.2.6 "Changing the Reference Impedance" (p.399).
##
##   Resso, M. and Bogatin, E., "Signal Integrity Characterization
##     Techniques", IEC, 2009.  Renormalization from measurement
##     reference impedance to system impedance.
## @end verbatim
##
## @seealso{s2z, z2s, sparameters}
## @end deftypefn

function S_new = renormsparams (S, z_new, z_old)

  narginchk (2, 3);
  if nargin < 3
    z_old = 50.0;
  end
  if ~isscalar(z_new) || ~isreal(z_new) || z_new <= 0
    error ('renormsparams: z_new must be a positive real scalar');
  end
  if ~isscalar(z_old) || ~isreal(z_old) || z_old <= 0
    error ('renormsparams: z_old must be a positive real scalar');
  end

  [N, M, K] = size(S);
  if N ~= M
    error ('renormsparams: S must be an NxNxK array');
  end

  I = eye(N);
  S_new = zeros(N, N, K);
  for k = 1:K
    s = S(:,:,k);
    Z = z_old * (I + s) / (I - s);
    S_new(:,:,k) = (Z - z_new*I) / (Z + z_new*I);
  endfor

endfunction

%!test
%! %% Round-trip: renorm to 100 then back to 50 == identity
%! K = 10;
%! S = rand(2,2,K)*0.15 + 1j*rand(2,2,K)*0.1;
%! S(2,1,:) += 0.7;  S(1,2,:) = S(2,1,:);
%! S100 = renormsparams(S, 100, 50);
%! S_rt = renormsparams(S100, 50, 100);
%! assert (S_rt, S, 1e-11);

%!test
%! %% z_new == z_old: identity (no change)
%! K = 5;
%! S = rand(2,2,K)*0.2;
%! assert (renormsparams(S, 50, 50), S, 1e-15);

%!test
%! %% 1-port: Z=100 (S11=1/3 at z0=50), renorm to 100 -> S11=0 (matched)
%! S = (1/3)*ones(1,1,1);  % Z=100 viewed from 50-ohm
%! S_100 = renormsparams(S, 100, 50);
%! assert (S_100(1,1,1), 0.0, 1e-13);

%!test
%! %% Consistent with sparameters(obj, z0_new) renormalization
%! K = 5;
%! f = linspace(1e9,5e9,K).';
%! S = rand(2,2,K)*0.15;  S(2,1,:) += 0.7;  S(1,2,:) = S(2,1,:);
%! S_obj = sparameters(S, f, 50);
%! S_100 = renormsparams(S, 100, 50);
%! S_obj_100 = sparameters(S_obj, 100);
%! assert (S_obj_100.Parameters, S_100, 1e-13);

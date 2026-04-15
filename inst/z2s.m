## -*- texinfo -*-
## @deftypefn  {Function File} {@var{S} =} z2s (@var{Z})
## @deftypefnx {Function File} {@var{S} =} z2s (@var{Z}, @var{z0})
## Convert N-port Z-parameters (impedance matrix) to S-parameters.
##
## @var{Z} is an NxNxK complex array.  @var{z0} is the reference impedance
## in ohms (scalar, default 50).  Returns an NxNxK S-parameter array.
##
## @strong{Conversion formula (N-port, uniform Z0):}
## @verbatim
##   S = (Z - z0*I) * inv(Z + z0*I)
## @end verbatim
## where I is the NxN identity matrix.
##
## @strong{Mathematical basis:}
## @verbatim
##   Pupalaikis, P.J., "S-Parameters for Signal Integrity",
##     Cambridge University Press, 2020.  [PRIMARY]
##     Section 3.4.1 "S-Parameters In Terms Of Z-Parameters",
##     Table 3.2, Eq. 3.16 (p.55): S = (Z - Z0*I) * (Z + Z0*I)^-1 —
##     matches this implementation exactly for the uniform-Z0 case.
##
##   Pozar, D.M., "Microwave Engineering", 4th ed., Wiley, 2012.
##     Section 4.3, Eq. 4.44 (p.181): [S] = ([Z] + [U])^-1 * ([Z] - [U])
##     (normalized, Z0=1).  Table 4.2 (p.192) gives the 2-port Z-to-S
##     conversion with explicit Z0.
##
##   Hall, S.H. and Heck, H.L., "Advanced Signal Integrity for High-Speed
##     Digital Designs", Wiley-IEEE Press, 2009.
##     Section 9.2.1 "Impedance Matrix" (p.355); Section 9.2.2
##     "Scattering Matrix" (p.358).
##
##   Balanis, C.A., "Advanced Engineering Electromagnetics",
##     2nd ed., Wiley, 2012.  Chapter 10.
## @end verbatim
##
## @seealso{s2z, z2y, z2abcd}
## @end deftypefn

function S = z2s (Z, z0)

  narginchk (1, 2);
  if nargin < 2
    z0 = 50.0;
  end
  if ~isscalar (z0) || ~isreal (z0) || z0 <= 0
    error ('z2s: z0 must be a positive real scalar');
  end

  [N, M, K] = size (Z);
  if N ~= M
    error ('z2s: Z must be an NxNxK array');
  end

  S = zeros (N, N, K);
  I = eye (N);

  for k = 1:K
    z = Z(:,:,k);
    %% S = (Z - z0*I) * inv(Z + z0*I)
    S(:,:,k) = (z - z0*I) / (z + z0*I);
  endfor

endfunction

%!test
%! %% 1-port: Z = 50 (matched) -> S11 = 0
%! Z = 50*ones(1,1,3);
%! S = z2s(Z);
%! assert (S, zeros(1,1,3), 1e-14);

%!test
%! %% 1-port: Z = 0 (short) -> S11 = -1
%! Z = zeros(1,1,1);
%! S = z2s(Z);
%! assert (S(1,1,1), -1.0, 1e-15);

%!test
%! %% 1-port: Z = 100 -> S11 = (100-50)/(100+50) = 1/3
%! Z = 100*ones(1,1,1);
%! S = z2s(Z);
%! assert (S(1,1,1), 1/3, 1e-14);

%!test
%! %% Round-trip: s2z(z2s(Z)) == Z
%! %% Note: avoid broadcasting 50*eye(2)+rand(2,2,K) — Octave doesn't broadcast 2D+3D.
%! K = 5;
%! Z = zeros(2,2,K);
%! for k = 1:K
%!   A = rand(2,2)*10 + 1j*rand(2,2)*5;
%!   Z(:,:,k) = 50*eye(2) + A + A.';   %% symmetric positive-definite-ish
%! end
%! assert (s2z(z2s(Z)), Z, 1e-10);

%!test
%! %% Custom z0
%! Z = 200*ones(1,1,1);
%! S_50  = z2s(Z, 50);
%! S_100 = z2s(Z, 100);
%! assert (S_50(1,1,1),  (200-50)/(200+50),   1e-14);
%! assert (S_100(1,1,1), (200-100)/(200+100), 1e-14);

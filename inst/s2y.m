## -*- texinfo -*-
## @deftypefn  {Function File} {@var{Y} =} s2y (@var{S})
## @deftypefnx {Function File} {@var{Y} =} s2y (@var{S}, @var{z0})
## Convert N-port S-parameters to Y-parameters (admittance matrix).
##
## @var{S} is an NxNxK complex array of S-parameters.  @var{z0} is the
## reference impedance in ohms (scalar, default 50).  Returns an NxNxK
## array of Y-parameters (units: siemens).
##
## @strong{Conversion formula (N-port, uniform Z0):}
## @verbatim
##   Y = (1/z0) * (I - S) * inv(I + S)
## @end verbatim
## where I is the NxN identity matrix.
##
## @strong{Mathematical basis:}
## @verbatim
##   Pupalaikis, P.J., "S-Parameters for Signal Integrity",
##     Cambridge University Press, 2020.  [PRIMARY]
##     Section 3.4.4 "Y-Parameters In Terms Of S-Parameters",
##     Table 3.5 (p.59): Y = (1/Z0) * (I - S) * (I + S)^-1 — matches
##     this implementation exactly for the uniform-Z0 case.
##
##   Pozar, D.M., "Microwave Engineering", 4th ed., Wiley, 2012.
##     Section 4.2, Eq. 4.26-4.27 (p.175): [I] = [Y][V]; [Y] = [Z]^-1
##     defines Y-parameters.  Table 4.2 (p.192) gives the 2-port S-to-Y
##     conversion.
##
##   Hall, S.H. and Heck, H.L., "Advanced Signal Integrity for High-Speed
##     Digital Designs", Wiley-IEEE Press, 2009.
##     Section 9.2.1 "Impedance Matrix" (p.355) — Y as the inverse of Z.
##
##   Balanis, C.A., "Advanced Engineering Electromagnetics",
##     2nd ed., Wiley, 2012.  Chapter 10.
## @end verbatim
##
## @seealso{y2s, s2z, s2abcd}
## @end deftypefn

function Y = s2y (S, z0)

  narginchk (1, 2);
  if nargin < 2
    z0 = 50.0;
  end
  if ~isscalar (z0) || ~isreal (z0) || z0 <= 0
    error ('s2y: z0 must be a positive real scalar');
  end

  [N, M, K] = size (S);
  if N ~= M
    error ('s2y: S must be an NxNxK array');
  end

  Y = zeros (N, N, K);
  I = eye (N);

  for k = 1:K
    s = S(:,:,k);
    Y(:,:,k) = (I - s) / (z0 * (I + s));
  endfor

endfunction

%!test
%! %% 1-port: matched (S11=0) -> Y = 1/z0
%! S = zeros(1,1,3);
%! Y = s2y(S);
%! assert (Y, ones(1,1,3)/50, 1e-15);

%!test
%! %% 1-port: S11=1/3 -> Z=100 -> Y=0.01
%! S = (1/3)*ones(1,1,1);
%! Y = s2y(S);
%! assert (Y(1,1,1), 1/100, 1e-14);

%!test
%! %% Round-trip: y2s(s2y(S)) == S
%! K = 15;
%! S = rand(2,2,K)*0.2 + 1j*rand(2,2,K)*0.1;
%! S(2,1,:) += 0.6;  S(1,2,:) = S(2,1,:);
%! assert (y2s(s2y(S)), S, 1e-11);

%!test
%! %% Consistency with s2z: Y == inv(Z) for passive networks
%! S = zeros(2,2,1);  S(1,1) = 0.2;  S(2,2) = 0.15;
%! S(1,2) = 0.8;  S(2,1) = 0.8;
%! Z = s2z(S, 50);
%! Y = s2y(S, 50);
%! assert (Y(:,:,1) * Z(:,:,1), eye(2), 1e-12);

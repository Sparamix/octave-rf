## -*- texinfo -*-
## @deftypefn  {Function File} {@var{Z} =} s2z (@var{S})
## @deftypefnx {Function File} {@var{Z} =} s2z (@var{S}, @var{z0})
## Convert N-port S-parameters to Z-parameters (impedance matrix).
##
## @var{S} is an NxNxK complex array of S-parameters.  @var{z0} is the
## reference impedance in ohms (scalar, default 50).  Returns an NxNxK
## array of Z-parameters.
##
## @strong{Conversion formula (N-port, uniform Z0):}
## @verbatim
##   Z = z0 * (I + S) * inv(I - S)
## @end verbatim
## where I is the NxN identity matrix.
##
## For a 1-port network this reduces to the familiar expression:
## @code{Z = z0*(1+S11)/(1-S11)}.
##
## @strong{Mathematical basis:}
## @verbatim
##   Pupalaikis, P.J., "S-Parameters for Signal Integrity",
##     Cambridge University Press, 2020.  [PRIMARY]
##     Section 3.4.2 "Z-Parameters In Terms Of S-Parameters",
##     Table 3.3 (p.56): Z = (I + S) * inv(I - S) * Z0 — matches this
##     implementation exactly for the uniform-Z0 case.
##
##   Pozar, D.M., "Microwave Engineering", 4th ed., Wiley, 2012.
##     Section 4.3, Eq. 4.45 (p.181): [Z] = ([U] + [S]) * ([U] - [S])^-1
##     (normalized, Z0=1).  Table 4.2 (p.192) gives the 2-port S-to-Z
##     conversion with explicit Z0.
##     Section 4.2, Eq. 4.25 (p.175): [V] = [Z][I] defines Z-parameters.
##
##   Hall, S.H. and Heck, H.L., "Advanced Signal Integrity for High-Speed
##     Digital Designs", Wiley-IEEE Press, 2009.
##     Section 9.2.1 "Impedance Matrix" (p.355).
##
##   Balanis, C.A., "Advanced Engineering Electromagnetics",
##     2nd ed., Wiley, 2012.  Chapter 10: electromagnetic first-principles
##     derivation of the impedance matrix.
## @end verbatim
##
## @seealso{z2s, s2y, s2abcd}
## @end deftypefn

function Z = s2z (S, z0)

  narginchk (1, 2);
  if nargin < 2
    z0 = 50.0;
  end
  if ~isscalar (z0) || ~isreal (z0) || z0 <= 0
    error ('s2z: z0 must be a positive real scalar');
  end

  [N, M, K] = size (S);
  if N ~= M
    error ('s2z: S must be an NxNxK array (square at each frequency)');
  end

  Z = zeros (N, N, K);
  I = eye (N);

  for k = 1:K
    s = S(:,:,k);
    %% Z = z0 * (I + S) * inv(I - S)
    Z(:,:,k) = z0 * (I + s) / (I - s);
  endfor

endfunction

%!test
%! %% 1-port: matched (S11=0) -> Z = z0
%! S = zeros(1,1,3);
%! Z = s2z(S);
%! assert (Z, 50*ones(1,1,3), 1e-14);

%!test
%! %% 1-port: S11=1/3 -> Z = 50*(1+1/3)/(1-1/3) = 50*(4/3)/(2/3) = 100 ohm
%! S = (1/3)*ones(1,1,1);
%! Z = s2z(S);
%! assert (Z(1,1,1), 100.0, 1e-13);

%!test
%! %% 1-port: S11=-1 -> Z = 0 (short circuit)
%! S = -ones(1,1,1);
%! Z = s2z(S);
%! assert (Z(1,1,1), 0.0, 1e-14);

%!test
%! %% 2-port diagonal S (no port coupling): Z = diag(z0*(1+sii)/(1-sii))
%! %% Note: S matrices with eigenvalue 1 make (I-S) singular; use uncoupled S here.
%! S = zeros(2,2,1);  S(1,1,1) = 0.2;  S(2,2,1) = 0.1;
%! Z = s2z(S);
%! assert (Z(1,1,1), 50*1.2/0.8, 1e-13);   %% Z11 = 75 ohm
%! assert (Z(2,2,1), 50*1.1/0.9, 1e-13);   %% Z22 = 50*11/9 ohm
%! assert (Z(1,2,1), 0.0, 1e-13);
%! assert (Z(2,1,1), 0.0, 1e-13);

%!test
%! %% Round-trip: z2s(s2z(S)) == S
%! K = 20;
%! S = rand(2,2,K)*0.3 + 1j*rand(2,2,K)*0.1;
%! S(2,1,:) += 0.6;  S(1,2,:) = S(2,1,:);
%! assert (z2s(s2z(S)), S, 1e-11);

%!test
%! %% Custom z0
%! S = zeros(2,2,1);
%! S(1,2,1) = 1;  S(2,1,1) = 1;
%! Z_50  = s2z(S, 50);
%! Z_100 = s2z(S, 100);
%! %% For ideal thru, Z is singular regardless of z0
%! %% But ratio of on-diagonal should equal z0 ratio at any non-singular S
%! S2 = zeros(2,2,1);  S2(1,1,1) = 0.2;  S2(2,2,1) = 0.2;
%! Z_50b  = s2z(S2, 50);
%! Z_100b = s2z(S2, 100);
%! assert (Z_100b(1,1,1)/Z_50b(1,1,1), 2.0, 1e-12);

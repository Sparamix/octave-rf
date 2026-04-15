## -*- texinfo -*-
## @deftypefn  {Function File} {@var{S} =} y2s (@var{Y})
## @deftypefnx {Function File} {@var{S} =} y2s (@var{Y}, @var{z0})
## Convert N-port Y-parameters (admittance matrix) to S-parameters.
##
## @var{Y} is an NxNxK complex array.  @var{z0} is the reference impedance
## in ohms (scalar, default 50).  Returns an NxNxK S-parameter array.
## This is the inverse of @code{s2y}.
##
## @strong{Conversion formula (N-port, uniform Z0):}
## @verbatim
##   S = (I - z0*Y) * inv(I + z0*Y)
## @end verbatim
##
## @strong{Mathematical basis:}
## @verbatim
##   Pupalaikis, P.J., "S-Parameters for Signal Integrity",
##     Cambridge University Press, 2020.  [PRIMARY]
##     Section 3.4.3 "S-Parameters In Terms Of Y-Parameters",
##     Table 3.4, Eq. 3.18 (p.57): S = (I + Z0*Y)^-1 * (I - Z0*Y) —
##     matches this implementation exactly for the uniform-Z0 case.
##
##   Pozar, D.M., "Microwave Engineering", 4th ed., Wiley, 2012.
##     Section 4.2, Eq. 4.26-4.27 (p.175).  Table 4.2 (p.192): 2-port
##     Y-to-S conversion.
##
##   Hall, S.H. and Heck, H.L., "Advanced Signal Integrity for High-Speed
##     Digital Designs", Wiley-IEEE Press, 2009.
##     Section 9.2.1 "Impedance Matrix" (p.355); Section 9.2.2 (p.358).
## @end verbatim
##
## @seealso{s2y, z2s, abcd2s}
## @end deftypefn

function S = y2s (Y, z0)

  narginchk (1, 2);
  if nargin < 2
    z0 = 50.0;
  end
  if ~isscalar (z0) || ~isreal (z0) || z0 <= 0
    error ('y2s: z0 must be a positive real scalar');
  end

  [N, M, K] = size (Y);
  if N ~= M
    error ('y2s: Y must be an NxNxK array');
  end

  S = zeros (N, N, K);
  I = eye (N);

  for k = 1:K
    y = Y(:,:,k);
    S(:,:,k) = (I - z0*y) / (I + z0*y);
  endfor

endfunction

%!test
%! %% 1-port: Y = 1/50 (matched) -> S11 = 0
%! Y = ones(1,1,3)/50;
%! S = y2s(Y);
%! assert (S, zeros(1,1,3), 1e-15);

%!test
%! %% 1-port: Y = 0 (open circuit) -> S11 = +1
%! Y = zeros(1,1,1);
%! S = y2s(Y);
%! assert (S(1,1,1), 1.0, 1e-15);

%!test
%! %% Round-trip: s2y(y2s(Y)) == Y
%! K = 10;
%! Y = rand(2,2,K)/100 + 1j*rand(2,2,K)/200;
%! Y(1,2,:) = Y(2,1,:);  % reciprocal
%! assert (s2y(y2s(Y)), Y, 1e-11);

%!test
%! %% Y * Z = I (admittance is inverse of impedance)
%! %% Note: avoid S12=S21 with S11+S12=1 (eigenvalue 1 → singular I-S).
%! S = zeros(2,2,1);  S(1,1) = 0.2;  S(2,2) = 0.15;  S(1,2) = 0.6;  S(2,1) = 0.6;
%! Y = s2y(S);
%! Z = s2z(S);
%! assert (Y(:,:,1)*Z(:,:,1), eye(2), 1e-12);

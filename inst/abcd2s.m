## -*- texinfo -*-
## @deftypefn  {Function File} {@var{S} =} abcd2s (@var{A})
## @deftypefnx {Function File} {@var{S} =} abcd2s (@var{A}, @var{z0})
## Convert 2-port ABCD (chain/transmission) parameters to S-parameters.
##
## @var{A} must be a 2x2xK complex array.  @var{z0} is the reference
## impedance in ohms (scalar, default 50).  Returns a 2x2xK S-parameter array.
## This is the inverse of @code{s2abcd}.
##
## @strong{Conversion formulas:}
## @verbatim
##   d  = A + B/z0 + C*z0 + D       (common denominator)
##
##   S11 = (A + B/z0 - C*z0 - D) / d
##   S12 = 2*(A*D - B*C) / d         = 2*det(ABCD) / d
##   S21 = 2 / d
##   S22 = (-A + B/z0 - C*z0 + D) / d
## @end verbatim
##
## @strong{Note}: For reciprocal networks det(ABCD) = AD-BC = 1, so S12 = S21 = 2/d.
##
## @strong{Mathematical basis:}
## @verbatim
##   Pupalaikis, P.J., "S-Parameters for Signal Integrity",
##     Cambridge University Press, 2020.  [PRIMARY]
##     Section 3.4.5 "S-Parameters In Terms Of ABCD Parameters",
##     Table 3.6, Eq. 3.20 (p.60): S from ABCD — matches this
##     implementation element-by-element.
##
##   Pozar, D.M., "Microwave Engineering", 4th ed., Wiley, 2012.
##     Section 4.4, Eq. 4.69 (p.189): ABCD definition.
##     Table 4.2 (p.192): 2-port ABCD-to-S conversion.
##
##   Hall, S.H. and Heck, H.L., "Advanced Signal Integrity for High-Speed
##     Digital Designs", Wiley-IEEE Press, 2009.
##     Section 9.2.3 "ABCD Parameters" (p.382).
## @end verbatim
##
## @seealso{s2abcd, t2s, z2s}
## @end deftypefn

function S = abcd2s (A, z0)

  narginchk (1, 2);
  if nargin < 2
    z0 = 50.0;
  end
  if ~isscalar (z0) || ~isreal (z0) || z0 <= 0
    error ('abcd2s: z0 must be a positive real scalar');
  end
  if size (A, 1) ~= 2 || size (A, 2) ~= 2
    error ('abcd2s: A must be a 2x2xK array');
  end

  K = size (A, 3);
  S = zeros (2, 2, K);

  for k = 1:K
    a = A(1,1,k);  b = A(1,2,k);
    c = A(2,1,k);  d = A(2,2,k);
    denom = a + b/z0 + c*z0 + d;
    if denom == 0
      error ('abcd2s: denominator is zero at frequency index %d', k);
    end
    S(1,1,k) = (a + b/z0 - c*z0 - d) / denom;
    S(1,2,k) = 2*(a*d - b*c) / denom;
    S(2,1,k) = 2 / denom;
    S(2,2,k) = (-a + b/z0 - c*z0 + d) / denom;
  endfor

endfunction

%!test
%! %% Identity ABCD = [1 0; 0 1] -> ideal thru
%! A = repmat(reshape(eye(2),2,2,1), [1 1 3]);
%! S = abcd2s(A, 50);
%! for k = 1:3
%!   assert (S(:,:,k), [0 1; 1 0], 1e-14);
%! end

%!test
%! %% Series impedance z0: ABCD=[1 z0; 0 1] -> S11=1/3, S21=2/3
%! z0 = 50;
%! A = zeros(2,2,1);  A(1,1) = 1;  A(1,2) = z0;  A(2,2) = 1;
%! S = abcd2s(A, z0);
%! assert (S(1,1,1), 1/3, 1e-14);
%! assert (S(2,1,1), 2/3, 1e-14);
%! assert (S(1,2,1), 2/3, 1e-14);
%! assert (S(2,2,1), 1/3, 1e-14);

%!test
%! %% Round-trip: s2abcd(abcd2s(A)) == A
%! K = 20;
%! A = zeros(2,2,K);
%! A(1,1,:) = 1 + rand(1,1,K)*0.1;
%! A(1,2,:) = rand(1,1,K)*30 + 10j;
%! A(2,1,:) = rand(1,1,K)*0.01;
%! A(2,2,:) = 1 + rand(1,1,K)*0.1;
%! assert (s2abcd(abcd2s(A, 50), 50), A, 1e-11);

%!test
%! %% Shunt admittance Y=1/z0: ABCD=[1 0; 1/z0 1] -> S11=-1/3, S21=2/3
%! z0 = 50;
%! A = zeros(2,2,1);  A(1,1) = 1;  A(2,1) = 1/z0;  A(2,2) = 1;
%! S = abcd2s(A, z0);
%! assert (S(1,1,1), -1/3, 1e-14);
%! assert (S(2,1,1),  2/3, 1e-14);

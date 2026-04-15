## -*- texinfo -*-
## @deftypefn  {Function File} {@var{A} =} s2abcd (@var{S})
## @deftypefnx {Function File} {@var{A} =} s2abcd (@var{S}, @var{z0})
## Convert 2-port S-parameters to ABCD (chain/transmission) parameters.
##
## @var{S} must be a 2x2xK complex array.  @var{z0} is the reference
## impedance in ohms (scalar, default 50).  Returns a 2x2xK ABCD array.
##
## The ABCD matrix is defined by:
## @verbatim
##   [V1]   [A  B] [ V2]
##   [I1] = [C  D] [-I2]
## @end verbatim
## where the sign convention is current flowing INTO port 1 and OUT OF port 2.
##
## @strong{Conversion formulas:}
## @verbatim
##   d  = 2 * S21                   (common denominator)
##
##   A  = ((1+S11)(1-S22) + S12*S21) / d
##   B  = z0 * ((1+S11)(1+S22) - S12*S21) / d
##   C  = (1/z0) * ((1-S11)(1-S22) - S12*S21) / d
##   D  = ((1-S11)(1+S22) + S12*S21) / d
## @end verbatim
##
## @strong{Mathematical basis:}
## @verbatim
##   Pupalaikis, P.J., "S-Parameters for Signal Integrity",
##     Cambridge University Press, 2020.  [PRIMARY]
##     Section 3.4.6 "ABCD Parameters In Terms Of S-Parameters",
##     Table 3.7 (p.61): ABCD from S — matches this implementation
##     element-by-element.
##
##   Pozar, D.M., "Microwave Engineering", 4th ed., Wiley, 2012.
##     Section 4.4, Eq. 4.69 (p.189): ABCD definition
##       V1 = A*V2 + B*I2,  I1 = C*V2 + D*I2
##     (sign convention: I2 flows OUT of port 2 for cascading).
##     Table 4.2 (p.192): 2-port S-to-ABCD conversion.
##
##   Hall, S.H. and Heck, H.L., "Advanced Signal Integrity for High-Speed
##     Digital Designs", Wiley-IEEE Press, 2009.
##     Section 9.2.3 "ABCD Parameters" (p.382).
##
##   Resso, M. and Bogatin, E., "Signal Integrity Characterization
##     Techniques", IEC, 2009.  ABCD in the context of transmission-line
##     cascades.
## @end verbatim
##
## @seealso{abcd2s, s2t, s2z}
## @end deftypefn

function A = s2abcd (S, z0)

  narginchk (1, 2);
  if nargin < 2
    z0 = 50.0;
  end
  if ~isscalar (z0) || ~isreal (z0) || z0 <= 0
    error ('s2abcd: z0 must be a positive real scalar');
  end
  if size (S, 1) ~= 2 || size (S, 2) ~= 2
    error ('s2abcd: S must be a 2x2xK array (ABCD is only defined for 2-port networks)');
  end

  K = size (S, 3);
  A = zeros (2, 2, K);

  for k = 1:K
    s11 = S(1,1,k);  s12 = S(1,2,k);
    s21 = S(2,1,k);  s22 = S(2,2,k);
    if s21 == 0
      error ('s2abcd: S21 is zero at frequency index %d', k);
    end
    d = 2 * s21;
    A(1,1,k) = ((1+s11)*(1-s22) + s12*s21) / d;
    A(1,2,k) = z0 * ((1+s11)*(1+s22) - s12*s21) / d;
    A(2,1,k) = (1/z0) * ((1-s11)*(1-s22) - s12*s21) / d;
    A(2,2,k) = ((1-s11)*(1+s22) + s12*s21) / d;
  endfor

endfunction

%!test
%! %% Ideal thru: S = [0 1; 1 0] -> ABCD = identity
%! S = reshape([0 1 1 0], 2, 2, 1);
%! A = s2abcd(S, 50);
%! assert (A(:,:,1), eye(2), 1e-14);

%!test
%! %% Series impedance z0=50: S11=S22=1/3, S12=S21=2/3 -> ABCD = [1 z0; 0 1]
%! z0 = 50;
%! S = reshape([1/3, 2/3, 2/3, 1/3], 2, 2, 1);
%! A = s2abcd(S, z0);
%! assert (A(1,1,1), 1.0, 1e-13);
%! assert (A(1,2,1), z0,  1e-11);
%! assert (A(2,1,1), 0.0, 1e-13);
%! assert (A(2,2,1), 1.0, 1e-13);

%!test
%! %% Round-trip: abcd2s(s2abcd(S)) == S
%! K = 20;
%! S = rand(2,2,K)*0.2 + 1j*rand(2,2,K)*0.1;
%! S(2,1,:) += 0.7;  S(1,2,:) = S(2,1,:);
%! assert (abcd2s(s2abcd(S, 50), 50), S, 1e-12);

%!test
%! %% Multi-frequency: AD-BC = 1 for reciprocal networks (det(ABCD)=1)
%! K = 10;
%! S = rand(2,2,K)*0.15;
%! S(2,1,:) += 0.8;  S(1,2,:) = S(2,1,:);  % reciprocal
%! A = s2abcd(S, 50);
%! for k = 1:K
%!   det_A = A(1,1,k)*A(2,2,k) - A(1,2,k)*A(2,1,k);
%!   assert (det_A, 1.0, 1e-12);
%! end

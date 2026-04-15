## -*- texinfo -*-
## @deftypefn  {Function File} {@var{H} =} s2h (@var{S})
## @deftypefnx {Function File} {@var{H} =} s2h (@var{S}, @var{z0})
## Convert 2-port S-parameters to H-parameters (hybrid parameters).
##
## @var{S} must be a 2x2xK complex array.  @var{z0} is the reference impedance
## (scalar, default 50).  Returns a 2x2xK H-parameter array.
##
## H-parameters are defined by:
## @verbatim
##   [V1]   [H11  H12] [I1]
##   [I2] = [H21  H22] [V2]
## @end verbatim
## H11 has units of ohms, H22 has units of siemens, H12 and H21 are dimensionless.
##
## @strong{Algorithm}: Computed via Z-parameters as an intermediate:
## @verbatim
##   Z   = s2z(S, z0)
##   H11 = det(Z) / Z22 = (Z11*Z22 - Z12*Z21) / Z22
##   H12 =  Z12 / Z22
##   H21 = -Z21 / Z22
##   H22 =  1   / Z22
## @end verbatim
##
## @strong{Mathematical basis:}
## @verbatim
##   Pupalaikis, P.J., "S-Parameters for Signal Integrity",
##     Cambridge University Press, 2020.  [PRIMARY]
##     Chapter 1, Section 1.2 "Network Parameter Models of Circuit
##     Elements" (p.16): H-parameter definition
##       V1 = H11*I1 + H12*V2,  I2 = H21*I1 + H22*V2.
##     Z-to-H conversion via 2x2 matrix partitioning (standard linear
##     algebra, as used here).
##
##   Bogatin, E., "Signal Integrity Simplified", 3rd ed., Pearson, 2018.
##     Chapter "S-Parameters and Other Parameter Sets" — SI-practitioner
##     perspective on hybrid (H) parameters and their use in transistor
##     models.
##
##   NOTE: Pozar's "Microwave Engineering" 4th ed. Table 4.2 (p.192)
##   covers only S, Z, Y, and ABCD parameters — it does NOT include
##   H-parameters.  Pozar §4.3 (Z-parameters, p.174-181) provides the
##   intermediate used by this implementation.
## @end verbatim
##
## @seealso{h2s, s2g, s2z, s2abcd}
## @end deftypefn

function H = s2h (S, z0)

  narginchk (1, 2);
  if nargin < 2
    z0 = 50.0;
  end
  if size (S, 1) ~= 2 || size (S, 2) ~= 2
    error ('s2h: S must be a 2x2xK array (H-parameters only defined for 2-port networks)');
  end

  K = size (S, 3);
  Z = s2z (S, z0);
  H = zeros (2, 2, K);

  for k = 1:K
    z11 = Z(1,1,k);  z12 = Z(1,2,k);
    z21 = Z(2,1,k);  z22 = Z(2,2,k);
    if z22 == 0
      error ('s2h: Z22 is zero at frequency index %d', k);
    end
    H(1,1,k) = (z11*z22 - z12*z21) / z22;
    H(1,2,k) =  z12 / z22;
    H(2,1,k) = -z21 / z22;
    H(2,2,k) =  1.0 / z22;
  endfor

endfunction

%!test
%! %% Round-trip: h2s(s2h(S)) == S
%! K = 10;
%! S = rand(2,2,K)*0.15 + 1j*rand(2,2,K)*0.1;
%! S(2,1,:) += 0.75;  S(1,2,:) = S(2,1,:);
%! assert (h2s(s2h(S)), S, 1e-10);

%!test
%! %% H11 has units of impedance: for matched S (S11=0), H11 ~ z0
%! S = zeros(2,2,1);
%! H = s2h(S);
%! %% Z = z0*I for S=0, so H11 = det(z0*I)/z0 = z0^2/z0 = z0
%! assert (H(1,1,1), 50.0, 1e-12);

%!test
%! %% H22 = 1/Z22: verify against s2z
%! S = zeros(2,2,1);  S(1,1) = 0.2;  S(2,2) = 0.15;
%! S(1,2) = 0.8;  S(2,1) = 0.8;
%! H = s2h(S);
%! Z = s2z(S);
%! assert (H(2,2,1), 1/Z(2,2,1), 1e-13);
%! assert (H(1,2,1), Z(1,2,1)/Z(2,2,1), 1e-13);

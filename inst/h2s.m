## -*- texinfo -*-
## @deftypefn  {Function File} {@var{S} =} h2s (@var{H})
## @deftypefnx {Function File} {@var{S} =} h2s (@var{H}, @var{z0})
## Convert 2-port H-parameters (hybrid parameters) to S-parameters.
##
## @var{H} must be a 2x2xK complex array.  @var{z0} is the reference impedance
## (scalar, default 50).  Returns a 2x2xK S-parameter array.
## This is the inverse of @code{s2h}.
##
## @strong{Algorithm}: Computed via Z-parameters:
## @verbatim
##   Z11 = (H11*H22 - H12*H21) / H22 = det(H) / H22
##   Z12 =  H12 / H22
##   Z21 = -H21 / H22
##   Z22 =  1   / H22
##   S   = z2s(Z, z0)
## @end verbatim
##
## @strong{Mathematical basis:}
## @verbatim
##   Pupalaikis, P.J., "S-Parameters for Signal Integrity",
##     Cambridge University Press, 2020.  [PRIMARY]
##     Chapter 1, Section 1.2 (p.16): H-parameter definition.
##     H-to-Z conversion via 2x2 matrix partitioning, then z2s.
##
##   Bogatin, E., "Signal Integrity Simplified", 3rd ed., Pearson, 2018.
##
##   NOTE: Pozar's "Microwave Engineering" 4th ed. Table 4.2 (p.192) does
##   NOT include H-parameters.  The algorithm uses Z-parameters as an
##   intermediate (see z2s.m for Z-to-S references).
## @end verbatim
##
## @seealso{s2h, g2s, z2s}
## @end deftypefn

function S = h2s (H, z0)

  narginchk (1, 2);
  if nargin < 2
    z0 = 50.0;
  end
  if size (H, 1) ~= 2 || size (H, 2) ~= 2
    error ('h2s: H must be a 2x2xK array');
  end

  K = size (H, 3);
  Z = zeros (2, 2, K);

  for k = 1:K
    h11 = H(1,1,k);  h12 = H(1,2,k);
    h21 = H(2,1,k);  h22 = H(2,2,k);
    if h22 == 0
      error ('h2s: H22 is zero at frequency index %d', k);
    end
    Z(1,1,k) = (h11*h22 - h12*h21) / h22;
    Z(1,2,k) =  h12 / h22;
    Z(2,1,k) = -h21 / h22;
    Z(2,2,k) =  1.0 / h22;
  endfor

  S = z2s (Z, z0);

endfunction

%!test
%! %% Round-trip: s2h(h2s(H)) == H
%! K = 8;
%! S = rand(2,2,K)*0.15 + 1j*rand(2,2,K)*0.1;
%! S(2,1,:) += 0.75;  S(1,2,:) = S(2,1,:);
%! H = s2h(S);
%! assert (h2s(H), S, 1e-10);

%!test
%! %% H22 = 1/Z22 and Z22 = 1/H22 inverse
%! S = zeros(2,2,1);  S(1,2) = 0.9;  S(2,1) = 0.9;  S(1,1) = 0.05;
%! H = s2h(S);
%! Z = s2z(S);
%! assert (H(2,2,1)*Z(2,2,1), 1.0, 1e-13);

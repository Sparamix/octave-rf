## -*- texinfo -*-
## @deftypefn  {Function File} {@var{G} =} s2g (@var{S})
## @deftypefnx {Function File} {@var{G} =} s2g (@var{S}, @var{z0})
## Convert 2-port S-parameters to G-parameters (inverse hybrid parameters).
##
## @var{S} must be a 2x2xK complex array.  @var{z0} is the reference impedance
## (scalar, default 50).  Returns a 2x2xK G-parameter array.
##
## G-parameters are the matrix inverse of H-parameters: G = inv(H).
## They are defined by:
## @verbatim
##   [I1]   [G11  G12] [V1]
##   [V2] = [G21  G22] [I2]
## @end verbatim
## G11 has units of siemens, G22 has units of ohms.
##
## @strong{Algorithm}: G = inv(H) for each frequency slice:
## @verbatim
##   H   = s2h(S, z0)
##   G11 =  H22 / det(H)
##   G12 = -H12 / det(H)
##   G21 = -H21 / det(H)
##   G22 =  H11 / det(H)
## @end verbatim
##
## @strong{Mathematical basis:}
## @verbatim
##   Pupalaikis, P.J., "S-Parameters for Signal Integrity",
##     Cambridge University Press, 2020.  [PRIMARY]
##     Chapter 1, Section 1.2 "Network Parameter Models of Circuit
##     Elements" (p.16): G-parameter definition as the inverse of the
##     H-parameter relation.
##
##   Bogatin, E., "Signal Integrity Simplified", 3rd ed., Pearson, 2018.
##     Chapter "S-Parameters and Other Parameter Sets".
##
##   NOTE: Pozar's "Microwave Engineering" 4th ed. Table 4.2 (p.192)
##   does NOT include G-parameters.  The algorithm goes via H-parameters
##   (see s2h.m) and inverts per frequency.
## @end verbatim
##
## @seealso{g2s, s2h, h2s}
## @end deftypefn

function G = s2g (S, z0)

  narginchk (1, 2);
  if nargin < 2
    z0 = 50.0;
  end
  if size (S, 1) ~= 2 || size (S, 2) ~= 2
    error ('s2g: S must be a 2x2xK array');
  end

  K  = size (S, 3);
  H  = s2h (S, z0);
  G  = zeros (2, 2, K);

  for k = 1:K
    h11 = H(1,1,k);  h12 = H(1,2,k);
    h21 = H(2,1,k);  h22 = H(2,2,k);
    d   = h11*h22 - h12*h21;   % det(H)
    if d == 0
      error ('s2g: det(H) is zero at frequency index %d', k);
    end
    G(1,1,k) =  h22 / d;
    G(1,2,k) = -h12 / d;
    G(2,1,k) = -h21 / d;
    G(2,2,k) =  h11 / d;
  endfor

endfunction

%!test
%! %% Round-trip: g2s(s2g(S)) == S
%! K = 8;
%! S = rand(2,2,K)*0.15 + 1j*rand(2,2,K)*0.1;
%! S(2,1,:) += 0.75;  S(1,2,:) = S(2,1,:);
%! assert (g2s(s2g(S)), S, 1e-10);

%!test
%! %% G = inv(H) per frequency slice
%! S = zeros(2,2,1);  S(1,2) = 0.9;  S(2,1) = 0.9;  S(1,1) = 0.1;
%! H = s2h(S);
%! G = s2g(S);
%! assert (G(:,:,1)*H(:,:,1), eye(2), 1e-12);
%! assert (H(:,:,1)*G(:,:,1), eye(2), 1e-12);

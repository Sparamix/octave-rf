## -*- texinfo -*-
## @deftypefn  {Function File} {@var{S} =} g2s (@var{G})
## @deftypefnx {Function File} {@var{S} =} g2s (@var{G}, @var{z0})
## Convert 2-port G-parameters (inverse hybrid parameters) to S-parameters.
##
## @var{G} must be a 2x2xK complex array.  @var{z0} is the reference impedance
## (scalar, default 50).  Returns a 2x2xK S-parameter array.
## This is the inverse of @code{s2g}.  Since G = inv(H), this computes
## H = inv(G) then calls @code{h2s}.
##
## @strong{Mathematical basis:}
## @verbatim
##   Pupalaikis, P.J., "S-Parameters for Signal Integrity",
##     Cambridge University Press, 2020.  [PRIMARY]
##     Chapter 1, Section 1.2 (p.16): G-parameter definition.
##
##   Bogatin, E., "Signal Integrity Simplified", 3rd ed., Pearson, 2018.
##
##   NOTE: Pozar's "Microwave Engineering" 4th ed. Table 4.2 (p.192) does
##   NOT include G-parameters.  Algorithm inverts G per frequency to get
##   H, then calls h2s (see h2s.m).
## @end verbatim
##
## @seealso{s2g, h2s, s2h}
## @end deftypefn

function S = g2s (G, z0)

  narginchk (1, 2);
  if nargin < 2
    z0 = 50.0;
  end
  if size (G, 1) ~= 2 || size (G, 2) ~= 2
    error ('g2s: G must be a 2x2xK array');
  end

  K = size (G, 3);
  H = zeros (2, 2, K);

  for k = 1:K
    g11 = G(1,1,k);  g12 = G(1,2,k);
    g21 = G(2,1,k);  g22 = G(2,2,k);
    d   = g11*g22 - g12*g21;   % det(G)
    if d == 0
      error ('g2s: det(G) is zero at frequency index %d', k);
    end
    H(1,1,k) =  g22 / d;
    H(1,2,k) = -g12 / d;
    H(2,1,k) = -g21 / d;
    H(2,2,k) =  g11 / d;
  endfor

  S = h2s (H, z0);

endfunction

%!test
%! %% Round-trip: s2g(g2s(G)) == G
%! K = 8;
%! S = rand(2,2,K)*0.15 + 1j*rand(2,2,K)*0.1;
%! S(2,1,:) += 0.75;  S(1,2,:) = S(2,1,:);
%! G = s2g(S);
%! assert (s2g(g2s(G)), G, 1e-10);

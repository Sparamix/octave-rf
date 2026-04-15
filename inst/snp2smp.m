## -*- texinfo -*-
## @deftypefn {Function File} {@var{S_out} =} snp2smp (@var{S}, @var{portorder})
## Reorder the ports of an N-port S-parameter matrix.
##
## @var{S} is an NxNxK complex array.  @var{portorder} is a 1xN vector of
## 1-indexed port numbers specifying the new port ordering.
## Returns an NxNxK array with rows and columns permuted by @var{portorder}.
##
## @strong{Example}: For a 4-port network with portorder = [3 4 1 2],
## the new port 1 corresponds to old port 3, new port 2 to old port 4, etc.
##
## @strong{Algorithm}: Row and column permutation of the S-matrix:
## @verbatim
##   S_out(i,j,:) = S(portorder(i), portorder(j), :)
## @end verbatim
##
## @strong{Mathematical basis:}
## @verbatim
##   Pupalaikis, P.J., "S-Parameters for Signal Integrity",
##     Cambridge University Press, 2020.
##     Chapter 3, Section 3.1 "S-Parameter Definition" (p.41): port
##     numbering convention.  Section 3.3 "Example S-Parameter Circuit
##     Calculations" (p.46): row/column permutation changes only the
##     labeling of ports.  Port reorder is standard linear algebra:
##     P * S * P^T for a permutation matrix P.
## @end verbatim
##
## @seealso{s2smm, smm2s}
## @end deftypefn

function S_out = snp2smp (S, portorder)

  narginchk (2, 2);

  N = size(S, 1);
  if size(S, 2) ~= N
    error ('snp2smp: S must be an NxNxK array');
  end
  if numel(portorder) ~= N
    error ('snp2smp: portorder must have %d elements for a %d-port network', N, N);
  end
  if any(portorder < 1) || any(portorder > N) || numel(unique(portorder)) ~= N
    error ('snp2smp: portorder must be a permutation of 1..%d', N);
  end

  S_out = S(portorder, portorder, :);

endfunction

%!test
%! %% Identity permutation: no change
%! K = 5;
%! S = rand(4,4,K) + 1j*rand(4,4,K);
%! assert (snp2smp(S, [1 2 3 4]), S, 1e-15);

%!test
%! %% Swap ports 1 and 2 of a 2-port
%! S = zeros(2,2,1);  S(1,1) = 0.1;  S(2,2) = 0.2;  S(1,2) = 0.8;  S(2,1) = 0.85;
%! Sp = snp2smp(S, [2 1]);
%! assert (Sp(1,1,1), S(2,2,1), 1e-15);
%! assert (Sp(2,2,1), S(1,1,1), 1e-15);
%! assert (Sp(1,2,1), S(2,1,1), 1e-15);
%! assert (Sp(2,1,1), S(1,2,1), 1e-15);

%!test
%! %% Double permutation = identity
%! K = 3;
%! S = rand(3,3,K) + 1j*rand(3,3,K);
%! po = [2 3 1];
%! %% inverse of [2 3 1] is [3 1 2]
%! po_inv = [3 1 2];
%! assert (snp2smp(snp2smp(S, po), po_inv), S, 1e-15);

## -*- texinfo -*-
## @deftypefn {Function File} {@var{v} =} rfparam (@var{s}, @var{i}, @var{j})
## Extract a single S-parameter element from a sparameters struct.
##
## Returns a @var{K}x1 column vector of the S@var{ij} element over all
## @var{K} frequency points, where @var{i} and @var{j} are 1-indexed port numbers.
##
## This is an Octave replacement for the MATLAB RF Toolbox @code{rfparam}
## function.  Equivalent to @code{squeeze(s.Parameters(i,j,:))}.
##
## @example
## s21 = rfparam(s, 2, 1);   % extract S21 over all frequencies
## @end example
##
## @seealso{sparameters}
## @end deftypefn

function v = rfparam (s, i, j)

  narginchk (3, 3);

  if ~isstruct (s) || ~isfield (s, 'Parameters')
    error ('rfparam: first argument must be a sparameters struct');
  end
  [N, M, K] = size (s.Parameters);
  if i < 1 || i > N || j < 1 || j > M
    error ('rfparam: port indices (%d,%d) out of range for %d-port network', i, j, N);
  end

  v = squeeze (s.Parameters(i, j, :));

endfunction

%!test
%! %% Basic extraction — S21 of an ideal thru
%! f = [1e9; 2e9; 3e9];
%! p = zeros(2,2,3);  p(1,2,:) = 1;  p(2,1,:) = 1;
%! s = sparameters(p, f);
%! assert (rfparam(s, 2, 1), [1; 1; 1], 1e-15);
%! assert (rfparam(s, 1, 1), [0; 0; 0], 1e-15);

%!test
%! %% 4-port extraction
%! f = [1e9; 2e9];
%! p = rand(4,4,2) + 1j*rand(4,4,2);
%! s = sparameters(p, f);
%! assert (rfparam(s, 3, 2), squeeze(p(3,2,:)), 1e-15);

%!test
%! %% Column vector output for K=1
%! f = 5e9;
%! p = reshape([0 1; 1 0], 2, 2, 1);
%! s = sparameters(p, f);
%! v = rfparam(s, 2, 1);
%! assert (numel(v), 1);
%! assert (v, 1, 1e-15);

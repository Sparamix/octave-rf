## -*- texinfo -*-
## @deftypefn {Function File} {@var{y} =} ifft_symmetric (@var{x})
## @deftypefnx {Function File} {@var{y} =} ifft_symmetric (@var{x}, @var{n})
## Compute the inverse FFT treating the input as conjugate-symmetric,
## returning a real-valued result.
##
## This is an Octave compatibility shim for MATLAB's
## @code{ifft(x, 'symmetric')} syntax, which is not supported in Octave.
## The 'symmetric' flag in MATLAB forces the result to be real-valued by
## treating the input as if it were exactly conjugate-symmetric (even if
## numerical noise makes it slightly non-symmetric).
##
## The Octave-compatible equivalent is @code{real(ifft(x))}, which discards
## the imaginary part that arises from floating-point asymmetry.
##
## @strong{Usage in IEEE P370}: The IEEE P370 MATLAB scripts
## (@code{IEEEP3702xThru.m}, @code{IEEEP370Zc2xThru.m}, etc.) call
## @code{ifft(makeSymmetric([dc; s]), 'symmetric')} to compute real-valued
## impulse responses from conjugate-symmetric spectra.  Replace these calls
## with @code{ifft_symmetric(makeSymmetric([dc; s]))} for Octave compatibility.
##
## If @var{n} is given, the FFT length is @var{n} (zero-padded or truncated).
##
## @seealso{ifft}
## @end deftypefn

function y = ifft_symmetric (x, n)

  narginchk (1, 2);

  if nargin == 1
    y = real (ifft (x));
  else
    y = real (ifft (x, n));
  end

endfunction

%!test
%! %% Purely real sinusoid spectrum → real time domain
%! N  = 8;
%! t  = (0:N-1).';
%! x  = cos(2*pi*t/N);               % time-domain signal
%! X  = fft(x);                       % conjugate-symmetric spectrum
%! y  = ifft_symmetric(X);
%! assert (isreal(y), true);
%! assert (y, x, 1e-12);

%!test
%! %% Conjugate-symmetric input → imaginary part below floating-point noise
%! X = [4; 1-1j; 0; 1+1j];           % conjugate-symmetric DFT (N=4)
%! y = ifft_symmetric(X);
%! assert (isreal(y), true);
%! assert (max(abs(imag(ifft(X)))), 0, 1e-14);   % imag is already ~0

%!test
%! %% Result equals real(ifft(x)) for any input
%! x = rand(16,1) + 1j*rand(16,1);
%! assert (ifft_symmetric(x), real(ifft(x)), 1e-15);

%!test
%! %% n argument: zero-padding
%! x = [1; 0; -1; 0];
%! y = ifft_symmetric(x, 8);
%! assert (isreal(y), true);
%! assert (length(y), 8);

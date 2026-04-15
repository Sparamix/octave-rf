## -*- texinfo -*-
## @deftypefn {Function File} {@var{s_out} =} embedsparams (@var{s_dut}, @var{s_fix1}, @var{s_fix2})
## Embed a DUT inside fixture S-parameters (inverse of de-embedding).
##
## @var{s_dut} is the device under test, @var{s_fix1} is the left fixture,
## and @var{s_fix2} is the right fixture.  All three are either sparameters
## structs or 2x2xK arrays.  Returns the embedded (fixture-DUT-fixture) cascade.
##
## This is the exact inverse of @code{deembedsparams}:
## @code{embedsparams(deembedsparams(S_m, f1, f2), f1, f2) == S_m}
##
## @strong{Algorithm:}
## @verbatim
##   T_result = T_fix1 * T_dut * T_fix2
## @end verbatim
## which is equivalent to @code{cascadesparams(s_fix1, s_dut, s_fix2)}.
##
## @strong{Mathematical basis:}
## @verbatim
##   Pupalaikis, P.J., "S-Parameters for Signal Integrity",
##     Cambridge University Press, 2020.  [PRIMARY]
##     Section 3.7 "Cascading" (p.69): T_total = TL * TR.
##     Chapter 10 "De-embedding" (p.282): forward cascade
##       T_measured = T_left * T_DUT * T_right
##     is the inverse operation of de-embedding.
##
##   Hall, S.H. and Heck, H.L., "Advanced Signal Integrity for High-Speed
##     Digital Designs", Wiley-IEEE Press, 2009.
##     Section 9.2.4 "Cascading S-Parameters" (p.390).
## @end verbatim
##
## @seealso{deembedsparams, cascadesparams}
## @end deftypefn

function s_out = embedsparams (s_dut, s_fix1, s_fix2)

  narginchk (3, 3);
  %% embedsparams is exactly cascadesparams(fix1, dut, fix2)
  s_out = cascadesparams (s_fix1, s_dut, s_fix2);

endfunction

%!test
%! %% embed then deembed == identity
%! K = 8;
%! f  = linspace(1e9, 8e9, K).';
%! p_f   = zeros(2,2,K);  p_f(2,1,:)  = exp(-1j*linspace(0,pi,K));  p_f(1,2,:) = p_f(2,1,:);
%! p_dut = zeros(2,2,K);  p_dut(2,1,:) = 0.8*exp(-1j*linspace(0,pi/2,K)); p_dut(1,2,:) = p_dut(2,1,:);
%! s_f   = sparameters(p_f, f);
%! s_dut = sparameters(p_dut, f);
%! s_emb = embedsparams(s_dut, s_f, s_f);
%! s_rec = deembedsparams(s_emb, s_f, s_f);
%! assert (s_rec.Parameters, p_dut, 1e-10);

%!test
%! %% deembed then embed == identity
%! K = 6;
%! f  = linspace(1e9, 6e9, K).';
%! p_f = zeros(2,2,K);  p_f(2,1,:) = exp(-1j*linspace(0,2,K));  p_f(1,2,:) = p_f(2,1,:);
%! p_m = zeros(2,2,K);  p_m(2,1,:) = 0.7*exp(-1j*linspace(0,3,K)); p_m(1,2,:) = p_m(2,1,:);
%! s_f = sparameters(p_f, f);
%! s_m = sparameters(p_m, f);
%! s_dut = deembedsparams(s_m, s_f, s_f);
%! s_emb = embedsparams(s_dut, s_f, s_f);
%! assert (s_emb.Parameters, p_m, 1e-10);

%!test
%! %% embedsparams == cascadesparams(fix1, dut, fix2)
%! K = 5;
%! f = linspace(1e9,5e9,K).';
%! pf  = zeros(2,2,K); pf(2,1,:) = 0.9; pf(1,2,:) = 0.9;
%! pd  = zeros(2,2,K); pd(2,1,:) = 0.8; pd(1,2,:) = 0.8;
%! sf = sparameters(pf, f);  sd = sparameters(pd, f);
%! r1 = embedsparams(sd, sf, sf);
%! r2 = cascadesparams(sf, sd, sf);
%! assert (r1.Parameters, r2.Parameters, 1e-14);

%% run_all_tests.m — Master test runner for octave-rf package
%%
%% Runs the embedded %!test BIST blocks for every function in inst/.
%% Usage: run('octave-rf/test/run_all_tests.m')  from the repo root
%%        OR from within octave-rf/: run('test/run_all_tests.m')
%%
%% Each function's %!test blocks are run by Octave's built-in 'test' command.
%% A summary line is printed for each function.

functions_tier1 = {'sparameters', 'rfparam', 's2t', 't2s', ...
                   'cascadesparams', 'deembedsparams', 'embedsparams', ...
                   's2abcd', 'abcd2s', 's2z', 'z2s', 'ifft_symmetric'};

functions_tier2 = {'s2sdd', 's2scc', 'smm2s', 's2smm', ...
                   'snp2smp', 'renormsparams'};

functions_tier3 = {'s2y', 'y2s', 's2h', 'h2s', 's2g', 'g2s'};

all_functions = [functions_tier1, functions_tier2, functions_tier3];

pass_total = 0;
fail_total = 0;
skip_total = 0;

printf('\n=== octave-rf BIST test suite ===\n\n');

for i = 1:length(all_functions)
  fn = all_functions{i};
  if exist(fn, 'file')
    [pass, fail, skip] = test(fn, 'quiet');
    pass_total += pass;
    fail_total += fail;
    skip_total += skip;
    if fail > 0
      printf('  FAIL  %s  (%d pass, %d fail, %d skip)\n', fn, pass, fail, skip);
    else
      printf('  OK    %s  (%d pass, %d skip)\n', fn, pass, skip);
    end
  else
    printf('  ---   %s  (not implemented yet)\n', fn);
  end
end

printf('\n=== Summary: %d passed, %d failed, %d skipped ===\n\n', ...
       pass_total, fail_total, skip_total);

if fail_total > 0
  error('run_all_tests: %d test(s) failed', fail_total);
end

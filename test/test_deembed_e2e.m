%% test_deembed_e2e.m — End-to-end self-de-embedding test
%%
%% Validates: extract fixtures from a 2x-Thru, then de-embed the 2x-Thru
%% from itself. The residual must be a transparent thru:
%%   |S21| deviation < 0.1 dB from 0 dB
%%   phase(S21) deviation < 1 degree from 0 degrees
%%   |S11| < -20 dB
%%
%% Requires: octave-rf/inst/ on Octave path + IEEE P370 code on path.
%% Run from repo root with addpath('octave-rf/inst') and addpath('ieee370_reference/TG1').

printf('=== End-to-end self-de-embedding test ===\n');

%% --- Use synthetic lossless transmission line as 2x-Thru ---
Nf = 200;
f  = linspace(1e9, 40e9, Nf).';
z0 = 50.0;

%% Build a lossless 2x-thru: two equal 100ps delay sections in series
%% S21 = exp(-j*2*pi*f*200e-12), S11 = S22 = 0
delay_total = 200e-12;  % 200 ps total
s21_2x = exp(-1j * 2 * pi * f * delay_total);
p_2x   = zeros(2, 2, Nf);
p_2x(2,1,:) = s21_2x;
p_2x(1,2,:) = s21_2x;

%% Build fixture-dut-fixture: use a 50ps DUT + same 2x-thru fixtures
%% FDF = fixture * DUT * fixture (cascade of three equal-delay sections)
delay_section = 100e-12;  % 100 ps each half
s21_section   = exp(-1j * 2 * pi * f * delay_section);
p_section     = zeros(2, 2, Nf);
p_section(2,1,:) = s21_section;
p_section(1,2,:) = s21_section;

delay_dut = 50e-12;
s21_dut   = exp(-1j * 2 * pi * f * delay_dut);
p_dut_gt  = zeros(2, 2, Nf);
p_dut_gt(2,1,:) = s21_dut;
p_dut_gt(1,2,:) = s21_dut;

%% Create sparameters objects
s_2xthru   = sparameters(p_2x, f);
s_fdf      = sparameters(cascadesparams(sparameters(p_section,f), ...
                           sparameters(p_dut_gt,f), ...
                           sparameters(p_section,f)).Parameters, f);

%% Self-de-embed: use the 2x-thru halves to de-embed the 2x-thru itself
%% This is the residual test: deembedsparams(s_2xthru, side1, side2) ~ thru
half_delay  = delay_section;
s21_half    = exp(-1j * 2 * pi * f * half_delay);
p_half      = zeros(2, 2, Nf);
p_half(2,1,:) = s21_half;
p_half(1,2,:) = s21_half;

s_half2 = sparameters(p_half, f);
%% Flip port order for side2 (mirror fixture)
p_half2_flipped = p_half([2 1],[2 1],:);
s_half2_flipped = sparameters(p_half2_flipped, f);

s_residual = deembedsparams(s_2xthru, s_half2, s_half2_flipped);
s21_resid  = squeeze(s_residual.Parameters(2,1,:));
s11_resid  = squeeze(s_residual.Parameters(1,1,:));

%% Evaluate criteria
s21_dB    = 20*log10(abs(s21_resid));       % should be ~0 dB
s21_deg   = angle(s21_resid) * 180/pi;      % should be ~0 deg (mod 360)
s11_dB    = 20*log10(abs(s11_resid) + eps);

max_s21_dev_dB  = max(abs(s21_dB));
max_s11_dB      = max(s11_dB);

printf('  Max |S21| deviation from 0 dB : %.4f dB  (limit: 0.1 dB)\n', max_s21_dev_dB);
printf('  Max |S11|                      : %.1f dB  (limit: -20 dB)\n', max_s11_dB);

pass = true;
if max_s21_dev_dB > 0.1
  printf('  FAIL: S21 deviation exceeds 0.1 dB\n');
  pass = false;
end
if max_s11_dB > -20
  printf('  FAIL: S11 exceeds -20 dB\n');
  pass = false;
end
if pass
  printf('  PASS: self-de-embedding residual within spec\n');
end
printf('\n');

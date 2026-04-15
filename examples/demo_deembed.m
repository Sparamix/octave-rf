%% demo_deembed.m  -- De-embedding demo for octave-rf
%%
%% Demonstrates the IEEE P370 NZC de-embedding workflow:
%%   1. Load a 2xThru measurement  -> extract fixture error boxes (NZC method)
%%   2. Load a FIX-DUT-FIX cascade -> de-embed to recover the DUT
%%   3. Compare against the known ground-truth DUT
%%
%% Run from the octave-rf/examples/ directory:
%%
%%   cd octave-rf/examples
%%   octave-cli --no-gui -q demo_deembed.m
%%
%% Requires: octave-rf package (inst/ directory on path) + fromtouchn.m
%%           IEEE P370 TG1 functions: IEEEP3702xThru_Octave.m
%%
%% References:
%%   Pupalaikis, P.J., "S-Parameters for Signal Integrity", CUP 2020. Ch.10.
%%   Resso & Bogatin, "Signal Integrity Characterization Techniques", 2018. Ch.5.
%%   IEEE P370 TG1: IEEEP3702xThru_Octave.m

%% --- Setup paths -----------------------------------------------------------
this_dir = fileparts (mfilename ('fullpath'));
addpath (fullfile (this_dir, '..', 'inst'));   %% octave-rf functions
addpath (this_dir);                            %% fromtouchn.m

%% Suppress Octave compatibility warnings from legacy code in fromtouchn.m
warning ('off', 'all');

%% --- Load Touchstone files ------------------------------------------------
printf ('Loading IEEE P370 case_01 files...\n');
[freq_2x, S_2xthru, ~]  = fromtouchn (fullfile (this_dir, 'case_01_2xThru.s2p'));
[freq_fd, S_fdf, ~]      = fromtouchn (fullfile (this_dir, 'case_01_F-DUT1-F.s2p'));
[freq_dut, S_dut_gt, ~]  = fromtouchn (fullfile (this_dir, 'case_01_DUT1.s2p'));
[~,        S_fixL, ~]    = fromtouchn (fullfile (this_dir, 'case_01_fixL.s2p'));

printf ('  2xThru:      %d points,  %.0f Hz - %.3f GHz\n', ...
        length(freq_2x), freq_2x(1), freq_2x(end)/1e9);
printf ('  FIX-DUT-FIX: %d points\n', length(freq_fd));
printf ('  Ground-truth DUT: %d points\n', length(freq_dut));

%% --- Method 1: Pre-extracted fixtures (case_01_fixL as reference) ----------
printf ('\n--- Method 1: De-embed using pre-extracted fixture (case_01_fixL) ---\n');
printf ('  (This fixture was extracted by Octave NZC from case_01_2xThru)\n');

%% For a symmetric 2xThru, side1 = fixL and side2 = fixL (mirrored)
%% Mirror the left fixture: swap ports for side2 (port-reversal convention)
S_fixR = snp2smp (S_fixL, [2 1]);   %% port-reversed right side

S_dut_deembed = deembedsparams (S_fdf, S_fixL, S_fixR);

err_vs_gt = max (abs (S_dut_deembed(:) - S_dut_gt(:)));
printf ('  De-embedded DUT vs ground truth:  max|diff| = %.2e\n', err_vs_gt);
printf ('  |S21| at 1 GHz:  DUT = %.4f,  De-embedded = %.4f\n', ...
        abs(S_dut_gt(2,1,100)), abs(S_dut_deembed(2,1,100)));

%% --- Method 2: Cascade then de-embed (round-trip identity check) ----------
printf ('\n--- Method 2: Embed then de-embed (identity round-trip) ---\n');

K = size (S_dut_gt, 3);
thru = zeros (2, 2, K);
thru(1,2,:) = 1;
thru(2,1,:) = 1;   %% ideal through: S12=S21=1, S11=S22=0

S_embedded = embedsparams (S_dut_gt, thru, thru);
S_recovered = deembedsparams (S_embedded, thru, thru);
err_rt = max (abs (S_recovered(:) - S_dut_gt(:)));
printf ('  Embed then de-embed with ideal thru:  max|diff| = %.2e\n', err_rt);

%% --- Cascade two identical sections ----------------------------------------
printf ('\n--- Cascade: two identical 2xThru sections ---\n');
S_double = cascadesparams (S_2xthru, S_2xthru);
printf ('  |S11| at 1 GHz (single):  %.4f\n', abs(S_2xthru(1,1,100)));
printf ('  |S11| at 1 GHz (double):  %.4f\n', abs(S_double(1,1,100)));
printf ('  |S21| at 1 GHz (single):  %.4f  (%.2f dB)\n', ...
        abs(S_2xthru(2,1,100)), 20*log10(abs(S_2xthru(2,1,100))));
printf ('  |S21| at 1 GHz (double):  %.4f  (%.2f dB)\n', ...
        abs(S_double(2,1,100)), 20*log10(abs(S_double(2,1,100))));

printf ('\nDemo complete. IEEE P370 NZC de-embedding workflow demonstrated.\n');
printf ('References: Pupalaikis 2020, Ch.10; Resso & Bogatin 2018, Ch.5.\n');

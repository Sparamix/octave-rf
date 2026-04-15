%% demo_mixed_mode.m  -- Mixed-mode S-parameter demo for octave-rf
%%
%% Demonstrates mixed-mode (differential/common-mode) analysis of a
%% 4-port differential cable measurement (CABLE1_RX_pair.s4p).
%%
%% Mixed-mode parameters decompose single-ended S-parameters into:
%%   Sdd -- differential-to-differential (signal integrity metric)
%%   Scc -- common-mode-to-common-mode (EMI/noise coupling metric)
%%   Sdc -- differential-to-common (mode conversion)
%%   Scd -- common-to-differential (mode conversion)
%%
%% Port convention used: adjacent pairs
%%   Pair 1 = ports 1,2  (e.g., positive and negative of differential pair)
%%   Pair 2 = ports 3,4
%%
%% Run from the octave-rf/examples/ directory:
%%
%%   cd octave-rf/examples
%%   octave-cli --no-gui -q demo_mixed_mode.m
%%
%% Requires: octave-rf package (inst/ directory on path) + fromtouchn.m
%%
%% References:
%%   Pupalaikis, P.J., "S-Parameters for Signal Integrity", CUP 2020. Ch.8.
%%   Hall, S.H. & Heck, H.L., "Advanced Signal Integrity", Wiley 2009. Ch.8.

%% --- Setup paths -----------------------------------------------------------
this_dir = fileparts (mfilename ('fullpath'));
addpath (fullfile (this_dir, '..', 'inst'));   %% octave-rf functions
addpath (this_dir);                            %% fromtouchn.m

%% Suppress Octave compatibility warnings from legacy code in fromtouchn.m
warning ('off', 'all');

%% --- Load 4-port S-parameters ---------------------------------------------
printf ('Loading CABLE1_RX_pair.s4p (6401 frequency points)...\n');
[freq, S4, npts] = fromtouchn (fullfile (this_dir, 'CABLE1_RX_pair.s4p'));
printf ('  Loaded %d frequency points, %d-port\n', npts, size(S4,1));
printf ('  Frequency range: %.3f MHz - %.3f GHz\n\n', ...
        freq(1)/1e6, freq(end)/1e9);

%% --- Port-order convention ------------------------------------------------
%% portorder = [1,2,3,4]: adjacent pairs
%%   Differential pair 1: ports 1(+) and 2(-)
%%   Differential pair 2: ports 3(+) and 4(-)
portorder = [1 2 3 4];

%% --- Convert to mixed-mode S-parameters -----------------------------------
printf ('--- Mixed-mode conversion (s2smm) ---\n');
Smm = s2smm (S4, portorder);
printf ('  Full 4x4 mixed-mode matrix computed.\n');
printf ('  Layout:  [Sdd  Sdc]\n');
printf ('           [Scd  Scc]\n\n');

%% Extract sub-blocks
Sdd = Smm(1:2, 1:2, :);   %% differential-mode S-parameters
Scc = Smm(3:4, 3:4, :);   %% common-mode S-parameters
Sdc = Smm(3:4, 1:2, :);   %% differential -> common (mode conversion)
Scd = Smm(1:2, 3:4, :);   %% common -> differential (mode conversion)

%% --- Also use dedicated sub-block functions --------------------------------
Sdd2 = s2sdd (S4, portorder);
Scc2 = s2scc (S4, portorder);

err_dd = max (abs (Sdd2(:) - Sdd(:)));
err_cc = max (abs (Scc2(:) - Scc(:)));
printf ('--- s2sdd / s2scc consistency with s2smm ---\n');
printf ('  Sdd block:  max|diff| = %.2e  (should be ~0)\n', err_dd);
printf ('  Scc block:  max|diff| = %.2e  (should be ~0)\n\n', err_cc);

%% --- Key signal integrity metrics -----------------------------------------
%% Find index near 1 GHz
[~, idx1G] = min (abs (freq - 1e9));
[~, idx5G] = min (abs (freq - 5e9));

printf ('--- Key metrics ---\n');
printf ('  Insertion loss (Sdd21) at 1 GHz:  %.2f dB\n', ...
        20*log10(abs(Sdd(2,1,idx1G))));
printf ('  Insertion loss (Sdd21) at 5 GHz:  %.2f dB\n', ...
        20*log10(abs(Sdd(2,1,idx5G))));
printf ('  Return loss    (Sdd11) at 1 GHz:  %.2f dB\n', ...
        20*log10(abs(Sdd(1,1,idx1G))));
printf ('  Mode conversion (Scd21) at 1 GHz: %.2f dB\n', ...
        20*log10(abs(Scd(2,1,idx1G))));
printf ('  Common-mode IL (Scc21) at 1 GHz:  %.2f dB\n\n', ...
        20*log10(abs(Scc(2,1,idx1G))));

%% --- Round-trip: smm2s recovers original S4 --------------------------------
printf ('--- Round-trip smm2s (mixed-mode -> single-ended) ---\n');
S4_rt = smm2s (Smm(1:2,1:2,:), Smm(1:2,3:4,:), ...
               Smm(3:4,1:2,:), Smm(3:4,3:4,:), portorder);
err_rt = max (abs (S4_rt(:) - S4(:)));
printf ('  smm2s round-trip:  max|diff| = %.2e  (should be ~machine epsilon)\n\n', err_rt);

%% --- Z and Y parameters for 4-port network --------------------------------
printf ('--- 4-port Z / Y parameters ---\n');
Z4 = s2z (S4);
Y4 = s2y (S4);
S4_from_Z = z2s (Z4);
S4_from_Y = y2s (Y4);
err_z = max (abs (S4_from_Z(:) - S4(:)));
err_y = max (abs (S4_from_Y(:) - S4(:)));
printf ('  s2z/z2s round-trip:  max|diff| = %.2e\n', err_z);
printf ('  s2y/y2s round-trip:  max|diff| = %.2e\n\n', err_y);

printf ('Demo complete. Mixed-mode analysis of 4-port differential cable.\n');
printf ('References: Pupalaikis 2020, Ch.8; Hall & Heck 2009, Ch.8.\n');

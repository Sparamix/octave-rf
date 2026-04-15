%% demo_basic_conversions.m  -- Parameter conversion demo for octave-rf
%%
%% Demonstrates S-parameter conversions on a real PCB stripline measurement.
%% Run from the octave-rf/examples/ directory:
%%
%%   cd octave-rf/examples
%%   octave-cli --no-gui -q demo_basic_conversions.m
%%
%% Requires: octave-rf package (inst/ directory on path) + fromtouchn.m
%%
%% Reference: Pupalaikis, P.J., "S-Parameters for Signal Integrity",
%%            Cambridge University Press, 2020. Chapters 3-4.

%% --- Setup paths -----------------------------------------------------------
this_dir = fileparts (mfilename ('fullpath'));
addpath (fullfile (this_dir, '..', 'inst'));   %% octave-rf functions
addpath (this_dir);                            %% fromtouchn.m

%% Suppress Octave compatibility warnings from legacy code in fromtouchn.m
warning ('off', 'all');

%% --- Load 2-port S-parameters ---------------------------------------------
printf ('Loading pcb_stripline_119mm.s2p (7000 frequency points, DC-35 GHz)...\n');
[freq, S, npts] = fromtouchn (fullfile (this_dir, 'pcb_stripline_119mm.s2p'));
printf ('  Loaded %d frequency points, %d-port\n', npts, size(S,1));

%% Wrap in sparameters object (optional — adds metadata)
z0 = 50;
s50 = sparameters (S, freq, z0);
printf ('  sparameters object: %d-port, Z0 = %g Ohm\n\n', size(s50.Parameters,1), z0);

%% --- T-matrix (wave-cascade matrix) ----------------------------------------
printf ('--- T-matrix (s2t / t2s) ---\n');
T = s2t (S);
S_rt = t2s (T);
err = max (abs (S_rt(:) - S(:)));
printf ('  Round-trip S -> T -> S:  max|diff| = %.2e\n\n', err);

%% --- Impedance parameters (Z) ----------------------------------------------
printf ('--- Z-parameters (s2z / z2s) ---\n');
Z = s2z (S);
printf ('  Z11 at 1 GHz:  %.3f + %.3fj Ohm\n', real(Z(1,1,100)), imag(Z(1,1,100)));
S_rt = z2s (Z);
err = max (abs (S_rt(:) - S(:)));
printf ('  Round-trip S -> Z -> S:  max|diff| = %.2e\n\n', err);

%% --- Admittance parameters (Y) ---------------------------------------------
printf ('--- Y-parameters (s2y / y2s) ---\n');
Y = s2y (S);
printf ('  Y11 at 1 GHz:  %.6f + %.6fj S\n', real(Y(1,1,100)), imag(Y(1,1,100)));
S_rt = y2s (Y);
err = max (abs (S_rt(:) - S(:)));
printf ('  Round-trip S -> Y -> S:  max|diff| = %.2e\n\n', err);

%% --- ABCD parameters -------------------------------------------------------
printf ('--- ABCD-parameters (s2abcd / abcd2s) ---\n');
A = s2abcd (S);
printf ('  A11 at 1 GHz:  %.6f + %.6fj\n', real(A(1,1,100)), imag(A(1,1,100)));
S_rt = abcd2s (A);
err = max (abs (S_rt(:) - S(:)));
printf ('  Round-trip S -> ABCD -> S:  max|diff| = %.2e\n\n', err);

%% --- H-parameters (hybrid) -------------------------------------------------
printf ('--- H-parameters (s2h / h2s) ---\n');
H = s2h (S);
S_rt = h2s (H);
err = max (abs (S_rt(:) - S(:)));
printf ('  Round-trip S -> H -> S:  max|diff| = %.2e\n\n', err);

%% --- G-parameters (inverse hybrid) ----------------------------------------
printf ('--- G-parameters (s2g / g2s) ---\n');
G = s2g (S);
S_rt = g2s (G);
err = max (abs (S_rt(:) - S(:)));
printf ('  Round-trip S -> G -> S:  max|diff| = %.2e\n', err);
printf ('  Note: G = inv(H); near resonances H is ill-conditioned,\n');
printf ('        so G vs reference may reach ~1e-10 -- this is expected.\n\n');

%% --- Renormalization -------------------------------------------------------
printf ('--- Renormalization (renormsparams) ---\n');
S75  = renormsparams (S, 75, 50);      %% renormalize to 75 Ohm
S_rt = renormsparams (S75, 50, 75);   %% back to 50 Ohm
err = max (abs (S_rt(:) - S(:)));
printf ('  50->75->50 Ohm round-trip:  max|diff| = %.2e\n', err);
printf ('  |S21| at 1 GHz:  50 Ohm = %.4f,  75 Ohm = %.4f\n\n', ...
        abs(S(2,1,100)), abs(S75(2,1,100)));

%% Also demonstrate sparameters Form 3 (renormalize via object)
s75 = sparameters (s50, 75);
printf ('  sparameters Form 3:  Z0 = 75 Ohm,  |S21| at 1 GHz = %.4f\n\n', ...
        abs(s75.Parameters(2,1,100)));

%% --- Port reordering -------------------------------------------------------
printf ('--- Port reordering (snp2smp) ---\n');
S_swapped  = snp2smp (S, [2 1]);   %% swap port 1 and port 2
S_restored = snp2smp (S_swapped, [2 1]);
err = max (abs (S_restored(:) - S(:)));
printf ('  Swap [2,1] then swap back:  max|diff| = %.2e  (pure permutation -- exact)\n\n', err);

printf ('Demo complete. All conversions demonstrated on real PCB data.\n');
printf ('Reference: Pupalaikis 2020, Chapters 3-4; Hall & Heck 2009, Chapters 3-4.\n');

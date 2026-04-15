# octave-rf

**RF and microwave network parameter utilities for GNU Octave.**

This is the **first RF/microwave engineering package for GNU Octave** — providing
S-parameter conversions and network operations that were previously only available
in MATLAB's proprietary RF Toolbox.

[![Octave Tests](https://github.com/OpenSNPTools/octave-rf/actions/workflows/test.yml/badge.svg)](https://github.com/OpenSNPTools/octave-rf/actions)
[![License: BSD-3-Clause](https://img.shields.io/badge/License-BSD_3--Clause-blue.svg)](LICENSE)

---

## Why This Exists

The [IEEE P370](https://opensource.ieee.org/elec-char/ieee-370/) open-source
de-embedding code depends on MATLAB RF Toolbox functions (`sparameters`,
`rfparam`, `cascadesparams`, `deembedsparams`, `s2t`, `t2s`, `s2abcd`, `abcd2s`,
`s2sdd`, `s2scc`, `smm2s`, etc.). None of these exist in GNU Octave.

**This package fills that gap.** With `pkg load rf`, the IEEE P370 NZC de-embedding
workflow (`IEEEP3702xThru_Octave.m` → `deembedsparams`) runs in Octave without
modification and without a MATLAB license.

---

## Installation

```octave
pkg install https://github.com/OpenSNPTools/octave-rf/releases/download/v0.1.0/rf-0.1.0.tar.gz
pkg load rf
```

Or from a local clone:

```octave
pkg install /path/to/octave-rf/
pkg load rf
```

**Requirements**: GNU Octave ≥ 6.0.0. No additional dependencies.

---

## Quick Start

```octave
pkg load rf

%% --- Parameter conversions ---
f = (1e9:1e9:10e9).';          % frequency vector, 1-10 GHz
S = zeros(2, 2, 10);
S(1,2,:) = 0.9;  S(2,1,:) = 0.9;  S(1,1,:) = 0.05;  S(2,2,:) = 0.05;

T    = s2t(S);            % S → T (chain scattering)
Z    = s2z(S);            % S → Z
Y    = s2y(S);            % S → Y
A    = s2abcd(S);         % S → ABCD
S_rt = t2s(T);            % T → S (round-trip to machine epsilon)

%% --- Cascade two 2-port networks ---
S_double = cascadesparams(S, S);

%% --- Renormalization ---
S75 = renormsparams(S, 75, 50);   % 50 Ω → 75 Ω

%% --- Mixed-mode (differential/common-mode) ---
S4 = rand(4, 4, 10) * 0.1;        % 4-port S-parameters
Smm = s2smm(S4, [1 2 3 4]);       % adjacent-pair convention
Sdd = s2sdd(S4, [1 2 3 4]);       % differential insertion/return loss
Scc = s2scc(S4, [1 2 3 4]);       % common-mode parameters

%% --- sparameters object ---
s50 = sparameters(S, f);           % wrap in object
s75 = sparameters(s50, 75);        % Form 3: renormalize object
s21 = rfparam(s50, 2, 1);          % extract S21 column vector
```

---

## IEEE P370 De-Embedding

```octave
pkg load rf
addpath('/path/to/ieee-370/TG1');   % IEEE P370 repository

%% Load Touchstone files (using fromtouchn from examples/, or any reader)
addpath('/path/to/octave-rf/examples');
[freq, S_2x]  = fromtouchn('case_01_2xThru.s2p');
[~,    S_fdf] = fromtouchn('case_01_F-DUT1-F.s2p');

%% Extract fixtures using IEEE P370 NZC algorithm
[fix1, fix2] = IEEEP3702xThru_Octave(S_2x, freq);

%% De-embed the DUT: T_DUT = inv(T_fix1) · T_FDF · inv(T_fix2)
S_dut = deembedsparams(S_fdf, fix1, fix2);
```

For runnable demos with bundled S-parameter files, see the `examples/` directory:

```bash
cd octave-rf/examples
octave --no-gui -q demo_basic_conversions.m
octave --no-gui -q demo_deembed.m
octave --no-gui -q demo_mixed_mode.m
```

---

## Function Reference

### S-Parameter Objects
| Function | Description |
|----------|-------------|
| `sparameters(P, f)` | Create S-parameter object from NxNxK array and frequency vector |
| `sparameters(P, f, z0)` | Create object with reference impedance z0 (renorm if z0 ≠ 50) |
| `sparameters(s, z0_new)` | Renormalize existing object to new reference impedance |
| `rfparam(s, i, j)` | Extract S(i,j) as a column vector across all frequencies |

### Chain Scattering (T) Parameters
| Function | Description |
|----------|-------------|
| `s2t(S)` | S-parameters → T-parameters (Convention A: T_cascade = T1·T2) |
| `t2s(T)` | T-parameters → S-parameters |

### Network Operations
| Function | Description |
|----------|-------------|
| `cascadesparams(S1, S2)` | Cascade two 2-port networks via T-matrix multiplication |
| `deembedsparams(S_meas, S_fix1, S_fix2)` | De-embed fixtures: T_DUT = inv(T1)·T_meas·inv(T2) |
| `embedsparams(S_dut, S_fix1, S_fix2)` | Embed fixtures: T_meas = T1·T_dut·T2 |

### Parameter Conversions (2-port and N-port)
| Function | Description |
|----------|-------------|
| `s2z(S)` / `z2s(Z)` | S ↔ Impedance parameters |
| `s2y(S)` / `y2s(Y)` | S ↔ Admittance parameters |
| `s2abcd(S)` / `abcd2s(A)` | S ↔ ABCD (chain/transmission) parameters |
| `s2h(S)` / `h2s(H)` | S ↔ Hybrid H-parameters |
| `s2g(S)` / `g2s(G)` | S ↔ Inverse hybrid G-parameters |

### Mixed-Mode (Differential/Common-Mode)
| Function | Description |
|----------|-------------|
| `s2smm(S4, portorder)` | Single-ended 4×4 → mixed-mode 4×4 (Sdd, Sdc, Scd, Scc blocks) |
| `s2sdd(S4, portorder)` | Extract Sdd (differential) block |
| `s2scc(S4, portorder)` | Extract Scc (common-mode) block |
| `smm2s(Sdd, Sdc, Scd, Scc, portorder)` | Mixed-mode blocks → single-ended 4×4 |

Port convention: `portorder=[1,2,3,4]` = adjacent pairs (pair1: ports 1,2; pair2: ports 3,4).
Matches MATLAB RF Toolbox `se2gmm(p=2)` and scikit-rf `se2gmm(p=2)`.

### Port Operations
| Function | Description |
|----------|-------------|
| `snp2smp(S, order)` | Reorder ports of N-port S-matrix (pure index permutation) |
| `renormsparams(S, z0_new, z0_old)` | Renormalize S-parameters between reference impedances |

### Octave Compatibility Shim
| Function | Description |
|----------|-------------|
| `ifft_symmetric(x)` | Equivalent of MATLAB's `ifft(x, 'symmetric')` — forces real output |

---

## Validation

All 24 functions cross-validated against [scikit-rf 1.11.0](https://scikit-rf.readthedocs.io)
and the [sparamix.py370](https://github.com/OpenSNPTools/sparamix-py370) Python reference
implementation.

| Group | Functions | max abs(Diff) | vs. Reference |
|-------|-----------|--------------|---------------|
| S↔T (2-port) | s2t, t2s | 5.0e-15 | scikit-rf |
| S↔Z (2-port) | s2z, z2s | 4.3e-13 | scikit-rf |
| S↔Y (2-port) | s2y, y2s | 8.5e-16 | scikit-rf |
| S↔ABCD | s2abcd, abcd2s | 3.5e-13 | scikit-rf |
| S↔H | s2h, h2s | 1.3e-12 | derived from Z |
| S↔G | s2g, g2s | 9.5e-11 | inv(H) — inversion amplification† |
| S↔Z/Y (4-port) | s2z, z2s, s2y, y2s | 1.6e-12 | scikit-rf |
| Cascade | cascadesparams | 4.5e-15 | scikit-rf |
| De-embedding | deembedsparams | 1.9e-13 | py370 + scikit-rf |
| Renormalization | renormsparams | 2.0e-15 | scikit-rf |
| Mixed-mode | s2smm, s2sdd, s2scc, smm2s | 3.7e-16 | scikit-rf |
| Port reorder | snp2smp | 0.0 (exact) | — |

†G = inv(H) amplifies condition number at network resonances; round-trip g2s(s2g(S)) = 3.8e-15.

**Built-in self-tests**: 81 tests across 24 functions, 0 failures.

```octave
pkg load rf
pkg test rf
```

---

## Examples and Test Data

The `examples/` directory contains:

- **`demo_basic_conversions.m`** — all parameter conversions on a real PCB stripline
- **`demo_deembed.m`** — IEEE P370 NZC de-embedding with case_01 files
- **`demo_mixed_mode.m`** — mixed-mode analysis of a 4-port differential cable
- **`fromtouchn.m`** — Touchstone reader (from IEEE P370 TG3, BSD-3-Clause)
- **8 Touchstone files** — real PCB measurements and IEEE P370 TG1 synthetic data

---

## Mathematical Basis

All functions are implemented from published mathematical definitions.
No proprietary source code was used or referenced.

| Reference | Used For |
|-----------|---------|
| Pupalaikis, P.J., *S-Parameters for Signal Integrity*, Cambridge UP, 2020 | All functions (primary reference) |
| Pozar, D.M., *Microwave Engineering*, 4th ed., Wiley, 2012 | S↔Z, S↔Y, S↔ABCD, S↔T conversions |
| Hall, S.H. & Heck, H.L., *Advanced Signal Integrity*, Wiley, 2009 | T-parameters, mixed-mode |
| Resso & Bogatin, *Signal Integrity Characterization Techniques*, IEC, 2009 | De-embedding, ABCD |
| Balanis, C.A., *Advanced Engineering Electromagnetics*, 2nd ed., Wiley, 2012 | Z, Y parameters |

See `doc/REFERENCES.md` for the complete function-by-function reference map.

---

## Related Projects

- **[sparamix.py370](https://github.com/OpenSNPTools/sparamix-py370)** — companion Python implementation of the IEEE P370 reference algorithms. octave-rf was developed alongside it for cross-validation.
- **[IEEE P370](https://opensource.ieee.org/elec-char/ieee-370/)** — IEEE standard for S-parameter characterization of PCB interconnects at frequencies up to 50 GHz.
- **[scikit-rf](https://scikit-rf.readthedocs.io)** — Python RF engineering library used for cross-validation.

---

## License

BSD-3-Clause — see [COPYING](COPYING).

Copyright © 2026 Giorgi Maghlakelidze / OpenSNPTools contributors.

---

## Citation

If you use this package in academic work, please cite:

```bibtex
@misc{octave-rf-2026,
  author       = {Maghlakelidze, Giorgi},
  title        = {octave-rf: RF and Microwave Network Parameter Utilities for GNU Octave},
  year         = {2026},
  publisher    = {GitHub},
  url          = {https://github.com/OpenSNPTools/octave-rf}
}
```

# octave-rf Package — Textbook Reference Guide

This document maps every function in the `octave-rf` package to the textbook(s) from which
its mathematical basis is drawn.  All citations have been verified against the physical
books (2026-04-15).  Each reference includes the specific chapter, section, equation
number, and page number where applicable.

---

## Available References

| Tag | Full Citation |
|-----|---------------|
| **[PUP]** | Pupalaikis, P.J., *S-Parameters for Signal Integrity*, Cambridge University Press, 2020. ISBN 978-1-108-48996-6. |
| **[POZ]** | Pozar, D.M., *Microwave Engineering*, 4th ed., Wiley, 2012. ISBN 978-0-470-63155-3. |
| **[H&H]** | Hall, S.H. and Heck, H.L., *Advanced Signal Integrity for High-Speed Digital Designs*, Wiley-IEEE Press, 2009. ISBN 978-0-470-19235-1. |
| **[BOG]** | Bogatin, E., *Signal Integrity Simplified*, 3rd ed., Pearson, 2018. |
| **[RES]** | Resso, M. and Bogatin, E., *Signal Integrity Characterization Techniques*, IEC, 2009. |
| **[BAL]** | Balanis, C.A., *Advanced Engineering Electromagnetics*, 2nd ed., Wiley, 2012. |

All Pozar, Pupalaikis, and Hall & Heck citations below have been **verified** against the
books (page numbers given).  The Bogatin, Resso, and Balanis citations are supporting
references for SI-practitioner perspective.

---

## Function Reference Map

### S-Parameter Objects

| Function | Primary | Secondary | Formulas / Sections |
|----------|---------|-----------|---------------------|
| `sparameters` | [PUP] Ch. 5 §5.1 (p.134) | [POZ] §4.3 Eq. 4.44–4.45 (p.181); [H&H] §9.2.6 (p.399) | Constructor; Form 3 renormalization via Z: `Z = z0_old*(I+S)*inv(I-S)`, `S_new = (Z-z0_new*I)*inv(Z+z0_new*I)` |
| `rfparam` | — | — | Pure index extraction `S(i,j,k)`; no textbook reference needed |

---

### T-Matrix (Transfer Scattering Parameters) — Convention A

Convention A (MATLAB RF Toolbox / Pupalaikis): cascade property is `T_total = T_left * T_right`.

| Function | Primary | Secondary | Formulas / Sections |
|----------|---------|-----------|---------------------|
| `s2t` | [PUP] §3.6 Eq. 3.31–3.32 (p.68) | [H&H] §9.2.4 (p.390) | `T = (1/S21) * [-det(S), S11; -S22, 1]` |
| `t2s` | [PUP] §3.6 Eq. 3.33–3.34 (p.68) | [H&H] §9.2.4 (p.390) | `S = (1/T22) * [T12, det(T); 1, -T21]` |

**NOTE**: Pozar's *Microwave Engineering* 4th ed. does **not** cover chain scattering
T-parameters.  Pozar §4.4 Eq. 4.54–4.55 describe **reference plane shifts** — a
different concept.  No Pozar citation is given for s2t/t2s.

---

### Network Operations

| Function | Primary | Secondary | Formulas / Sections |
|----------|---------|-----------|---------------------|
| `cascadesparams` | [PUP] §3.7 Eq. 3.35 (p.69); Ch. 10 (p.282) | [POZ] §4.4 Eq. 4.71 (p.189) — ABCD cascade (analogous); [H&H] §9.2.4 (p.390); [RES] | `T_total = T_1 * T_2 * ... * T_N`; S converted via `s2t`/`t2s` per frequency |
| `deembedsparams` | [PUP] §3.8–3.9 (p.69–70); Ch. 10 (p.282) | [H&H] §9.2.5 (p.395); [RES] | `T_DUT = inv(T_f1) * T_m * inv(T_f2)` (implemented as `T_f1 \ T_m / T_f2` for numerical stability) |
| `embedsparams` | [PUP] §3.7 (p.69); Ch. 10 (p.282) | [H&H] §9.2.4 (p.390) | `T_result = T_f1 * T_DUT * T_f2`; thin wrapper around `cascadesparams(f1, dut, f2)` |

Note: Pozar §4.4 Eq. 4.71 shows the analogous ABCD cascade property
`[ABCD]_cascade = [ABCD]_1 * [ABCD]_2`.  T-parameters cascade the same way;
Pozar's book does not present T-parameters explicitly but the cascade property is
directly analogous.

---

### Z-Parameters (Impedance)

| Function | Primary | Secondary | Formulas / Sections |
|----------|---------|-----------|---------------------|
| `s2z` | [PUP] §3.4.2 Table 3.3 (p.56) | [POZ] §4.3 Eq. 4.45 (p.181); Table 4.2 (p.192); [H&H] §9.2.1 (p.355); [BAL] Ch. 10 | `Z = z0 * (I + S) * inv(I - S)` (N-port, uniform Z0) |
| `z2s` | [PUP] §3.4.1 Table 3.2 Eq. 3.16 (p.55) | [POZ] §4.3 Eq. 4.44 (p.181); Table 4.2 (p.192); [H&H] §9.2.1 (p.355) | `S = (Z - z0*I) * inv(Z + z0*I)` (N-port, uniform Z0) |

Pozar Eq. 4.44/4.45 are the **normalized** forms (Z0=1).  Table 4.2 (p.192) gives
the 2-port case with explicit Z0, which reduces to the implementation here.

---

### Y-Parameters (Admittance)

| Function | Primary | Secondary | Formulas / Sections |
|----------|---------|-----------|---------------------|
| `s2y` | [PUP] §3.4.4 Table 3.5 (p.59) | [POZ] §4.2 Eq. 4.26–4.27 (p.175); Table 4.2 (p.192); [H&H] §9.2.1 (p.355) | `Y = (1/z0) * (I - S) * inv(I + S)` (N-port, uniform Z0) |
| `y2s` | [PUP] §3.4.3 Table 3.4 Eq. 3.18 (p.57) | [POZ] §4.2 Eq. 4.26–4.27 (p.175); Table 4.2 (p.192); [H&H] §9.2.1 (p.355) | `S = (I - z0*Y) * inv(I + z0*Y)` (N-port, uniform Z0) |

---

### ABCD-Parameters (Chain / Transmission)

Valid for 2-port networks only.  Let `d = 2 * S21`.

| Function | Primary | Secondary | Formulas / Sections |
|----------|---------|-----------|---------------------|
| `s2abcd` | [PUP] §3.4.6 Table 3.7 (p.61) | [POZ] §4.4 Eq. 4.69 (p.189); Table 4.2 (p.192); [H&H] §9.2.3 (p.382); [RES] | `A = ((1+S11)(1-S22)+S12*S21)/d`, `B = z0*((1+S11)(1+S22)-S12*S21)/d`, `C = ((1-S11)(1-S22)-S12*S21)/(z0*d)`, `D = ((1-S11)(1+S22)+S12*S21)/d` |
| `abcd2s` | [PUP] §3.4.5 Table 3.6 Eq. 3.20 (p.60) | [POZ] §4.4 Eq. 4.69 (p.189); Table 4.2 (p.192); [H&H] §9.2.3 (p.382); [RES] | `denom = A + B/z0 + C*z0 + D`; `S11 = (A+B/z0-C*z0-D)/denom`, `S12 = 2*det(ABCD)/denom`, `S21 = 2/denom`, `S22 = (-A+B/z0-C*z0+D)/denom` |

[BOG] covers ABCD intuitively in the context of transmission-line cascades —
useful cross-reference for sign conventions and typical signal-integrity applications.

---

### H-Parameters (Hybrid) and G-Parameters (Inverse Hybrid)

Valid for 2-port networks only.  Computed via Z as intermediate.

| Function | Primary | Secondary | Formulas / Sections |
|----------|---------|-----------|---------------------|
| `s2h` | [PUP] Ch. 1 §1.2 (p.16) | [BOG] | Via Z: `H11 = det(Z)/Z22`, `H12 = Z12/Z22`, `H21 = -Z21/Z22`, `H22 = 1/Z22` |
| `h2s` | [PUP] Ch. 1 §1.2 (p.16) | [BOG] | Via Z: `Z11 = det(H)/H22`, `Z12 = H12/H22`, `Z21 = -H21/H22`, `Z22 = 1/H22`; then `z2s` |
| `s2g` | [PUP] Ch. 1 §1.2 (p.16) | [BOG] | `G = inv(H)` per frequency slice: `G11=H22/det(H)`, `G12=-H12/det(H)`, `G21=-H21/det(H)`, `G22=H11/det(H)` |
| `g2s` | [PUP] Ch. 1 §1.2 (p.16) | [BOG] | `H = inv(G)` per frequency slice; then `h2s` |

**IMPORTANT**: Pozar *Microwave Engineering* 4th ed. Table 4.2 (p.192) covers only
S, Z, Y, and ABCD parameters — it does **not** include H or G parameters.  Pozar
mentions hybrid parameters exist but provides no S↔H or S↔G formulas.  The
implementation uses Z-parameters as an intermediate (see s2z/z2s refs above).

[BOG] Chapter "S-Parameters and Other Parameter Sets" provides SI-practitioner
perspective on H-parameters and their use in transistor models.

---

### Mixed-Mode S-Parameters

Valid for 4-port networks with differential-pair topology.  `portorder = [D+1, D-1, D+2, D-2]`.

Mode transformation matrix (Convention: Pupalaikis / Hall & Heck — "standard mixed-mode
converter" with 1/sqrt(2) normalization, from [PUP] Eq. 7.24–7.27, p.197):
```
M = (1/sqrt(2)) * [ 1 -1  0  0 ]   ← differential pair 1
                  [ 0  0  1 -1 ]   ← differential pair 2
                  [ 1  1  0  0 ]   ← common-mode pair 1
                  [ 0  0  1  1 ]   ← common-mode pair 2
```
`S_mm = M * S_reordered * M'`  (where `M' = inv(M)` since M is unitary).

Output block ordering: `[Sdd Sdc; Scd Scc]` → rows/cols `[d1, d2, c1, c2]`.

| Function | Primary | Secondary | Formulas / Sections |
|----------|---------|-----------|---------------------|
| `s2sdd` | [PUP] §7.3 Eq. 7.24 (p.197); §7.3.2 (p.199) | [H&H] Ch. 7 (p.297); §9.2.7 (p.400) | Returns `S_mm(1:2, 1:2, :)` — differential block |
| `s2scc` | [PUP] §7.3 Eq. 7.25 (p.197); §7.3.2 (p.199) | [H&H] Ch. 7 (p.297); §9.2.7 (p.400) | Returns `S_mm(3:4, 3:4, :)` — common-mode block; Scc ref. impedance = z0/2 (25 Ω for 50 Ω system) |
| `s2smm` | [PUP] §7.3.2 Fig. 7.7–7.8 (p.197–198) | [H&H] Ch. 7 (p.297); §9.2.7 (p.400) | Full 4×4 mixed-mode matrix `[Sdd Sdc; Scd Scc]` |
| `smm2s` | [PUP] §7.3.2 (p.199) — inverse of Eq. 7.24–7.27 | [H&H] Ch. 7 (p.297); §9.2.7 (p.400) | Inverse: `S_reordered = M' * S_mm * M`; undo port permutation via inverse index map |

[PUP] §7.3.2 (p.199) explicitly defines the 4×4 mixed-mode matrix `[Sdd Sdc; Scd Scc]`
and each block's meaning (Sdd = differential propagation, Sdc = mode conversion, etc.).
[H&H] Ch. 7 (p.297) provides the SI-engineering perspective on differential signaling
and mode conversion; §9.2.7 (p.400) gives the formal multimode S-parameter derivation.

---

### Port Operations

| Function | Primary | Secondary | Formulas / Sections |
|----------|---------|-----------|---------------------|
| `snp2smp` | [PUP] §3.1 (p.41); §3.3 (p.46) | — | `S_out(i,j,:) = S(portorder(i), portorder(j), :)` — row/column permutation (standard linear algebra: `P*S*P^T`) |

---

### Renormalization

| Function | Primary | Secondary | Formulas / Sections |
|----------|---------|-----------|---------------------|
| `renormsparams` | [PUP] Ch. 5 §5.1 (p.134) | [POZ] §4.3 Eq. 4.44–4.45 (p.181); [H&H] §9.2.6 (p.399); [RES] | `Z = z0_old*(I+S)*inv(I-S)`; `S_new = (Z-z0_new*I)*inv(Z+z0_new*I)` |

Note: this is the **uniform reference impedance** case (scalar z0 for all ports).
For per-port renormalization with different impedances at each port, see [PUP]
Chapter 5 for the generalized bilinear transform.

---

### Compatibility Utilities

| Function | Purpose | Notes |
|----------|---------|-------|
| `ifft_symmetric` | Octave shim for `ifft(...,'symmetric')` | Implemented as `real(ifft(x))`. The `'symmetric'` option exists in MATLAB R2011b+, but is absent in Octave ≤ 11.1. No textbook reference needed — this is a pure compatibility shim. |

---

## Notes on Reference Impedance Conventions

All functions in this package default to **z0 = 50 Ω** (real, scalar) unless otherwise
specified, consistent with:
- [PUP] throughout (50 Ω is the standard SI reference)
- [RES] Section on measurement reference impedance
- IEEE P370 test files (all use 50 Ω single-ended reference)

Mixed-mode parameters carry different effective reference impedances:
- **Sdd**: differential reference = 2 × z0 (100 Ω for 50 Ω system)
- **Scc**: common-mode reference = z0/2 (25 Ω for 50 Ω system)

This is a consequence of the mode transformation matrix M with 1/sqrt(2) normalization,
documented in [PUP] §7.3 Eq. 7.24–7.27 (p.197) and [H&H] Ch. 7 (p.297).

---

## Using This Document

This file is part of the `octave-rf` package documentation and is intended to:
1. Guide users to primary references when they need to understand the mathematical basis
2. Document the verified textbook citations for the mathematical formulas in each function
3. Serve as supporting material for the IEEE EPEPS / EMC+SIPI publication

The recommended reading order for SI practitioners new to S-parameter network theory:
1. Bogatin [BOG] — intuitive introduction, SI context
2. Hall & Heck [H&H] — comprehensive SI treatment including mixed-mode
3. Resso [RES] — measurement-focused, characterization techniques
4. Pupalaikis [PUP] — rigorous mathematical treatment, primary reference for this package
5. Balanis [BAL] — electromagnetics background for advanced topics
6. Pozar [POZ] — microwave engineering, useful for cross-verification (note: does not
   cover T-parameters, H-parameters, or G-parameters)

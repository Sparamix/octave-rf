# octave-rf

S-parameter network utilities for GNU Octave.  Enables IEEE P370
de-embedding code to run independently in Octave while remaining
compatible with MATLAB RF Toolbox syntax.

**Status**: 🚧 Work in progress — not yet released as an installable package.

## Quick example

```octave
addpath ('inst');                          % or: pkg load rf (after install)

s = sparameters ('examples/case_01_2xThru.s2p');   % read Touchstone file
T = s2t (s.Parameters);                   % S -> T (chain scattering)
Z = s2z (s.Parameters, 50);               % S -> Z (impedance)
S21 = rfparam (s, 2, 1);                  % extract S21 column vector

sc = cascadesparams (s, s);               % cascade two networks
[Sdd, Sdc, Scd, Scc] = s2smm (s.Parameters);   % mixed-mode (4-port)
```

## Functions (26)

| Category | Functions |
|---|---|
| S-parameter object | `sparameters`, `rfparam` |
| T-parameters | `s2t`, `t2s` |
| Z / Y / ABCD / H / G | `s2z`, `z2s`, `s2y`, `y2s`, `s2abcd`, `abcd2s`, `s2h`, `h2s`, `s2g`, `g2s` |
| Cascade / de-embed | `cascadesparams`, `deembedsparams`, `embedsparams` |
| Mixed-mode | `s2smm`, `smm2s`, `s2sdd`, `s2scc` |
| Port reorder / renorm | `snp2smp`, `renormsparams` |
| I/O | `fromtouchn` (Touchstone reader), also via `sparameters(filename)` |
| Compatibility shims | `ifft_symmetric`, `round(x,n)` |

## MATLAB compatibility

Function signatures match MATLAB RF Toolbox — the same user code runs in
both environments.  See the
[MATLAB Compatibility Guide](doc/MATLAB_COMPATIBILITY_GUIDE.md) for the
full function-by-function comparison.

## Validation

Three-way cross-validated against MATLAB R2025b RF Toolbox and scikit-rf
1.11.0 — 108/108 pair-wise tests pass to floating-point precision.
See the [3-way report](doc/VALIDATION_REPORT_3WAY.md) and the
[MATLAB-only report](doc/VALIDATION_REPORT_MATLAB_R2025b.md).

## Tests

100 built-in self-tests, 0 failures:

```octave
addpath ('inst');
pkg test rf          % if installed as a package
% or: test ('s2t'); test ('s2z'); ...   % individual functions
```

## Documentation

- [MATLAB Compatibility Guide](doc/MATLAB_COMPATIBILITY_GUIDE.md)
- [Textbook References](doc/REFERENCES.md) — verified against Pozar, Pupalaikis, Hall & Heck
- [examples/](examples/) — runnable demos with real S-parameter data

## Requirements

GNU Octave >= 6.0.0.  No additional dependencies.

## :warning: AI-Assisted Development Disclosure

This project was developed with the assistance of **Claude Opus 4.6**
(Anthropic).  We believe in full transparency about AI involvement in
engineering work.

**We practice responsible vibe-coding.**  AI accelerates development, but
every function in this package goes through a rigorous verification and
validation protocol before it ships:

1. **Equation verification against textbooks** — every formula was checked
   against the physical books (Pozar, Pupalaikis, Hall & Heck) with exact
   page and equation numbers recorded in the source code and in
   [doc/REFERENCES.md](doc/REFERENCES.md).  This process caught and
   corrected several wrong citations that existed in the original
   documentation.

2. **Three-way cross-validation to floating-point precision** — every
   function is validated against MATLAB RF Toolbox and scikit-rf
   independently.  108/108 pair-wise comparisons pass.  This process
   caught a T-parameter convention mismatch that was fixed before
   release — proof that the validation protocol works.

3. **100 built-in self-tests (BIST)** — every function has inline tests
   that run on `pkg test rf`.  Tests cover known-answer values, round-trip
   identities, edge cases, and error paths.

4. **Clean-room implementation** — all code was written from published
   mathematical definitions in academic textbooks.  No proprietary MATLAB
   source code was referenced or reverse-engineered.

5. **Open to community scrutiny** — all validation reports, textbook
   references, and test infrastructure are included in the repository.
   We welcome independent verification, bug reports, and feedback via
   [GitHub Issues](https://github.com/Sparamix/octave-rf/issues).

The AI assisted with code generation, documentation, and the systematic
verification workflow.  The human author (a signal integrity engineer)
directed the architecture, reviewed every output, and made all
engineering decisions.  Every commit was reviewed before merging.

## License

BSD-3-Clause — see [COPYING](COPYING).

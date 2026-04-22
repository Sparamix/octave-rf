<p align="center">
  <img src="doc/icon.png" alt="octave-rf" width="150" height="150">
</p>

<h1 align="center">octave-rf</h1>

<p align="center">
  <a href="https://github.com/Sparamix/octave-rf/releases/latest"><img src="https://img.shields.io/github/v/release/Sparamix/octave-rf?label=release" alt="release"></a>
  <a href="COPYING"><img src="https://img.shields.io/badge/license-BSD--3--Clause-blue" alt="license"></a>
  <a href="https://github.com/Sparamix/octave-rf/actions/workflows/test.yml"><img src="https://github.com/Sparamix/octave-rf/actions/workflows/test.yml/badge.svg" alt="Octave BIST"></a>
</p>

S-parameter network utilities for GNU Octave.  Enables IEEE P370
de-embedding code to run independently in Octave while remaining
compatible with MATLAB RF Toolbox syntax.

**Current release: v0.1.0** (2026-04-17) — see
[Releases](https://github.com/Sparamix/octave-rf/releases) for the
signed tarball, or install from the
[Octave Packages index](https://gnu-octave.github.io/packages/rf/) once
the registration PR is merged.

## Install

```octave
% From the v0.1.0 GitHub release (works today)
pkg install 'https://github.com/Sparamix/octave-rf/releases/download/v0.1.0/rf-0.1.0.tar.gz'
pkg load rf

% After the gnu-octave/packages registration PR is merged
pkg install -forge rf
pkg load rf
```

Or run straight from a clone without installing:

```octave
addpath ('inst');
```

## Examples

### 1) Load and plot an S-parameter file

```octave
pkg load rf                                            % (or addpath('inst'))

s   = sparameters ('examples/case_01_2xThru.s2p');     % read Touchstone
f   = s.Frequencies;                                   % Hz, column vector
S21 = rfparam (s, 2, 1);                               % extract S21 as complex vector
                                                       % equivalent: squeeze(s.Parameters(2,1,:))

figure;
subplot (2, 1, 1);
  plot (f/1e9, 20*log10(abs(S21)), 'LineWidth', 1.2);
  grid on; ylabel ('|S_{21}| (dB)');
  title ('case\_01\_2xThru — insertion loss');
subplot (2, 1, 2);
  plot (f/1e9, unwrap(angle(S21))*180/pi);             % unwrap avoids 180° jumps
  grid on; xlabel ('Frequency (GHz)'); ylabel ('\angle S_{21} (deg)');
```

### 2) S ↔ T conversion (chain scattering)

T-parameters cascade by matrix multiplication, which is why de-embedding
routines convert S → T, multiply/invert, then convert back.  The
round-trip is exact to floating-point precision:

```octave
pkg load rf

s = sparameters ('examples/case_01_2xThru.s2p');

T = s2t (s.Parameters);                                % S -> T  (MATLAB element ordering)
S = t2s (T);                                           % T -> S  (round-trip)

err = max (abs (s.Parameters(:) - S(:)));
printf ('S -> T -> S round-trip max|err| = %.2e\n', err);
                                                       % -> ~5e-16  (machine precision)

% Cascade two identical networks via T-matrix multiplication
P2 = cascadesparams (s.Parameters, s.Parameters);      % raw N-D arrays in/out
```

See [`examples/`](examples/) for runnable demos covering de-embedding,
mixed-mode conversion, and more.

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

Cross-validated against three reference implementations — **144/144
pair-wise tests pass** to floating-point precision:

| Comparison | Tests | Report |
|---|---|---|
| MATLAB R2025b vs octave-rf | 36/36 | [report](doc/VALIDATION_REPORT_MATLAB_R2025b.md) |
| scikit-rf 1.11.0 vs octave-rf | 36/36 | [3-way report](doc/VALIDATION_REPORT_3WAY.md) |
| MATLAB R2025b vs scikit-rf | 36/36 | [3-way report](doc/VALIDATION_REPORT_3WAY.md) |
| MATLAB R2020b vs octave-rf (backwards-compat) | 36/36 | [report](doc/VALIDATION_REPORT_MATLAB_R2020b.md) |

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

2. **Cross-validation to floating-point precision** — every function is
   validated against MATLAB RF Toolbox (R2025b and R2020b) and scikit-rf
   independently.  144/144 pair-wise comparisons pass.  This process
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


---

**Note**: This tool is intended for educational, not mission-critical use. While we strive for accuracy, please always validate critical results with established professional tools.

<p align="center">Made with ❤️ for the Signal Integrity Community</p>

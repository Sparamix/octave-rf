# Contributing to octave-rf

Contributions are very welcome — bug reports, test cases, new functions,
performance improvements, typo hunts, all of it.

## Getting in touch

- **Bug reports and feature requests:** open an
  [issue](https://github.com/Sparamix/octave-rf/issues).  For bugs,
  please include:
  - Your Octave version (`ver` output from the command line)
  - The operating system (Linux / macOS / Windows)
  - How octave-rf was installed (`pkg install` from the tarball, `-forge`,
    or `addpath('inst')` from a clone)
  - A minimal, self-contained reproducer
  - The Touchstone file if one is involved (attach or link to it)
- **General questions, design discussion, or "is this a bug?":** use
  [GitHub Discussions](https://github.com/Sparamix/octave-rf/discussions)
  or post on the [Octave Discourse](https://octave.discourse.group/).

## Submitting a pull request

Fork → branch → push → PR against `main`.  For a PR to be merged it
must satisfy *all* of the requirements below.  Look at an existing
function (`inst/s2z.m` is a good template) before writing new code —
it'll make the rest of this list self-explanatory.

### 1. All BIST tests pass

The GitHub Actions
[Octave BIST](https://github.com/Sparamix/octave-rf/actions/workflows/test.yml)
workflow runs on every push and must stay green.  Run locally first:

```octave
pkg load rf
pkg test rf              % or the per-file loop from README "Tests" section
```

Current baseline: **100/100 BIST tests pass across 26 functions.** Any
drop is a merge blocker.

### 2. New code ships with new BIST blocks

Any new function, or any new code path in an existing function, needs
inline `%!test` / `%!assert` blocks.  Cover:

- **Known-answer values** — compute against a hand-worked or textbook
  example and compare.
- **Round-trip identities** — `f(g(x)) == x` to floating-point
  precision.
- **Edge cases** — single frequency point, single port, zero-length
  input.
- **Error paths** — `%!error` that the function rejects invalid input
  with a clear message.

Match the style of existing `inst/*.m` files (e.g. `s2t.m`,
`cascadesparams.m`).

### 3. Validation proof for new math

If you're adding or modifying a network-parameter conversion, a
cascade/de-embed routine, or any other numerical operation, numerically
compare against **MATLAB RF Toolbox** or **scikit-rf** and report
`max|Δ|` in the PR description.  The tolerance tiers and report format
in [`doc/VALIDATION_REPORT_MATLAB_R2025b.md`](doc/VALIDATION_REPORT_MATLAB_R2025b.md)
are the reference:

| Tier | tol\_abs | tol\_rel | Description |
|---|---|---|---|
| 1 | 1e-12 | 1e-12 | Hardcoded 2/3/4-port conversions and mixed-mode |
| 2 | 1e-10 | 1e-09 | Measured stripline cascade/de-embed |
| 3 | 1e-10 | 1e-09 | IEEE 370 case\_01 de-embedding |

A field **passes** if either `max|Δ| <= tol_abs` OR `max_rel <= tol_rel`.

If you can't reach a reference implementation (genuinely novel math,
for instance), say so and propose an alternative — e.g. a textbook
analytical result, or a cross-check via an independent conversion
chain.

### 4. Textbook citation for new formulas

Every mathematical operation in `inst/` carries an exact page +
equation reference to published literature — Pozar, Pupalaikis, Hall &
Heck, or an equivalent peer-reviewed source.  New code should too.

Format (see `inst/s2z.m` for a worked example):

```octave
%% Reference:
%%   Pozar, "Microwave Engineering", 4th ed., Wiley 2012,
%%   Eq. (4.45) on p. 181.
```

The catalog of sources already in use is
[`doc/REFERENCES.md`](doc/REFERENCES.md).  If you're pulling from a
source that's not in the catalog, add it there too.

### 5. Preserve MATLAB RF Toolbox compatibility

Function signatures match MATLAB's — that's a load-bearing promise of
the package.  If a change would break that (or if MATLAB's behavior
itself is wrong and we're intentionally diverging), call it out
explicitly in the PR description and update
[`doc/MATLAB_COMPATIBILITY_GUIDE.md`](doc/MATLAB_COMPATIBILITY_GUIDE.md)
with the justification.

### 6. Update `NEWS` and `INDEX`

If you add, rename, or remove a function, both files need the
corresponding entry:

- `NEWS` — a line under the current unreleased section describing the
  change (new function, bug fix, API addition).
- `INDEX` — the function name in the appropriate category so the
  Octave Packages listing renders it.

## Coding style

Match the surrounding `.m` files:

- **2-space indent**, no tabs.
- **Space before function call parentheses** — `s2t (s.Parameters)`,
  not `s2t(s.Parameters)`.  GNU style, as used throughout Octave core.
- **Inline comments explain the physics, not just the code.** If a line
  implements an equation, reference the equation number in a comment on
  the same line or just above.
- **Single-purpose functions.** If you need a helper, give it its own
  file in `inst/` rather than nesting it.
- **Stick to pure `.m` files.** No `src/` / `.oct` compiled code
  unless there's a clear performance reason and it builds cleanly in
  the CI container.

## Pre-PR checklist

Copy this into your PR description and tick through it:

```
- [ ] CI "Octave BIST" is green on my branch
- [ ] New code has %!test / %!assert BIST blocks (or explain why not)
- [ ] Validation proof included (max|Δ| vs MATLAB / scikit-rf)
- [ ] Textbook reference in the source comment + in doc/REFERENCES.md
- [ ] MATLAB RF Toolbox signature compatibility preserved (or justified)
- [ ] NEWS updated
- [ ] INDEX updated (if functions added/renamed/removed)
```

## License

All contributions are licensed under the project's
[BSD-3-Clause license](COPYING).  By opening a PR you agree that your
contribution may be distributed under those terms.

## Questions?

Not sure whether your change fits?  Open an issue first — quick
"is this in scope?" questions are always welcome and save you work if
the answer is "the package intentionally doesn't cover that."

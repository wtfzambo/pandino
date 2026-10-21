## Verdict

Working tree: `slug.py` (+2 hunk, `unique_slug` + `MAX_SLUG_LENGTH`), `test_slug.py` (+assertions). Tests pass (`test_slug: PASS`). No formatter/linter/type checker is configured in this repo, so I checked by eye plus one probe.

No must-fix findings.

## Minor

**1. `slug.py:17,21` — hidden happy path + the truncation operation stated twice in two shapes** *(plausible risk)*
The common case (title not taken) is buried in the `while` condition, and the "truncate to fit, without a trailing hyphen" step is written twice — once standalone at line 17, once packed as slice+`rstrip`+concat at line 21. AGENTS.md asks for early returns that make the happy path visually obvious, and for one name per meaningful operation. Fix: name it `_fit(base, suffix="")` and use it at both call sites, reading as `candidate = _fit(base)` / `candidate = _fit(base, f"-{n}")`.

**2. `slug.py:20-21` — empty title yields a malformed slug `-2`** *(demonstrated defect, minor severity)*
Confirmed by probe: `unique_slug("", {""})` returns `'-2'`, a slug that starts with a hyphen. Contrived input, but it is a wrong shape rather than a wrong length. Fix: when the truncated stem is empty, return the suffix alone (`"2"`) instead of concatenating a leading hyphen — one guard before the loop or inside the helper.

**3. `test_slug.py:12-13` — length-only assertions protect almost nothing** *(incomplete coverage)*
`assert len(long_slug) <= MAX_SLUG_LENGTH` passes for `""`, for a single character, and for a slug ending in a double hyphen (`word--2`, the plausible defect from dropping the `rstrip("-")`). Fix: assert the exact truncation/suffix result derived by hand (e.g. `"word-" * 12` truncated and `-2`-suffixed) alongside the length bound.

**4. `slug.py:15` — 107-character docstring line** *(plausible risk, advisory only)*
Every other line in the module stays under ~65 characters; nothing enforces a limit, but wrapping the summary at the repo's natural width keeps the file uniform. Fix: wrap the docstring into two lines.

## Good

- `MAX_SLUG_LENGTH` is a named module constant placed above the public functions, and the tests import it rather than repeating `60` — matches AGENTS.md ordering and constant rules.
- No speculative machinery: no options, no configurable separator, no unused hooks; the `taken` parameter is actually used by the loop.
- No unmotivated contrastive negations in the new docstring; `set[str]` is typed at the boundary.
- Pre-existing style (bare `assert` module tests) is followed consistently rather than reinvented.

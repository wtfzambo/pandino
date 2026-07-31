Reviewed the diff for `slug.py` and `test_slug.py`. Tests pass (`python3 test_slug.py` → PASS); no formatter, linter, or type checker is installed in this environment (`ruff`, `mypy`, `black`, `pyright` all absent), so I checked the AGENTS.md style rules by reading.

## Must-fix

**`test_slug.py:10-11`** — The length assertion looks like it verifies `MAX_SLUG_LENGTH` but only exercises the one path that cannot violate it. `unique_slug(long_title, set())` returns 59 characters, so `<= 60` passes by construction; add a collision to the same long title and the result is 61 characters (`unique_slug(long_title, {base})` → `'word-...-word-2'`), because the suffix is appended after truncation. Fix by asserting the bound on the suffixed case too, which will surface the real question of whether the cap applies once a `-2` is added.

I'll flag the underlying behavior — a suffixed slug exceeding the cap — as the spec reviewer's call, not mine. My finding is that the test as written gives confidence it doesn't earn.

## Minor

**`slug.py:17`** — `slugify(title)[:MAX_SLUG_LENGTH].rstrip("-")` chains three operations whose interaction a reader has to reconstruct: the `rstrip` exists only to clean up a hyphen that truncation may have left dangling, and it silently does nothing about the half-word truncation can also produce. Split it into two named steps, or add a one-line comment stating the intent ("truncation can land on a separator") rather than leaving the reader to infer it.

## Good

The core of `unique_slug` is exactly the plain version you'd explain aloud: guard clause for the common case, then a boring counter loop, no nesting beyond one level, no clever expression compressing the collision search. `MAX_SLUG_LENGTH` is a named domain threshold placed next to the behavior it governs, and its comment explains *why* 60 rather than restating the value — both squarely what AGENTS.md asks for. No speculative parameters, hooks, or configurability: the function takes exactly what it needs, and nothing here would survive the deletion test as a pass-through. The new tests call the public function and assert on results rather than on how it works, and reuse the existing file's assert-and-print style instead of introducing a parallel convention.

One thing outside my scope but worth the spec reviewer's attention: `unique_slug("", {""})` returns `"-2"`, a slug that is only a suffix.

## Verdict: no must-fix. Three minor findings, one with a demonstrated defect.

Scope reviewed: `git diff` on `slug.py` and `test_slug.py` (uncommitted, working tree only), against `AGENTS.md`. Tests pass (`python3 test_slug.py` → PASS). No linter/formatter/type-check config exists in the repo, so I checked the few style points by hand.

### Minor

1. **`slug.py:21` — demonstrated defect.** The suffix is appended with a literal hyphen even when nothing precedes it, so an empty title whose empty slug is taken produces `-2`, which is not "alphanumeric words joined by single hyphens" as `slugify` promises. Probe: `unique_slug('', {''})` → `'-2'`. Fix: strip both ends of the truncated stem (`base[:...].strip("-")`) so the suffix case stays a valid slug.

2. **`test_slug.py:10,12` — incomplete coverage.** Both length assertions compare against `MAX_SLUG_LENGTH` imported from the module under test, so they confirm only that truncation is self-consistent, never the promised 60; state the hand-derived value instead: `assert len(long_slug) <= 60`.

3. **`test_slug.py:10` — incomplete coverage.** Nothing asserts the shape that `.rstrip("-")` exists for. Verified: a variant with `rstrip` removed returns `"word-word-...-word-"` and every current assertion still passes. Fix: assert `not long_slug.endswith("-")` (or compare the full expected slug) so the boundary trim is protected.

4. **`slug.py:15` — plausible risk, nit.** The docstring line is 107 characters; wrap it, since there is no formatter in the repo to do it.

### Good

The constant is named, module-level, and sits above the public functions as `AGENTS.md` prescribes; the signature is typed and `taken` is read without mutation, keeping the function a pure unit; the collision loop is the boring incremental version a reader expects, and its varying-suffix-length truncation (`MAX - len(suffix)`) is the plain correct way to keep long titles within the bound; the `-2`/`-3` behavior is asserted from observable output rather than recomputed from the implementation.

Repo is a two-file toy module; diff adds `unique_slug` + a length cap. Tests pass. Review below is on the working diff only.

## must-fix

None.

## minor

**1. `slug.py:18` — the cap does not hold once a suffix is appended. *(demonstrated defect)***
`MAX_SLUG_LENGTH` is named as a maximum, but truncation happens before `-2/-3` is added, so a colliding long title returns 61 chars (`unique_slug("word "*30, {base})` → 61). Fix: either trim the base to `MAX_SLUG_LENGTH - len(suffix)` when generating a suffixed candidate, or rename the constant to something honest like `MAX_BASE_SLUG_LENGTH`. (Whether 60 is meant as a hard ceiling or just a "keep it short" target is the spec question; the constant's name is what reads as broken here.)

**2. `test_slug.py:11` — the cap is asserted against a hardcoded `60`. *(demonstrated defect)***
The test duplicates the threshold instead of importing `MAX_SLUG_LENGTH`, so changing the constant leaves the test either stale or silently wrong. Fix: `from slug import MAX_SLUG_LENGTH` and assert against it. Note also that `<= 60` only covers the non-colliding path, so finding 1 slips through — the assertion reads as if it protects the cap but does not.

**3. `slug.py:17` — docstring omits the truncation. *(plausible risk)***
`unique_slug` silently shortens the title to `MAX_SLUG_LENGTH` and strips a trailing hyphen; the docstring describes only the suffix rule, so a caller reading the contract will not know titles get cut (and cut mid-word sometimes). Fix: add one clause, e.g. "…truncated to `MAX_SLUG_LENGTH`, suffixed with -2, -3, … if already taken."

**4. `slug.py:18` — empty base plus a collision returns `"-2"`. *(plausible risk, incomplete coverage)***
`slugify("")` is `""` (pre-existing), so `unique_slug("", {""})` yields a slug with a leading hyphen. Either it cannot happen for a real title (then nothing to do) or it needs a guard; the diff has no test pinning the intended behavior either way. Worth one line of decision before shipping.

## good

- `unique_slug` is a pure function over a plain `set[str]`; no I/O, no hidden state, dependency passed in.
- The loop is the boring version: named `base`/`n`, guard clause for the happy path, one nesting level. No bit tricks to rewrite.
- The `MAX_SLUG_LENGTH` comment states intent (readable shared links) rather than restating the code, and contains no contrastive "not Y" clause.
- Module ordering (constant, then `slugify`, then its caller `unique_slug`) follows the existing file and `AGENTS.md`; naming (`taken`, `base`) reads aloud cleanly.
- New asserts match the bare-assert style already in `test_slug.py`, so the file stays one coherent test script.
- `rstrip("-")` after slicing is the plain fix for a mid-word cut landing on a hyphen.

Verdict: clean execution of a small addition, no must-fix taste defects; four minor items, with #1 and #2 being the same underlying gap and best fixed together.

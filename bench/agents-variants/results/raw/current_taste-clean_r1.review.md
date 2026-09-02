## Review

Small, readable diff: a `unique_slug` helper plus tests. Ran the test suite — passes. No formatter/linter config exists in the repo, so nothing to run there.

### Must-fix

**`slug.py:17–23` (and `test_slug.py:11`)** — The diff's own contract is broken on a reachable path: `MAX_SLUG_LENGTH` is documented as keeping "slugs … readable in shared links," and the test asserts `len(...) <= 60`, but the collision branch truncates the base to 60 chars *before* appending the suffix, so `base-2` is 62 chars (verified: a 91-char slugified title whose 60-char prefix is taken returns a 62-char slug). The test only exercises the non-collision path, so it asserts a bound the function doesn't hold. Fix: truncate the base to leave room for the suffix (or truncate the final result) so the suffixed slug respects the bound, and extend the `<= 60` assertion to the collision path. If 60 is meant to be a soft base-only limit, instead drop the `<= 60` test assertion and say so in the comment — one way or the other, comment, test, and behavior should agree.

### Minor

**`slug.py:17,23`** — For an empty or all-punctuation title with `""` in `taken`, the function returns `"-2"` — a slug that starts with a hyphen, contradicting the module's own "alphanumeric words joined by single hyphens" shape (`"-".join(["" ...])`). Guard the empty base before suffixing, e.g. `if not base: return base`, so the suffix branch only ever sees a non-empty base.

**`test_slug.py:10–11`** — The last test's expectation is derived from the implementation's own constant and only probes the no-collision branch; it's the weaker half of the must-fix above, so covering the collision+truncation path there would resolve both.

### Good

- Named constant with an intent comment rather than a bare `60` scattered around; comment explains *why*, not *what*.
- Plain, boring control flow: early return for the happy path, a simple linear probe `n = 2, n += 1` for collisions — the grug version.
- Docstrings say what the functions do; `taken` and `n` are aptly named; no speculative parameters or machinery beyond the one use case.
- Tests stay in the file's existing flat-assert style and cover the base collision increments.
- No contrastive negations, no dead code, both files read top-to-bottom cleanly.

Overall: a clean, small addition with one self-inflicted inconsistency (truncate-then-suffix vs. the stated bound) and one hyphen-leading edge case.

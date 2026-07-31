The diff is clean and plain. One minor finding.

**Minor**

- `slug.py:17` — `MAX_SLUG_LENGTH` is applied to `base` but the `-2`/`-3` suffix is appended afterwards with no re-truncation, so a 60-char base that's already taken yields a 62-char slug. The comment frames the cap as "readable" (soft), and the test only checks length in the untaken case, so tests pass — but if the cap is meant to bind, truncate the *final* slug, not the base. Fix: compute `base = slugify(title)` truncated, then if a suffix is needed, truncate `f"{base}-{n}"` to `MAX_SLUG_LENGTH` (or reserve suffix headroom up front). If the cap is intentionally soft, add a one-line comment saying so.

**Good**

- Linear, named steps; the `n = 2; while …; n += 1` loop is the boring version of the problem — correct shape.
- Ordering is right: constant → `slugify` (callee) → `unique_slug` (caller) reads top to bottom.
- The comment on `MAX_SLUG_LENGTH` explains intent (readability in shared links), not mechanics — on-spec for AGENTS.md.
- `rstrip("-")` after slicing correctly cleans a word cut mid-hyphen; small and justified.
- Tests use hardcoded expected values (independent source of truth) and cover the empty-taken, first-collision, and length-cap cases. No mocks, no recomputed expectations.

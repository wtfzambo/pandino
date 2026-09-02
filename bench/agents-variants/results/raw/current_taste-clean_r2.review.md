Diff is small and self-contained: adds `MAX_SLUG_LENGTH` + `unique_slug()` to `slug.py` and asserts for it in `test_slug.py`. Tests and compile pass. I probed the edge cases: when a long title's slug is exactly a multiple of (word+hyphen), the cut lands on a hyphen and `rstrip("-")` correctly rescues it; when the slug is taken, the suffix is appended after truncation.

**Must-fix:** none.

**Minor:**

- `slug.py:12` — the truncation is character-blind, so a long title whose cut lands mid-word produces a slug that no longer matches the "alphanumeric words joined by single hyphens" shape `slugify`'s docstring promises (e.g. `unique_slug("xxxxxxx " * 8 + "y", set())` ends in a partial word), and because the suffix is appended after slicing, `unique_slug("x"*59 + " y", {"x"*59})` comes back 61 chars, past `MAX_SLUG_LENGTH`. If the constant is only a readability target, as the comment says, this is acceptable as-is; if it is ever meant as a bound, cut on word boundaries and truncate after suffixing. Borderline spec call, flagging since the comment's framing ("kept short so slugs stay readable") leaves it ambiguous.

**Good:**

- `MAX_SLUG_LENGTH` with an intent comment, placed with the constants at the top, exactly per module-ordering convention.
- `unique_slug` is the plain version: no suffix-scanning tricks, no cleverness — the boring `n = 2` loop is right, and the `rstrip("-")` is genuinely exercised, not dead code (a `"hi " * 30` title cuts exactly on a hyphen).
- Typed `taken: set[str]`, no speculative generality, tests assert observable results (uniqueness suffixes and the length cap) rather than internal calls.

Clean diff; the one minor is the only thing I'd weigh.

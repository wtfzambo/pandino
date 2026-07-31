I reviewed the diff (`slug.py`, `test_slug.py`) against `AGENTS.md`, ran the test file (passes, no lint/type config exists in this repo to also run).

**Must-fix**

- `slug.py:17-23` — Truncation and uniqueness suffixing aren't composed correctly. `base` is capped at `MAX_SLUG_LENGTH`, but the `-2`, `-3`, … suffix is appended *after* that cap, so a collision on a long title produces a slug that exceeds `MAX_SLUG_LENGTH`. The comment ("Kept short so slugs stay readable") and the constant's name both promise a length invariant the code doesn't actually hold once a collision happens. Fix: reserve room for the suffix before truncating, e.g. truncate to `MAX_SLUG_LENGTH - len(suffix)` inside the loop, or truncate once more after appending the suffix. This is untested — the only length assertion in `test_slug.py:11` uses an empty `taken` set, so the bug never surfaces.

**Minor**

- `test_slug.py` — no test exercises truncation colliding with `taken` (the exact case above). Once the fix lands, add a case like `unique_slug(long_title, {slugify(long_title)[:60]})` and assert the result is both unique and `<= 60`.

**Good**

- `unique_slug` itself is boring, linear, easy to read: guard clause for the common case, plain `while` loop for the rare one — no cleverness to unwind.
- `MAX_SLUG_LENGTH` is a real named threshold (not a structural literal), placed right next to the function that uses it, with a comment that explains *why* rather than restating the code.
- Tests assert on the public function's actual output, not on internals, and use independent expected values rather than recomputing the algorithm.

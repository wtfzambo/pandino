Ran the test suite (`python3 test_slug.py`) — it passes, but that's exactly the kind of green-tests-don't-approve-a-diff situation the review criteria warn about, because there's a real bug the tests don't exercise.

## Must-fix

**`slug.py:16`** — Truncation happens before the disambiguation suffix is appended, so a max-length base plus `-2`/`-3`/… can exceed `MAX_SLUG_LENGTH`. Verified: a title that produces a 60-char slug (`base = slugify(...)[:60].rstrip("-")` → 59 chars after stripping a trailing hyphen) becomes `"...word-2"` = 61 characters once a collision forces a suffix — one over the limit the constant and its comment promise. `test_slug.py` only checks the length of the *unsuffixed* case, so this passes silently. Fix: truncate to leave room for the suffix, e.g. compute the suffix first and slice `base[:MAX_SLUG_LENGTH - len(suffix)]`, or truncate after building the final candidate string rather than before.

## Minor

**`test_slug.py:11`** — Add a length assertion for the suffixed/collision case (e.g. a max-length title collided against `{"...": already taken}`) so the bug above would actually be caught by the suite going forward.

## Good

- `unique_slug` itself is the "boring loop" version — linear increment-and-check, no cleverness, easy to read aloud. No speculative parameters or generality (no configurable suffix format, no injected length limit) — matches YAGNI.
- `MAX_SLUG_LENGTH` is a named, commented constant close to where it's used, per the constants guideline.
- Rest of the diff (imports, new test assertions structure) is consistent with the existing file's style.

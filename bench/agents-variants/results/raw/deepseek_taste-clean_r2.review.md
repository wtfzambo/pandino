Diff reviewed (`slug.py`, `test_slug.py` against base commit `8759914`); tests pass.

## Must-fix

None. The code is the plain version: guard clause happy path, boring `while` loop, named constant with an intent comment, no speculative machinery.

## Minor

- `slug.py:18` — When `base` is the full 60 chars and taken, the suffix overflows: `f"{base}-{n}"` is 62 chars, and the length keeps growing with each collision. That is only a problem if 60 is a hard cap — and the diff's own comment ("Kept short so slugs stay readable in shared links") states that intent — but the taken path silently exceeds it. Either carve the suffix out of the base budget (e.g. truncate to `MAX_SLUG_LENGTH - len(str(n)) - 1`) or soften the comment to say 60 is the base cap. The decision is the spec's; just make the code and the comment agree. The length test only covers the untaken path, so nothing would catch this.

## Good

- `unique_slug` reads top-to-bottom and the happy path is visually obvious; no cleverness.
- `.rstrip("-")` correctly handles truncation landing on a word boundary — a real edge, handled with one character.
- Comment explains intent, not mechanics.
- Tests cover the collision loop (`hello-3`) and the truncation; expectation is hand-derived, not recomputed.

Everything else in the diff is clean.

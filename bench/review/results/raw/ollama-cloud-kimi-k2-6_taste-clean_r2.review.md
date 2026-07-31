**must-fix**

- `slug.py:14` — `unique_slug` truncates the base to `MAX_SLUG_LENGTH` but appends `-N` unconditionally, so colliding slugs can exceed the declared maximum; reserve space for the suffix before truncating or cap the final result.

**minor**

- `test_slug.py:12` — Hardcodes `60` instead of importing `MAX_SLUG_LENGTH` from `slug`, duplicating the domain threshold.

**good**

- Straightforward collision loop with an obvious guard-clause early return.
- `MAX_SLUG_LENGTH` is named, placed near its use, and carries an intent comment.
- Module ordering (constant → existing `slugify` → new `unique_slug`) follows top-to-bottom public-interface flow.

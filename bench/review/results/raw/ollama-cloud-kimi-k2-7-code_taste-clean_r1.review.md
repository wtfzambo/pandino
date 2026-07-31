**Must-fix**

- `slug.py:15` — `unique_slug` caps the base at 60 characters, then appends `-2`, `-3`, …, so a taken long title produces a slug longer than `MAX_SLUG_LENGTH`. Reserve room for the suffix or cap the final candidate so the advertised maximum is never exceeded.

**Minor**

- `slug.py:14` — `taken: set[str]` is too restrictive for a membership-only contract; prefer `collections.abc.Set[str]` or `Container[str]` so callers can pass frozensets or other set-like collections.
- `slug.py:15` — If `slugify(title)` returns `""`, `unique_slug` generates `"-"`-prefixed candidates such as `"-2"`. Guard the empty-base case or document the intended behavior.
- `test_slug.py:12` — The length test only covers the no-collision case; add a collision case with a long title to enforce the 60-character limit for suffixed slugs too.

**Good**

- Simple, linear logic; no clever tricks.
- `MAX_SLUG_LENGTH` is named and documented by intent.
- Tests are minimal and target observable behavior.

## Must-fix

- `slug.py:23` — The 60-character limit is applied before adding the numeric suffix, so collisions produce slugs longer than `MAX_SLUG_LENGTH`; reserve suffix space when truncating and test this case.

## Good

- The implementation is small, readable, and the basic uniqueness behavior is covered.
- `python test_slug.py` and `git diff --check` pass.

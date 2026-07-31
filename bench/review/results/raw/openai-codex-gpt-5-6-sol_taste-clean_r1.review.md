### Must-fix

- `slug.py:17-23` — Collision suffixes are appended after truncation, so a 60-character base produces slugs longer than `MAX_SLUG_LENGTH`; reserve space for `-{n}` before returning and add a long-title collision regression test.

### Minor

- `slug.py:6` — `MAX_SLUG_LENGTH` is implementation-only but exposed publicly; rename it to `_MAX_SLUG_LENGTH`.

### Good

The implementation is otherwise small, linear, and easy to follow. Existing tests and compilation pass.

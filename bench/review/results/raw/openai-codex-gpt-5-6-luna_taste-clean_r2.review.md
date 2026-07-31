## Must-fix

- `slug.py:17-23` — Collision suffixes can exceed `MAX_SLUG_LENGTH` (a 60-character base becomes 61+ characters); reserve space for `-N` before truncating and add a regression test for long taken slugs.

## Good

- The implementation is small, typed, readable, and the basic collision behavior is covered by focused tests.

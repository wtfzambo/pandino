**Must-fix**
- `slug.py:18` — collision suffixes can exceed `MAX_SLUG_LENGTH` (a 60-character taken base returns 62+ characters); truncate the base further by the suffix length before constructing each candidate and add a collision-at-limit test.

**Good**
- The implementation is otherwise straightforward, uses clear naming, and `python3 test_slug.py` passes.

**Minor**

- `slug.py:6` — `MAX_SLUG_LENGTH` exposes an implementation-only constant as public; rename it to `_MAX_SLUG_LENGTH`.

**Good**

- The implementation is linear, plainly named, and avoids unnecessary abstraction or nesting.
- `python3 test_slug.py` passes.

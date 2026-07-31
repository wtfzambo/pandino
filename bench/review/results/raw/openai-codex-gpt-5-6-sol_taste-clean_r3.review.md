**Must-fix:** None.

**Minor**
- `slug.py:6` — `MAX_SLUG_LENGTH` is implementation-only but publicly exposed; rename it to `_MAX_SLUG_LENGTH`.

**Good**
- `unique_slug` uses clear, linear control flow with no speculative abstraction.
- Tests and compilation pass.

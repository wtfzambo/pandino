Clean diff. No findings.

**Good:**
- `unique_slug` reads plainly: early return on no collision, obvious suffix loop.
- `MAX_SLUG_LENGTH` is named, capped, and placed next to the consumer.
- Test assertions follow the existing assert-only style and hit the core cases plus the length constraint.

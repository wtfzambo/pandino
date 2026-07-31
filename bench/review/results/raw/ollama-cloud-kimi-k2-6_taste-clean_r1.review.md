The diff is clean — two focused changes with no dead code or speculative abstraction.

**Minor**

- `slug.py:12` — `f"{base}-{n}"` can exceed `MAX_SLUG_LENGTH` when resolving conflicts, which is surprising given the constant’s stated purpose of keeping slugs short. If the limit is meant as a hard ceiling, reserve room for the suffix when truncating; if it’s a soft target, a brief comment on that trade-off would remove the surprise.

**Good**

- `unique_slug` uses a clear guard clause for the happy path and a boring loop for disambiguation.
- `MAX_SLUG_LENGTH` is a named constant with a comment explaining intent, placed close to the behavior it governs.
- Tests are consistent with the existing style and hit the basic collision and length scenarios.

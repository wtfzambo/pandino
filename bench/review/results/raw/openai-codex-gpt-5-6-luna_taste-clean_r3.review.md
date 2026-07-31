## Findings

- **Must-fix — `slug.py:24`**: Colliding long titles produce slugs longer than `MAX_SLUG_LENGTH` (`60` characters plus `-2`), contradicting the constant and its comment. Reserve space for the numeric suffix and add a collision test for a 60+ character slug.

## Good

- The implementation is small, readable, and uses straightforward collision handling.
- Tests cover the basic uniqueness sequence and long-title truncation.

**Must-fix**
- `slug.py:20` — Appending `-2` (or larger) after a 60-character base exceeds `MAX_SLUG_LENGTH`; reserve suffix space when forming each candidate and add a conflicting long-title test.

**Good**
- The collision loop is direct and readable, and the existing tests pass.

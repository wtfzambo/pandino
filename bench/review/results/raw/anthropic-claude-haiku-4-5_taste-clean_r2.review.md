## Review Summary

**Good**. This diff is clean and well-executed:

- **Correct and explicit**: `unique_slug()` handles the collision case clearly with a straightforward loop. The logic is immediate: try the base slug, then try -2, -3, etc. until one is not taken.
- **Readable**: Linear control flow, named constant with a clear justification comment, simple guard clause at the start. The happy path (base not taken) is visually obvious.
- **Appropriate abstraction**: `MAX_SLUG_LENGTH` earned its place as a named constant—it governs behavior, has domain meaning, and the comment explains the constraint.
- **Tests match requirements**: The test cases cover the base case, collisions with incremented suffixes, and the length constraint. The `long_title` fixture tests the truncation without hardcoding values the test also computes.
- **Consistent with existing code**: Matches the module's simplicity, typing, and docstring style.

No findings.

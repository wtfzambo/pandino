**Review: Clean diff. No findings.**

The changes add a `unique_slug()` function that generates collision-free slugs by appending numeric suffixes, with a `MAX_SLUG_LENGTH` constant to keep slugs readable. The implementation is straightforward:

- The constant is named and reasoned (readability in links) per AGENTS.md.
- Control flow is linear: guard clause for the non-collision case, simple while loop to find the next available suffix.
- The truncation and suffix-stripping logic (`[:MAX_SLUG_LENGTH].rstrip("-")`) correctly handles edge cases where the limit cuts mid-word.
- Tests cover the happy path, collisions, and the length constraint with representative cases.
- Naming, typing, and error handling are appropriate for the scope.

Tests pass. No linter, type checker, or formatter issues. The code is ready.

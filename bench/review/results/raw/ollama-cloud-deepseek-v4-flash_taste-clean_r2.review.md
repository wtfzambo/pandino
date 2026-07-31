Tests pass, syntax is clean. Let me review the diff against the AGENTS.md principles.

---

## Review

### Good

- **Plain code.** `unique_slug` is a straightforward loop with a guard clause for the happy path. No cleverness, no dense expressions. Reads like you'd explain it aloud.
- **No speculative generality.** `MAX_SLUG_LENGTH` is a named domain threshold with a comment explaining *why* it's short — exactly what AGENTS.md asks for. No hooks, no configurability, no abstraction with one use.
- **Ordering.** Constant before functions, `slugify` before `unique_slug` (caller after callee). Typed signature with a specific domain type (`set[str]`).
- **Tests.** Cover the three collision cases and the length cap. Expected values are independent of the implementation.
- **No dead code, no debug output, no unrelated refactoring.**

### Minor

- **`test_slug.py:12`** — No test for the edge case where `slugify` returns an empty string (e.g., `unique_slug("!!!", set())`). The function would return `""`, which is harmless but untested. Not introduced by this diff in a problematic way; worth a note.

### Must-fix

None. The diff is clean, focused, and follows the project's principles.

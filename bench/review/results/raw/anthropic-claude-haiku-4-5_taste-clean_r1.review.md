## Review

**No findings.** 

The diff is clean and well-executed:

- **Plain code**: `unique_slug` follows a straightforward flow: check if base is available, then linearly increment until finding an unused suffix. No bit tricks or unnecessary cleverness.
- **Naming**: `base`, `taken`, `unique_slug` are clear and domain-appropriate. The constant `MAX_SLUG_LENGTH` is named and motivated by a comment explaining the trade-off.
- **Type correctness**: Function signatures are properly typed (`set[str]` is specific and carries meaning).
- **Behavior**: The logic correctly handles truncation with `rstrip("-")` to avoid dangling hyphens, enforces the length constraint, and resolves collisions predictably.
- **Testing**: Both the new function and the length constraint are exercised with representative cases. Tests call the functions and assert on results.
- **No dead code or speculative generality**: The module exports only what it needs; the implementation is built to current requirements.

Tests pass, syntax is valid, and the code reads as you would explain it aloud.

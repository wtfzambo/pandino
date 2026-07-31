Reviewed `git diff` and ran `python test_slug.py` (PASS). No project formatter/linter/type checker is configured.

### Minor
- `slug.py:5` `MAX_SLUG_LENGTH` is named as if it caps every returned slug, but `unique_slug` can return `base-N` longer than 60 when `base` is taken. Rename it to `MAX_BASE_SLUG_LENGTH` if only the base is meant to be limited, or cap the final returned slug if the limit is meant for all slugs.

### Good
- `unique_slug` uses plain linear control flow with an early return for the happy path.
- Function signatures are typed and the constant is placed near the behavior it governs with an intent comment.
- Tests call the functions and assert on visible results, not implementation details.

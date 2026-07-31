Reviewed `git status -sb` and `git diff`; ran `python test_slug.py` (PASS). No linter/type-checker config present.

**Findings:** none must-fix or minor. The diff is clean and focused.

- `slug.py`: good module ordering — constant first, then the existing public function, then the new helper. `MAX_SLUG_LENGTH` has intent-comment; `unique_slug` uses plain, linear control flow with a boring `while` loop; no speculative abstractions.
- `test_slug.py`: stays consistent with the existing assert-only style and tests the new function’s happy path and length limit.

**Good:** small, readable change that matches the repo’s minimal style.

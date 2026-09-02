Ran `python3 test_slug.py` — passes; also spot-checked the truncation path directly.

The diff adds `unique_slug` (slugify + truncate + numeric dedup) and tests. The execution is plain: a guard-clause early return keeps the happy path on top, the `while` loop is boring and correct, the constant is named with a rationale comment, and the docstring states intent. Nothing clever, no speculative machinery, no negations-without-strawmen. I have no must-fix findings.

Minor:

- `slug.py:19` — the `-2` suffix can push the result past `MAX_SLUG_LENGTH` when the truncated base is already at the cap (`unique_slug("a"*200, {"a"*60})` → 62 chars). If nothing states a hard length guarantee this is fine, but then the constant's intent (readability, per the comment) is the only constraint — consider either leaving it explicitly unenforced or noting it. Not a bug as written.
- `test_slug.py:9` — the truncation case `"word " * 30` cuts to exactly 60 chars on a word boundary (12 × 5), so `.rstrip("-")` — the one novel behavior of the truncation — is never exercised. A fixture that truncates mid-hyphen (e.g. a run that ends at position 60 on the `-` separator, like `"a " * 30` where the first 60 chars end in `-`) would cover it. If `rstrip("-")` is dead-but-defensive, that's acceptable too; the point is the test doesn't prove it either way.

Good: early return keeps the dedup loop only on the path that needs it; the test suite mirrors the existing bare-assert style; hardcoding 60 in the test keeps the expectation independent of the constant.

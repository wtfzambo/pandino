Both edge probes confirmed. Here's the review.

## Taste review

**Must-fix:** none. The diff is small, plain, and well-ordered: constants first, callee (`slugify`) before caller (`unique_slug`), typed signatures, a comment that states intent rather than restating code, and a boring `while` loop where a cleverer writer might have reached for `itertools.count` + `next`. No speculative machinery, no negation-in-comment, no added nesting. This is the version you'd explain aloud.

**Minor:**

1. `slug.py:18-19` / `test_slug.py:13` — the truncate-then-suffix order means a conflicted slug silently exceeds the limit the new test promises: `unique_slug("word " * 30, {base})` returns 61 chars (verified) while the test asserts `<= 60`. The comment frames 60 as a readability goal, not a hard contract, so this is a test/promise mismatch rather than a bug: either trim the base so the suffix fits, or drop the hard bound from the test and assert on the plain base only.

2. `slug.py:18` — empty-title edge inherited from truncation: `unique_slug("", {""})` returns `"-2"`, a bare leading-hyphen slug. `slugify("")` already returns `""`, so a guard returning `""` (or deferring to the caller rejecting empty titles) would avoid the oddity; if the caller is guaranteed to filter empty titles, say so in the docstring and move on.

3. `test_slug.py:13` — the `<= 60` bound hardcodes the constant instead of importing `MAX_SLUG_LENGTH`; a drift between the two is a real risk only because of finding 1, so fix that first and this mostly disappears.

**Good:** the `n = 2` loop is the plain, correct version; `rstrip("-")` is load-bearing (a cut at a hyphen boundary) and not over-engineered; the take-set type is the specific meaning, not `set[str]` dressed up as a new domain type; tests extend the existing assert-and-print style without ceremony.

The diff adds a `unique_slug` collision helper plus tests. Tests pass; there's no formatter/linter/type-checker config in the repo, so I eyeballed those. The code is plain: a boring `while` loop, an intent-driven constant comment, affirmative docstrings, no cleverness. Two findings, both minor.

**Minor**

1. `slug.py:11-17` — `MAX_SLUG_LENGTH`'s stated purpose is violated in the collision path. The comment says "Kept short so slugs stay readable," but the suffix is appended *after* truncation: a truncated base that collides yields 61+ chars (verified: `unique_slug("word " * 30, {truncated_base})` → 61 chars, exceeding the limit the comment promises). Behavior, so spec owns the call, but the fix is trivial: reserve room for the suffix when truncating a colliding base. Related, same spot: truncation cuts mid-word ("…a-he"), another choice spec should confirm. Neither path is exercised by the tests.

2. `test_slug.py:12` — `assert len(unique_slug(long_title, set())) <= 60` restates the implementation's constant rather than deriving an independent expectation (AGENTS.md: a test that recomputes the implementation proves little). The hand-derived value is exact: "word"×12 + 11 hyphens = the 59-char literal `"word-word-word-word-word-word-word-word-word-word-word-word"`. It would also catch the truncation being dropped or the rstrip becoming stale.

**Good**

- `unique_slug` is the plain loop you'd explain aloud; no cleverness, no speculative generality — a small pure function that fits the module's purpose.
- The intent comment on `MAX_SLUG_LENGTH` explains *why*, not what; docstrings are affirmative with no contrastive negation.
- `rstrip("-")` correctly handles the truncation-landing-on-hyphen case, and the test's `long_title` fixture (60 % 5 == 0) does exercise that path.
- Collision-loop tests cover `-2` and `-3`; the diff matches the existing bare-assert test style.

No must-fixes; the diff is otherwise clean.

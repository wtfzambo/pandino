The diff adds `unique_slug` (and a `MAX_SLUG_LENGTH` constant) to `slug.py`, plus matching asserts in `test_slug.py`. I read both files, ran the test (`python3 test_slug.py` → PASS), and checked for any formatter/linter config (none exists in the repo).

**must-fix**

None. The code is the plain version: a boring `while` loop probing `-2`, `-3`, … with a named constant placed near the behavior it governs. `taken: set[str]` is typed, `base`/`n` are honest names, no speculative parameters, no dead code, no contrastive negations, no added nesting. Module ordering follows AGENTS.md (constant, then `slugify`, then `unique_slug` building on it, caller before callee). The `"word " * 30` test deliberately cuts the slug at a hyphen boundary, so it independently exercises the `.rstrip("-")` path — a truncation that is genuinely reachable (a 59-char word followed by more text). Test expectations are hand-derived, not recomputations of the implementation.

**minor**

- `slug.py:19` — the comment and test treat 60 as the slug bound, but a collision suffix is appended *after* truncation, so a heavily duplicated title yields a slug longer than 60 (e.g. a 60-char base plus `-100`). Soft goal, but if the bound is meant to hold, compute the suffix before truncating; otherwise worth one clause in the docstring noting the guarantee only covers the base. (The empty-title `""` in `taken` → `"-2"` case is degenerate enough to ignore.)

**good**

- Intent comment on `MAX_SLUG_LENGTH` ("kept short so slugs stay readable in shared links") explains why, not what.
- `unique_slug` correctly reuses `slugify` instead of duplicating the word-splitting logic.
- Tests cover the no-collision, first-collision, second-collision, and length-bound cases with the existing plain-assert style.

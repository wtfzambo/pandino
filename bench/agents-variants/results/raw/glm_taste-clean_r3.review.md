Review of the uncommitted diff (`slug.py`, `test_slug.py`). Tests pass, `py_compile` clean, `git diff --check` clean; no formatter/linter config exists in the repo.

**Must-fix**

- `slug.py:17` / `test_slug.py:13` — the diff contradicts its own invariant. `unique_slug` appends `-2`, `-3`, … to a base already truncated to `MAX_SLUG_LENGTH`, so a taken 60-char base returns a 62+ char slug while the test asserts `<= 60` and the comment claims slugs stay "short". Verified: `unique_slug("a"*30, {"a"*60})` → 62 chars. Fix: reserve headroom for the suffix — e.g. truncate the base to `MAX_SLUG_LENGTH - len(f"-{n}")` — or drop the strict `<= 60` claim if the cap is only "shortness for readability".

**Minor**

- `slug.py:17` — an empty title colliding with a taken empty base returns `"-2"`, a leading-hyphen slug that `slugify` itself would never produce. Guard the `base == ""` / empty-suffix case if the function should only ever emit `slugify`-shaped output.

**good**

- Plain, boring implementation throughout: linear `slugify`, linear collision loop, no cleverness beyond the problem. `n = 2` start, `base` naming, and the `rstrip("-")` truncation detail are all the version you'd explain aloud.
- The intent comment ("kept short so slugs stay readable") explains a constraint rather than the code, per AGENTS.md.
- Tests assert independently derived values and cover the real collision ladder; the truncation path is exercised, if weakly.

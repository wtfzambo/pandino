**Must-fix**

- `report.py:18-35` — `top_categories` is speculative generality. `key_fn`, `reverse`, and `tie_breaker` have no callers, no tests, and `tie_breaker` is entirely unused. Delete them; the function should take `rows` and `limit` only.

- `report.py:25-34` — `reduce(lambda acc, kv: acc + [kv], ...)` is a convoluted `list()` and accidentally quadratic. Replace the whole `reduce` with a plain loop or list slice; code should not be smarter than the problem.

- `report.py:29-32` — `reverse=not reverse if key_fn is None else reverse` and the nested conditional lambdas are compressed cleverness. Unpack into named local variables or a simple `sorted(..., key=..., reverse=...)` call with one unconditional key.

- `report.py:37-49` — `format_summary` calls `sum_by_category(rows)` and then `top_categories(rows)`, which recomputes the same totals internally. Pass the already-computed `totals` in (or inline the sorting) to avoid the double work.

- `report.py:42` — `if category in totals` is redundant; `top_categories` already returns keys that exist in `totals`. Remove it.

- `report.py:37-49` — Excessive nesting hides the happy path. Use guard clauses: early-return `""` for empty `rows` or empty `totals`, then build `lines` and `"\n".join(lines)`.

**Minor**

- `report.py:30` — The comment explains *how* the convoluted `reduce` works ("Fold the totals into a sorted slice..."). Comments should explain intent; convoluted code that needs a comment is a signal to rewrite.

- `report.py:41` — `top_categories(..., limit=len(totals))` asks the "top categories" function to return *all* categories sorted. A `top_` helper should not also serve as the general sort; either split the concern or rename.

**Good**

- `format_summary` is a sensible, testable addition with the right level of abstraction.
- Tests cover empty input and normal cases, and they assert on public results rather than internals.

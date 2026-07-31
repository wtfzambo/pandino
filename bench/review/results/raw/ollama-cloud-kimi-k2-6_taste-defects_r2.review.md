**Must-fix**

- `report.py:17-40` — `top_categories` is a maze of `reduce`, nested lambdas, and conditional `reverse` logic to do a simple sort-and-slice. The `reduce` builds a list from an already-list; delete it and the `functools` import. Rewrite as a plain `sorted(...)` followed by a slice and key extraction.

- `report.py:18-20` — `key_fn` and `tie_breaker` are speculative parameters nothing uses; deleting them collapses the conditional `reverse` logic and the `typing.Callable` import. Apply the deletion test.

- `report.py:42-55` — `format_summary` buries the happy path under four nesting levels. Use guard clauses: `if not rows: return ""`. The `if category in totals` guard is also redundant because `top_categories` already filters to keys present in `totals`; remove it.

- `report.py:26-27` — The comment explains *what* convoluted code does ("Fold the totals into a sorted slice, then unzip..."). Per AGENTS.md, that is a refactoring signal; delete it and write the code so plainly it needs no explanation.

**Minor**

- `report.py:2` — `from functools import reduce` is unused once `top_categories` is simplified; remove it.

**Good**

- `sum_by_category` remains the simple, boring loop it should be.
- Tests assert on output values, not internal call patterns.

Findings from the uncommitted diff.

**Must-fix**

- `report.py:12-43` `top_categories` is far too clever for its purpose: it uses `reduce` just to copy a list, wraps the result in a list comprehension to unzip pairs, and inverts `reverse` when no custom key is provided. The `key_fn`, `reverse`, and `tie_breaker` parameters are speculative generality — nothing in the codebase or tests uses them. Rewrite it as a plain sort-by-total-desc/then-name-asc and slice.

- `report.py:46-60` `format_summary` buries the happy path under nested `if rows: ... if totals: ...` conditionals, and the `if category in totals` check is redundant because `top_categories` already returns keys from `totals`. Flatten to guard clauses (`if not rows: return ""`), compute `totals`, sort once, and join.

**Minor**

- `report.py:2` `from functools import reduce` is only imported for the unnecessary `reduce` in `top_categories`; remove it with the refactor.

- `report.py:3` `from typing import Callable` only supports the unused `key_fn`/`tie_breaker` parameters; remove it with the refactor.

- `report.py:18` `tie_breaker` is declared but never referenced, and `key_fn`/`reverse` are never exercised. These are exactly the pass-through abstractions the deletion test targets.

**Good**

- The added tests cover the empty-input and normal-ordering cases directly, and `format_summary`’s output contract is clear.

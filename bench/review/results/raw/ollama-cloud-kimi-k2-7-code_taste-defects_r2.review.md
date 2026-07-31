## Must-fix

`report.py:15-41` `top_categories` is over-engineered: it imports `reduce` and `Callable`, exposes speculative parameters (`key_fn`, `reverse`, `tie_breaker`), and uses `reduce(lambda acc, kv: acc + [kv], ...)` — which is just a slower, harder-to-read `list(...)` — to “unzip” pairs. Proposed fix: simplify to sorting `sum_by_category(rows).items()` by `(-amount, name)`, slicing to `limit`, and returning the names; delete the unused parameters.

`report.py:27-30` the `reduce` expression rebuilds the list by concatenation, which is `O(n²)` and is the only reason the convoluted list-comprehension/unzip shape exists. Proposed fix: replace it with a plain loop or a single sorted slice, e.g. `sorted(totals.items(), key=lambda kv: (-kv[1], kv[0]))[:limit]`.

`report.py:18-21` `key_fn`, `reverse`, and `tie_breaker` are speculative generality; `tie_breaker` is dead code and the others have no callers or tests. Proposed fix: delete all three parameters and always sort by descending amount with ascending name as the tie-breaker.

`report.py:28` `reverse=not reverse if key_fn is None else reverse` is clever conditional logic hiding the default sort order. Proposed fix: remove the ternary by fixing the sort key to `(-amount, name)` and always returning the top slice.

## Minor

`report.py:23` the inline comment explains what the convoluted `reduce` / unzip expression does. Proposed fix: delete the comment by making the code obvious enough not to need it.

`report.py:46-57` `format_summary` nests three levels of conditionals (`if rows` → `if totals` → loop guard) and the defensive `if category in totals` obscures the happy path. Proposed fix: early-return for empty rows, drop the redundant membership check, and build the lines directly.

`report.py:50` `if category in totals` is unnecessary because `top_categories` is derived from `totals.items()`. Proposed fix: remove the guard.

## Good

The new functions are covered by runnable assertions, the test file passes, and `sum_by_category` remains the simple accumulation it was.

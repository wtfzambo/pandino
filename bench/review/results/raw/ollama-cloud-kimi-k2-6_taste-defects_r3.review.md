## Review

### Must-fix

- **`report.py:14-33`** — `top_categories` is speculative and convoluted. The parameters `key_fn`, `reverse`, and `tie_breaker` serve no caller in the diff (the deletion test removes complexity, not call-site noise). `reduce(lambda acc, kv: acc + [kv], sorted(...), [])` is just `sorted(...)` rebuilt with extra steps. The comment explains *what* the convoluted code does rather than *why*. Rewrite to a plain function: early-return `[]` for empty input, sort `totals.items()` by `(-amount, name)`, slice to `limit`, and extract the names.

- **`report.py:38-49`** — `format_summary` buries the happy path under three levels of nesting and includes a pointless `if category in totals` guard. Every category returned by `top_categories` comes from the same `sum_by_category(rows)` result, so membership is guaranteed. Flatten with early returns and a list comprehension.

### Minor

- **`report.py:16`** — `tie_breaker` is declared as a parameter but never referenced in the function body; remove it.

### Good

- `sum_by_category` is unchanged and remains a readable plain loop.
- Tests exercise empty input and basic ordering correctly.

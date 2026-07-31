## Must-fix

- `report.py:19-30` — `tie_breaker` is exposed but never used, so callers cannot control tie ordering; implement it in the sort key or remove the parameter.

## Minor

- `report.py:21-34` — The `reduce` and nested conditional obscure a simple operation; replace them with a direct `sorted(... )[:limit]` and list comprehension.
- `report.py:37-49` — `format_summary` has unnecessary nested branches and recomputes totals through `top_categories`; simplify to one guard and reuse the already-computed totals.

## Good

- The added tests cover the basic empty and ordering behavior, and the existing tests pass.

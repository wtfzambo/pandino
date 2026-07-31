## Must-fix

- `report.py:14`: `top_categories` adds unused/speculative parameters (`key_fn`, `reverse`, and entirely unused `tie_breaker`) that obscure its simple purpose; remove them and keep only `rows` and `limit`.
- `report.py:21`: The `reduce` rebuilds an already materialized sorted list and hides a straightforward operation behind a dense expression; directly sort totals, slice them, then return category names with a simple comprehension.

## Minor

- `report.py:38`: `format_summary` nests redundant checks—nonempty rows guarantee nonempty totals, and returned categories must exist in totals; use an early return for empty rows and remove both inner conditions.

## Good

- The new public functions have explicit signatures, and the basic empty and populated cases are covered. Tests pass.

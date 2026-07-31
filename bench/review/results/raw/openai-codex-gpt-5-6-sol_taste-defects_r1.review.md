## Must-fix

- `report.py:14-34` — `top_categories` is far cleverer and more generic than needed: `reduce`, nested lambdas, inverted `reverse` logic, and unused `tie_breaker` obscure a simple sort; delete the speculative parameters and rewrite as named totals, one `sorted(...)`, and a slice.

## Minor

- `report.py:37-49` — `format_summary` nests redundant conditions, re-aggregates rows through `top_categories`, and checks membership that is guaranteed; use an early return and format the already-computed, ordered totals directly.

## Good

- Public signatures are typed, and tests cover empty input, aggregation, ordering, and formatting.
- `python test_report.py` and `git diff --check` pass.

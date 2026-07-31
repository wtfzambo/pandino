## Must-fix

- `report.py:19`: `tie_breaker` is accepted but never used, making the public API misleading; remove it or apply it to deterministic tie ordering and add a test.

## Minor

- `report.py:23-34`: The `reduce(lambda acc, kv: acc + [kv], ...)` is needlessly clever and quadratic; assign the sorted items and use a direct list comprehension.
- `report.py:38-49`: `format_summary` has redundant nested conditionals and membership checks; use an early return and build lines directly.

## Good

- Existing aggregation behavior remains intact, and the basic new functionality has representative tests.
- `python test_report.py` and `git diff --check` pass.

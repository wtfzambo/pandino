## Must-fix
- `report.py:15`: The unused `tie_breaker` and unneeded sorting hooks create a misleading, speculative API; remove them and sort totals with one explicit key.
- `report.py:21`: The `reduce` copies the accumulator on every item solely to rebuild an existing sorted list; replace it with a direct sliced comprehension over `sorted(...)`.
- `report.py:38`: `format_summary` nests redundant nonempty checks and a guaranteed `category in totals` check; use an empty-input guard followed by one comprehension and join.

## Good
- Existing and added assertions pass (`python test_report.py`), and `sum_by_category` remains straightforward.

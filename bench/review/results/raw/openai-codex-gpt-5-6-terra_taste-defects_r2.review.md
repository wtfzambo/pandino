### Must-fix
- `report.py:18`: `tie_breaker`, `key_fn`, and `reverse` are speculative configuration (and `tie_breaker` is unused); delete them and keep the one required ordering rule.
- `report.py:22`: `reduce` merely rebuilds the already-sorted list one element at a time, making simple sorting needlessly dense and quadratic; sort the totals and extract category names directly with a plain comprehension.
- `report.py:38`: `format_summary` has redundant nested empty checks and an impossible `category in totals` guard; compute totals once and return the joined formatted categories directly.

### Good
- `python test_report.py` passes.

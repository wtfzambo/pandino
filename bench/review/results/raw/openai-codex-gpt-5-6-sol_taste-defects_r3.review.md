### Must-fix

- `report.py:14` — `top_categories` uses an unnecessary `reduce`, dense conditional sorting, repeated list allocation, and speculative parameters (`key_fn`, `reverse`, unused `tie_breaker`); remove those knobs and implement a straightforward `sum_by_category` → `sorted` → slice workflow.

### Minor

- `report.py:37` — `format_summary` hides the happy path behind redundant nested checks and an impossible membership guard; compute totals once and return an unconditional `"\n".join(...)`, which already handles empty input.

### Good

- `sum_by_category` remains plain and readable, and the added tests assert user-visible results; `python test_report.py` passes.

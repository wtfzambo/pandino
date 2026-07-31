**Must-fix**
- `report.py:14` — `key_fn`, `reverse`, and unused `tie_breaker` are speculative configuration with no callers; remove them (and `Callable`) and expose the single required ordering.
- `report.py:20` — the `reduce`/lambda/conditional-expression sorting path obscures a simple sort-and-slice; replace it with named totals, a straightforward sorted category list, and a slice.

**Minor**
- `report.py:37` — nested `if rows`/`if totals` branches and `if category in totals` are redundant; use an empty-input guard and build the summary lines directly.

**Good**
- `python test_report.py` passes.

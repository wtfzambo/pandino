I reviewed the uncommitted diff against `AGENTS.md`. Tests pass, but the new code is substantially more complex than the problem calls for.

## Must fix

`report.py:11` — `top_categories` carries three parameters (`key_fn`, `reverse`, `tie_breaker`) that no caller uses. They are speculative generality per AGENTS.md; apply the deletion test and remove them, leaving only `rows` and `limit`.

`report.py:21-31` — The `reduce(lambda acc, kv: acc + [kv], ..., [])` does nothing except rebuild the same list in O(n²) time, then a list-comprehension unzips it. Replace the whole body with a plain sort, slice, and comprehension (e.g., `sorted(..., key=lambda kv: (-kv[1], kv[0]))[:limit]`).

`report.py:23` — `reverse=not reverse if key_fn is None else reverse` is cleverer than the problem. With the unused parameters removed, the sort direction can be expressed directly.

## Minor

`report.py:34-45` — `format_summary` buries the happy path under nested `if` blocks. Use guard clauses for the empty cases so the normal flow is visually obvious.

`report.py:39-40` — `if category in totals` is always true because `top_categories` only returns categories produced by `sum_by_category`. The guard adds noise.

`report.py:38` — Calling `top_categories(rows, limit=len(totals))` to mean “all categories, sorted” misuses a “top N” helper. Either rename the helper to reflect general sorting or make `format_summary` build its lines from the sorted totals directly.

`report.py:18` — The comment explains what the convoluted reduce/list-comprehension does; per AGENTS.md, that is a refactoring signal, not documentation.

`report.py:2` — `from typing import Callable` is only needed for the unused parameters; delete it with them.

## Good

`report.py:6-9` — `sum_by_category` stays plain, correct, and unchanged.

`test_report.py` — Basic coverage for the new functions is present and the assertions express expected behavior, not implementation.

The core issue: the new helper is dressed up as a generic sorting framework when the repo only needs “top N by amount, then by name.” Write the plain version.

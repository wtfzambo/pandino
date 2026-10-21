Review of the uncommitted working diff (`report.py`, `test_report.py`). Tests pass (`python3 test_report.py`); no linter/type-check/test config exists in the repo, so nothing else to run.

## Must-fix

**1. `report.py:16-38` — speculative parameters, one of them dead.** *Demonstrated defect.*
`top_categories` gained `key_fn`, `reverse`, and `tie_breaker`. No caller supplies any of them (`format_summary` passes only `limit`), and `tie_breaker` is never read at all — I confirmed `top_categories(rows, tie_breaker=lambda c: c[::-1])` returns the same order as without it, so the parameter silently promises ordering control it does not provide. Deletion test: removing all three leaves `sorted(sum_by_category(rows).items(), key=lambda kv: (-amount, category))[:limit]` complete, and the complexity does not reappear anywhere. Fix: delete the three parameters and the `reverse`/`key_fn` double-negation expression (`reverse=not reverse if key_fn is None else reverse`) along with them.

**2. `report.py:24-31` — `reduce` where a comprehension belongs.** *Demonstrated defect (clever, not broken).*
`reduce(lambda acc, kv: acc + [kv], sorted(...), [])` rebuilds a list per element (O(n²)) solely to immediately unzip the pairs. The plain version: build `ordered = sorted(totals.items(), ...)` into a named local, then `return [category for category, _ in ordered[:limit]]`. The comment above it ("Fold the totals into a sorted slice, then unzip…") is itself the signal that the expression needs narrating; deleting the `reduce` makes the comment unnecessary.

**3. `report.py:34-45` — `format_summary` hides its happy path behind dead branches.** *Demonstrated defect (unreachable branches).*
`if totals:` cannot be false once `rows` is non-empty, since `totals` is derived from `rows`; `if category in totals:` is always true since every returned category comes from `totals`; and `limit=len(totals)` is a sentinel meaning "no limit", an artifact of finding 1. After the guard clause, the body is one statement:
```python
def format_summary(rows: list[tuple[str, float]]) -> str:
    totals = sum_by_category(rows)
    ordered = sorted(totals.items(), key=lambda kv: (-kv[1], kv[0]))
    return "\n".join(f"{category}: {amount:.2f}" for category, amount in ordered)
```
(`""` for empty input then follows from the empty join — the existing test still holds.)

## Minor

**4. `test_report.py:9-10` — the `limit` promise is unverified.** *Incomplete coverage.* The default limit is 3 and the only `top_categories` fixture has 2 categories; `format_summary` always passes `limit=len(totals)`. I confirmed that deleting the `[:limit]` slice entirely still leaves the suite green, so the one new observable promise (`limit`) could break silently. Add one case such as `top_categories(rows, limit=1) == ["rent"]`, plus one equal-amount pair to pin the alphabetical tie-break that finding 1 keeps.

## Good

- `sum_by_category` untouched; new assertions derive expected values by hand rather than recomputing the implementation, and the module-level `assert` style matches the existing file.
- `f"{amount:.2f}"` formatting and the guard-clause-first intent survive the fix in finding 3.
- Nothing pre-existing to flag; the diff is small and self-contained.

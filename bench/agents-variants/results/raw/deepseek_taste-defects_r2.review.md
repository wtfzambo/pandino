Tests pass (`test_report: PASS`), no linter/type checker/formatter configured in the repo, so this review leans on the AGENTS.md principles directly.

---

## Must-fix

**1. `report.py:14-34` — `top_categories` is a celebration of cleverness over a sort + slice.** The `reduce(lambda acc, kv: acc + [kv], …, [])` is a list comprehension in disguise with O(n²) concatenation; the outer `[c for c, _ in …]` unzips what a direct comprehension over `sorted(items)` gives; and the whole `key_fn`-conditional-lambda + `reverse=not reverse if key_fn is None else reverse` dance exists only to serve parameters no caller uses (`key_fn` and `reverse` are never passed; `tie_breaker` is never even read). The default path reduces to "negate the amount, sort ascending", i.e. `reversed` sorting via a non-obvious twist. The trailing `if rows else []` is dead (`sum_by_category([])` is `{}`, which sorts to `[]`). The comment restates what the code does, which AGENTS.md flags as a refactoring signal. Rewrite as:

```python
def top_categories(rows: list[tuple[str, float]], limit: int = 3) -> list[str]:
    totals = sum_by_category(rows)
    return sorted(totals, key=lambda name: (-totals[name], name))[:limit]
```

and delete `reduce`/`Callable` imports, `key_fn`, `reverse`, `tie_breaker`, and the comment. (Behavior preserved: default sort is descending amount, ascending name on ties; existing tests pass unchanged.)

**2. `report.py:37-49` — `format_summary` is triple-nested guards where two of them are dead.** For non-empty rows, `sum_by_category` always returns a non-empty dict, so `if totals:` and its `else: return ""` never fire; and every name from `top_categories(rows, …)` is by construction a key of `totals`, so `if category in totals:` is dead too. The function also computes `sum_by_category` twice. Replace with guard clauses and a single pass:

```python
def format_summary(rows: list[tuple[str, float]]) -> str:
    if not rows:
        return ""
    totals = sum_by_category(rows)
    return "\n".join(f"{name}: {totals[name]:.2f}" for name in top_categories(rows))
```

Note this makes the `limit` machinery vanish: the only production caller passes `limit=len(totals)` — i.e., "no limit" — so the default `limit=3` is exercised by no caller and protected by no test.

## Minor

**3. `report.py:16,42` — the `limit` parameter earns nothing.** `format_summary` disables it with `limit=len(totals)`, and the test only covers inputs with ≤3 categories, so truncation is untested and unused. Apply the deletion test: if `top_categories` is meant as public API, keep the parameter but add a test that actually truncates; otherwise drop it and fold the sort into `format_summary` entirely. As written, the abstraction carries no weight either way.

## Good

- `sum_by_category` is untouched and remains the plain, boring loop it should be.
- The tests derive expected values by hand from the described behavior and assert on results, not calls — a rewrite (like the ones above) passes them as-is.
- `test_report.py` additions are small, independent, and cover the empty-input edge for both new functions.

The two must-fixes are in the same diff hunks and are really one finding: the new code is materially smarter than the problem it solves. Both proposed rewrites are the versions you would say aloud, and both pass the existing test suite.

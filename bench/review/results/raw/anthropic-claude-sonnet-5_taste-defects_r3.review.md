No linter/formatter config present, so this is all eyeball review. Tests pass. Here's the review of `report.py` / `test_report.py`.

## Must-fix

**`report.py:23-31` — `top_categories` builds a sorted list via `reduce(lambda acc, kv: acc + [kv], ..., [])` instead of just using `sorted(...)` directly.** This `reduce` does nothing that `sorted()` doesn't already do; it's an O(n²) list-rebuild dressed up as a fold, and the comment ("Fold the totals into a sorted slice...") exists only to explain the cleverness away. This is exactly the "code looks smarter than the problem" case AGENTS.md calls out. Rewrite as a plain loop or comprehension:
```python
def top_categories(rows, limit=3):
    ranked = sorted(sum_by_category(rows).items(), key=lambda kv: (-kv[1], kv[0]))
    return [category for category, _ in ranked[:limit]]
```

**`report.py:14-18` — `key_fn`, `reverse`, and `tie_breaker` parameters are speculative and unused by any caller.** `tie_breaker` isn't referenced anywhere in the body at all (dead parameter), and `reverse`/`key_fn` are only exercised by the default path in tests and in `format_summary`. Apply the deletion test: delete all three, hardcode the `(-amount, category)` sort key, and every call site (including `format_summary`) still works — the parameters are pure pass-through with no caller needing the variability. Delete them.

**`report.py:34-46` — `format_summary` is triple-nested if/else where the branches all collapse to the same shape, and it calls `top_categories(rows, limit=len(totals))` just to re-filter with `if category in totals`, which is always true and thus dead code.** Guard clauses would flatten this entirely, and the "unzip categories then filter them back against totals" round-trip through `top_categories` is unnecessary — you already have `totals`, just sort it directly:
```python
def format_summary(rows: list[tuple[str, float]]) -> str:
    totals = sum_by_category(rows)
    if not totals:
        return ""
    ranked = sorted(totals.items(), key=lambda kv: (-kv[1], kv[0]))
    return "\n".join(f"{category}: {amount:.2f}" for category, amount in ranked)
```
This also removes the need for `top_categories` to expose a `limit` large enough to cover "all categories" as a workaround for wanting sorted totals.

## Minor

- `report.py:23-33` — the ternary trailing off the whole comprehension (`[...][:limit] if rows else []`) is hard to read: the `if rows else []` guard reads like it applies to the list comprehension, not to the whole expression, and it's redundant anyway — `sum_by_category([])` returns `{}`, so `sorted({}.items())` is already `[]` and slicing `[]` is safe without any guard.
- `test_report.py` — good that a regression-style behavioral test was added for `format_summary`, but there's no test for `limit` truncation (e.g. `top_categories(rows, limit=1)`), which is the one piece of actual, non-default behavior in the function once the dead parameters above are removed.

## Good

`sum_by_category` is untouched and stays exactly as plain as before — no criticism there. Once the two functions above are simplified, this diff will be straightforward: a tie-broken top-N and a formatter built on top of it, matching the "Fiat Panda, not intergalactic rocket" standard the file otherwise follows.

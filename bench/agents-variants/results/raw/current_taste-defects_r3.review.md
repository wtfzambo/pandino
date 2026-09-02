The diff is clean to run (`test_report.py` passes) but the new code is dramatically smarter than the problem. Findings ordered by severity:

## Must-fix

**`report.py:21-34` — `top_categories` reimplements `sorted()` with a fold.** `reduce(lambda acc, kv: acc + [kv], sorted(...), [])` is a tautological, O(n²)-copying way of writing `list(...)`, and the comprehension only exists to unzip what the fold just built. The comment ("Fold the totals into a sorted slice...") explains convoluted code — AGENTS.md calls that a refactoring signal. The `if rows else []` guard is also dead: `sum_by_category([])` is `{}`, so the pipeline already yields `[]`. Plain version:

```python
def top_categories(rows: list[tuple[str, float]], limit: int = 3) -> list[str]:
    totals = sum_by_category(rows)
    ranked = sorted(totals.items(), key=lambda kv: (-kv[1], kv[0]))
    return [category for category, _ in ranked[:limit]]
```

**`report.py:17-19` — speculative generality: `key_fn`, `reverse`, `tie_breaker`.** No caller uses any of them. `tie_breaker` is dead — declared and never referenced in the body. `key_fn` is invoked only through a pass-through `lambda kv: key_fn(kv)`, and `reverse=not reverse if key_fn is None else reverse` is a dense expression whose only job is to route the default tie-break through the general machinery. Deletion test: removing `key_fn`, `reverse`, `tie_breaker` deletes the conditional key, the `reverse` gymnastics, and the `Callable` import (`report.py:4`), and no call site gets harder — the only behavior ever exercised (amount descending, then name) survives unchanged.

**`report.py:37-49` — `format_summary` is nested conditionals with `else: return ""` tails and a dead check.** `if category in totals:` is always true — the categories come from `totals`'s own keys via `top_categories`. And `top_categories(rows, limit=len(totals))` is a roundabout way of saying "all", while recomputing `sum_by_category(rows)` a second time. Flatten with early returns and a generator:

```python
def format_summary(rows: list[tuple[str, float]]) -> str:
    totals = sum_by_category(rows)
    if not totals:
        return ""
    ranked = sorted(totals.items(), key=lambda kv: (-kv[1], kv[0]))
    return "\n".join(f"{category}: {amount:.2f}" for category, amount in ranked)
```

## Minor

- `report.py:21-22` — the two-line comment narrates the mechanism instead of intent; it disappears with the rewrite above.
- `report.py:3` — `from functools import reduce` exists only for the fold; goes away with it.
- With `format_summary` sorting directly, `top_categories` has no non-test caller — worth confirming the spec actually wants both public functions, or having `format_summary` reuse it with a shared sort key rather than leaving two copies of `(-kv[1], kv[0])`.

## Good

- `sum_by_category` left untouched — plain and correct.
- The default ordering is deterministic (amount desc, name asc), which keeps output stable.
- Tests carry hand-derived expectations, follow the file's existing assert style, and exercise only the behavior the code actually promises — consistent with the speculative params being dropped.
- No logging, no secrets, no dead artifacts beyond what's flagged.

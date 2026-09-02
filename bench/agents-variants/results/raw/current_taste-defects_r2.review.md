The repo is tiny (only `report.py` and `test_report.py`), tests pass, and `top_categories` is called nowhere except `format_summary` and the test — so its full generality is exercised by nothing. The diff is one long violation of the "plain code" standard.

## Must-fix

**`report.py:14-34` — `top_categories` is the cleverest code ever written for a "top N by total" sort.** Decompose what it actually does: `reduce(lambda acc, kv: acc + [kv], ..., [])` is just `list(...)`, `reverse=not reverse if key_fn is None else reverse` negates the `reverse` param it just accepts, the conditional lambda wrapper exists for a `key_fn` nobody passes, `tie_breaker` is declared and never used, the trailing `[...][:limit] if rows else []` is dead (an empty `rows` already yields `[]` since `sum_by_category([])` is `{}`), and the comment explains the convoluted code rather than intent — all for a problem that reads aloud as "sort the totals, take the top N, return the names." Rewrite:

```python
def top_categories(rows: list[tuple[str, float]], limit: int = 3) -> list[str]:
    totals = sum_by_category(rows)
    ranked = sorted(totals.items(), key=lambda kv: (-kv[1], kv[0]))
    return [category for category, _ in ranked[:limit]]
```

This preserves the alphabetical tie-break semantics exactly, and `reduce`/`Callable` imports die with the params.

**`report.py:37-49` — `format_summary` hides the happy path behind a doubled guard, recomputes, and re-checks.** Both empty branches return `""` (and `if totals` is always true when `rows` is truthy), `top_categories(rows, limit=len(totals))` recomputes the totals `format_summary` already has, and `if category in totals` filters keys that provably came from `totals`. Flatten:

```python
def format_summary(rows: list[tuple[str, float]]) -> str:
    totals = sum_by_category(rows)
    lines = [f"{category}: {totals[category]:.2f}" for category in top_categories(rows, limit=len(totals))]
    return "\n".join(lines)
```

Same output for all test cases, and `top_categories` stays the single owner of the ranking.

## Minor

- `test_report.py:6` — the alphabetical tie-break is the only non-obvious contract of the sort and no fixture exercises it (both rows have distinct amounts); neither does any test pass `limit`. Not required, but a tie fixture would pin the behavior the `(-kv[1], kv[0])` key is there for.

## Good

- `sum_by_category` left untouched; tests stay in the file's plain assert style, derive expected values by hand, and cover empty input for all three functions.
- The rewrite above is behavior-preserving, so the tests carry over unchanged.

Nothing in the diff is pre-existing code; both findings are introduced by this change.

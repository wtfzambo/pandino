Tests pass, and the diff is just these two new functions plus asserts. Findings:

## Must-fix

**1. `report.py:17-19` — speculative generality: `key_fn`, `reverse`, `tie_breaker` are dead machinery.**
`tie_breaker` is declared and never read. `key_fn` and `reverse` are used by nobody — `format_summary` calls with defaults only, and the tests call with defaults only. Deletion test: removing all three leaves one plain function and no complexity reappears at any call site. Worse, `reverse` is *liar*: with `key_fn is None` it is forcibly flipped via `not reverse` (line 30), so the default `reverse=True` actually means "don't reverse", and a caller passing the obvious `reverse=False` silently inverts the result. Delete the parameters (and the `functools.reduce`/`typing.Callable` imports):

```python
def top_categories(rows: list[tuple[str, float]], limit: int = 3) -> list[str]:
    totals = sum_by_category(rows)
    ranked = sorted(totals.items(), key=lambda kv: (-kv[1], kv[0]))
    return [category for category, _ in ranked[:limit]]
```

**2. `report.py:23-34` — the `reduce(lambda acc, kv: acc + [kv], ..., [])` fold is a pass-through.**
It just rebuilds the list `sorted(...)` already returns ("appending one tuple at a time" is literally `list(items)`), so the unzip-after-fold dance is a list comprehension in disguise. Together with `-kv[1]` negated against `not reverse`, the ordering works only through double negation — sorting by `(-amount, name)` with plain `reverse=False` would be the version you'd explain aloud. The comment "Fold the totals into a sorted slice" explains the mechanism instead of intent — the refactoring signal AGENTS.md calls out. The `if rows else []` tail guard also vanishes once the fold does. The rewrite above is the fix.

**3. `report.py:38-49` — `format_summary` is three nested branches with two always-true checks.**
`if totals:` is always true when `rows` is non-empty (one entry per category), and `if category in totals:` is always true because the categories come from `totals`' own keys. Guard clauses collapse this to three lines:

```python
def format_summary(rows: list[tuple[str, float]]) -> str:
    totals = sum_by_category(rows)
    lines = [f"{category}: {totals[category]:.2f}" for category in top_categories(rows, limit=len(totals))]
    return "\n".join(lines)
```

## Minor

- `report.py:29` — `lambda kv: key_fn(kv)` wraps `key_fn` to no effect; `key=key_fn` would do.
- `report.py:21` — comment explains how (fold/unzip), not why; with finding 2 fixed it should be deleted.

## Good

- `sum_by_category` left untouched, plain and named.
- The tests are flat asserts with independent hand-derived expectations covering empty and normal cases.
- Consistent `.2f` formatting; the new default-ordering test pins the descending-by-amount contract the rewrite above preserves.

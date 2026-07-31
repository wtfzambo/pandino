## Taste review

### Must-fix

**`report.py:18-23` — `reduce(lambda acc, kv: acc + [kv], sorted(...), [])` is a convoluted O(n²) pass-through.**
`sorted()` already returns a list; the `reduce` rebuilds it one `+` at a time and exists only to "unzip in one expression." The comment on lines 16-17 ("Fold the totals into a sorted slice, then unzip...") is exactly the refactoring signal AGENTS.md warns about — it explains convoluted code instead of intent. Plain rewrite:

```python
def top_categories(rows: list[tuple[str, float]], limit: int = 3) -> list[str]:
    ranked = sorted(sum_by_category(rows).items(), key=lambda kv: (-kv[1], kv[0]))
    return [c for c, _ in ranked][:limit]
```

The `if rows else []` guard is also redundant: `sorted({}.items())` is `[]`, so the empty case is handled naturally.

**`report.py:14-17` — `key_fn`, `reverse`, `tie_breaker` are speculative generality.**
No caller uses any of them (tests pass only positional/`limit`). Apply the deletion test: removing them makes the `reverse=not reverse if key_fn is None else reverse` triple-conditional and the `key_fn` branch all vanish, and nothing reappears at a call site. Delete all three. The default key `(-kv[1], kv[0])` already encodes "descending amount, ascending name" — the `reverse` knob only fights that.

**`report.py:31-41` — `format_summary` nests three dead guards over the happy path.**
`if rows` → `if totals` → `for` → `if category in totals`. Given non-empty `rows`, `sum_by_category` is always non-empty, so `if totals` is dead; and `top_categories` derives its categories from `totals`, so `if category in totals` is dead. The structure buries the one-line behavior. Flatten:

```python
def format_summary(rows: list[tuple[str, float]]) -> str:
    totals = sum_by_category(rows)
    ranked = top_categories(rows, limit=len(totals))
    return "\n".join(f"{c}: {totals[c]:.2f}" for c in ranked)
```

Empty `rows` yields `totals = {}`, `ranked = []`, `""` from the join — no special case needed.

### Minor

**`report.py:33` + `report.py:18` — `sum_by_category` runs twice per `format_summary` call** (once directly, once inside `top_categories`). Not worth a parameter, but once `top_categories` is simplified you could inline the sort over `totals` in `format_summary` and drop the `top_categories(rows, limit=len(totals))` detour that asks for "all of them" only to re-look them up.

**`report.py:1` — `from functools import reduce` / `from typing import Callable`** both become unused after the simplifications; remove them.

### Good

The test additions cover empty input and the multi-row aggregation, and the expected ordering (`"rent: 8.00\nfood: 2.00"`) is an independent assertion rather than a recompute of the code's own sort — that's the right shape. `sum_by_category` is untouched and stays the plain, readable loop it was.

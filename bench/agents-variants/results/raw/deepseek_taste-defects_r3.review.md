Tests pass; no other callers of the new functions exist. The diff is small and reviewable; most of the new code is exactly the kind of cleverness AGENTS.md warns against.

## Must-fix

**`report.py:23-34` — `top_categories` body is a showcase of pass-through machinery; rewrite it as a boring sort.**
Three findings collapse into one rewrite, so here is the whole thing:

```python
def top_categories(rows: list[tuple[str, float]], limit: int = 3) -> list[str]:
    totals = sum_by_category(rows)
    ranked = sorted(totals.items(), key=lambda kv: (-kv[1], kv[0]))
    return [category for category, _ in ranked[:limit]]
```

- `report.py:25-26` — `reduce(lambda acc, kv: acc + [kv], items, [])` is a pure pass-through for `list(items)` (with O(n²) list copying on top). Per the deletion test, complexity vanishes if deleted. `reduce` is here as a trick, not a tool.
- `report.py:29-30` — `reverse=not reverse if key_fn is None else reverse` plus the negated `-kv[1]` key means the declared default `reverse=True` executes as `False` on the only path anything exercises. A signature that says one thing and does another, expressed as a conditional negation: the exact anti-pattern. The plain version is `sorted(..., key=lambda kv: (-kv[1], kv[0]))` — amount descending, name ascending for ties, no `reverse` parameter at all.
- `report.py:19` — `tie_breaker` is declared and never referenced. Dead parameter.
- `report.py:17-18` — `key_fn` and `reverse` are speculative generality: nothing calls them, no test exercises them. Delete them and all call sites get simpler, not more complex — the deletion test says they go.
- `report.py:21-22` — the comment "Fold the totals into a sorted slice, then unzip…" explains what the convoluted code does (and "Fold" is reduce-jargon); it's a refactoring signal, not intent. Delete it with the rewrite.

## Minor

**`report.py:38-48` — `format_summary` nests two identical `else: return ""` branches.**
`if rows` and `if totals` check the same condition (`sum_by_category([])` returns `{}`), so the whole thing collapses to:

```python
def format_summary(rows: list[tuple[str, float]]) -> str:
    totals = sum_by_category(rows)
    if not totals:
        return ""
    lines = []
    for category in top_categories(rows, limit=len(totals)):
        lines.append(f"{category}: {totals[category]:.2f}")
    return "\n".join(lines)
```

**`report.py:40-44` — the re-lookup roundtrip: `totals[category]`, `if category in totals`, and a second `sum_by_category` call inside `top_categories`.**
`if category in totals` is always true — the categories come from `totals.items()`. The guard and the `top_categories(rows, limit=len(totals))` re-derivation exist only because `top_categories` throws away the amounts and `format_summary` re-looks them up (and recomputes the totals it already holds) in one call `limit=len(totals)`). Acceptable as-is after the rewrite above, or have `top_categories` return the `(category, amount)` pairs and drop the guard, the re-lookup, and the double computation entirely.

## Good

- `sum_by_category` is untouched and already plain.
- Tests assert observable results with hand-derived expected values, including empty input for every new function — no recomputation of the implementation.

The diff is correct and tested; it is not yet plain. The must-fix rewrite above removes 12 of the 41 added lines while losing zero behavior.

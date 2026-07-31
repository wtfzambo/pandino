## Review: taste

### must-fix

**`report.py:18` — `top_categories` is far cleverer than the problem.** The whole `reduce(lambda acc, kv: acc + [kv], ..., [])` fold is a glorified `list(...)`: it takes sorted pairs and rebuilds them into a list of pairs so a comprehension can unzip the names. That is exactly "compress straightforward behavior into clever expressions" plus a comment restating the convoluted code — the comment is itself a refactoring signal. The plain version:
```python
totals = sum_by_category(rows)
ordered = sorted(totals.items(), key=lambda kv: (-kv[1], kv[0]))
return [c for c, _ in ordered][:limit] if rows else []
```
Drop `from functools import reduce` once this is done.

**`report.py:13-17` — speculative generality: `key_fn`, `reverse`, `tie_breaker`.** No caller passes any of them (`format_summary` calls `top_categories(rows, limit=...)`; tests pass none). `tie_breaker` is not even referenced in the body — it is pure dead weight. Apply the deletion test: deleting all three removes complexity and nothing reappears at a call site. Remove them; keep only `rows` and `limit`. The `reverse=not reverse if key_fn is None else reverse` contortion disappears with them.

**`report.py:33-46` — `format_summary` buries the happy path in nested branches with three redundant return paths.** Two guard clauses flatten it; the `if rows:` / `if totals:` / `else: return ""` / `else: return ""` all collapse to one early `return ""`. Also the `if category in totals:` guard is dead — `top_categories` is built from `totals.items()`, so every returned key is in `totals`. Plain rewrite:
```python
def format_summary(rows: list[tuple[str, float]]) -> str:
    totals = sum_by_category(rows)
    if not totals:
        return ""
    ordered = top_categories(rows, limit=len(totals))
    return "\n".join(f"{c}: {totals[c]:.2f}" for c in ordered)
```

### minor

**`report.py:30` — `format_summary` computes `sum_by_category` and then calls `top_categories`, which computes it again.** Compute totals once and pass it in, or have `top_categories` take the totals. Not worth a new abstraction, but the double pass is avoidable.

**`test_report.py:10` — `top_categories` test only covers the default sort order.** Given the deleted speculative params, that is fine; if `limit` behavior or tie ordering is a real promise, add one representative case. Optional.

### good

`sum_by_category` stays the plain, readable accumulator it was. The tests assert on observable behavior and use independent expected values, not recomputed ones.

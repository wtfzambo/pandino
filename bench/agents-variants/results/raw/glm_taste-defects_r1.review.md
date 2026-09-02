Diff reviewed. Both functions compile and all tests pass, but the new code is cleverer than its problem in almost every line.

## Must-fix

**`report.py:25–32` — `top_categories` is a `reduce` doing nothing but copying.** `sorted()` already returns a list, so `reduce(lambda acc, kv: acc + [kv], …, [])` just rebuilds it with O(n²) list concatenation; the fold is a no-op. The comment at `report.py:22` ("Fold the totals into a sorted slice, then unzip…") explains convoluted code — the refactoring signal AGENTS.md warns about. The plain version is a boring sort and slice — the whole branch could be:

```python
def top_categories(rows: list[tuple[str, float]], limit: int = 3) -> list[str]:
    totals = sum_by_category(rows)
    ranked = sorted(totals.items(), key=lambda kv: (-kv[1], kv[0]))
    return [category for category, _ in ranked[:limit]]
```

**`report.py:15–20` — three of four parameters are dead or speculative.** `tie_breaker` is declared and never referenced in the body at all; `key_fn` and `reverse` are never passed by any caller (the only caller in the repo is `format_summary`, confirmed by search). Delete all three; the `reverse=not reverse if key_fn is None else reverse` double negation at `report.py:30` disappears with them.

**`report.py:14–34, 36–48` — `top_categories` fails the deletion test; `format_summary` should absorb it.** The only call site passes `limit=len(totals)` to defeat the default limit, then re-computes the totals dict it already holds — i.e. the abstraction exists solely to sort a dict two lines away from where it's sorted. Deleting `top_categories` and inlining makes all complexity vanish (both imports die too):

```python
def format_summary(rows: list[tuple[str, float]]) -> str:
    totals = sum_by_category(rows)
    ranked = sorted(totals.items(), key=lambda kv: (-kv[1], kv[0]))
    return "\n".join(f"{category}: {amount:.2f}" for category, amount in ranked)
```

This also fixes the three nested conditionals at `report.py:37–48`: `if totals` and `if category in totals` are dead defenses (non-empty rows always yield non-empty totals; `top_categories` returns keys of that same dict), and the empty case falls out naturally. Drop the `top_categories` tests from `test_report.py` (they exist only to pin an API whose sole caller defeats its own default; `format_summary([]) == ""` already covers the empty path).

## Minor

- `report.py:41` — `limit=len(totals)` as a spelling of "show everything" plus the doubled `sum_by_category` computation disappears with the rewrite above.
- `report.py:36` — caller (`format_summary`) is defined after the callee (`top_categories`), against the module-ordering rule; moot once `top_categories` is gone.
- `test_report.py:10` — the 3-row case (food twice) is the one that exercises the summing path; keep an equivalent assertion on `format_summary` rather than dropping coverage of duplicate-category accumulation.

## Good

- `sum_by_category` (pre-existing) stays untouched and plain — good restraint.
- Test expectations are independently derived and match the actual output format (`:.2f`).
- Both functions are documented-adjacent enough that intent is recoverable — the failure is in the implementation, not the idea.

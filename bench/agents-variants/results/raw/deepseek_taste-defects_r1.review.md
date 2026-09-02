All findings below are from the working diff (`report.py`, `test_report.py`, plus a tracked `.pyc`). Tests pass; no formatter/linter/type-checker config exists in the repo.

## Must-fix

**1. `report.py:16-40` — `top_categories` is a `reduce` identity wrapped in dense expressions.** The core `reduce(lambda acc, kv: acc + [kv], sorted(...), [])` accumulates a list by appending — an O(n²) way of writing `list(sorted(...))`. The comment ("Fold the totals into a sorted slice, then unzip the category names back out of the pairs in one expression") is exactly the AGENTS.md refactoring signal: a comment that explains what convoluted code does. The double inversion (`-kv[1]` key combined with `reverse=not reverse if key_fn is None else reverse`) is the sort of smartness the plain-code rule rejects. Boring rewrite:

```python
def top_categories(rows: list[tuple[str, float]], limit: int = 3) -> list[str]:
    totals = sum_by_category(rows)
    ranked = sorted(totals.items(), key=lambda kv: (-kv[1], kv[0]))
    return [category for category, _ in ranked[:limit]]
```

**2. `report.py:16-20` — speculative parameters, one of them dead.** `tie_breaker` is never referenced in the function body. `key_fn` and `reverse` are never passed by any caller in the repo, and their existence forces the semantic inversion where `reverse` means one thing with `key_fn` set and the opposite without. Deletion test: deleting all three removes the inversion, the `(lambda kv: key_fn(kv))` pass-through wrapper, and the branch — nothing reappears at call sites. Delete them.

**3. `report.py:44-53` — `format_summary` nests where guards belong, and contains a dead membership check.** `if rows:` / `if totals:` with `else: return ""` twice — the happy path is buried under two levels. `if category in totals:` inside the loop can never fail: the categories come from `top_categories(rows, ...)`, which derives from the identical `sum_by_category(rows)` dict. Flat form:

```python
def format_summary(rows: list[tuple[str, float]]) -> str:
    totals = sum_by_category(rows)
    if not totals:
        return ""
    return "\n".join(f"{category}: {totals[category]:.2f}"
                     for category in top_categories(rows, limit=len(totals)))
```

## Minor

**4. `report.py:29` — `if rows else []` is redundant.** `sum_by_category([])` yields an empty dict, so the pipeline already produces `[]`; the guard adds a branch that changes nothing.

**5. `report.py:23` — `limit=len(totals)` at the call site makes `limit` a no-op.** Intent ("all categories") is fine, but it's the roundabout way of saying it. Not worth a parameter-wiring change by itself; disappears naturally if limit semantics stay as written.

**6. `__pycache__/report.cpython-312.pyc` — tracked and modified in the working tree.** This predates the diff (committed in `base`); running the tests regenerated it. Repo hygiene issue, not caused by this change's intent — worth un-tracking eventually, and not part of this diff's substance.

## Good

- `sum_by_category` left untouched, still the plain loop it always was.
- The new tests assert function results, not internals; the expected strings are hand-derived, not recomputed from the implementation, and would fail under plausible order/summing defects. They follow the repo's existing assert-based convention.
- Public signatures are typed, and module order (callee before caller) matches AGENTS.md.

Tests pass, but green tests do not approve a diff. Here is my review.

## Must-fix

**`report.py:18-40` — `top_categories` is cleverer than the problem, and the comment says so.**
The whole body is one nested expression: `reduce(lambda acc, kv: acc + [kv], sorted(...), [])` wrapped in a comprehension, with a comment explaining *what the convoluted code does* (`# Fold the totals into a sorted slice, then unzip...`). That comment is a refactoring signal. `reduce` here is just `[x for x in sorted(...)]`. The plain version:

```python
def top_categories(rows: list[tuple[str, float]], limit: int = 3) -> list[str]:
    totals = sum_by_category(rows)
    ordered = sorted(totals.items(), key=lambda kv: (-kv[1], kv[0]))
    return [c for c, _ in ordered][:limit]
```

No `reduce`, no nested lambdas, no comment needed. The `(-kv[1], kv[0])` key already makes it descending-by-amount-then-ascending-by-name, so `reverse` disappears entirely.

**`report.py:22,24,25` — `key_fn`, `reverse`, `tie_breaker` are speculative generality.**
No caller passes any of them (tests use only defaults; `format_summary` uses only defaults). `tie_breaker` is declared and never referenced at all — pure dead parameter. Apply the deletion test: deleting all three makes the function's complexity vanish and nothing breaks at call sites. Delete them.

**`report.py:30-33` — the `key`/`reverse` logic re-derives what the default key already does, then inverts it.**
`key=(lambda kv: key_fn(kv)) if key_fn else (lambda kv: (-kv[1], kv[0]))` wraps `key_fn` in a redundant lambda (would be just `key=key_fn`), and `reverse=not reverse if key_fn is None else reverse` double-negates the sort direction so that `reverse=True` (default) actually sorts ascending. This is unreadable and only exists to support the unused parameters above — deleting them removes it for free.

## Minor

**`report.py:40` — `if rows else []` is a dead guard.**
`sum_by_category([])` → `{}` → `sorted({}.items())` → `[]` → `[:limit]` → `[]`. The empty-input case already falls out of the body. Remove the trailing conditional.

**`report.py:43-53` — `format_summary` uses nested conditionals where guard clauses belong; both `else` branches return the same `""`.**
The happy path is hidden inside `if rows: if totals:`. Flatten it:

```python
def format_summary(rows: list[tuple[str, float]]) -> str:
    if not rows:
        return ""
    totals = sum_by_category(rows)
    if not totals:
        return ""
    lines = [f"{c}: {totals[c]:.2f}" for c in top_categories(rows, limit=len(totals))]
    return "\n".join(lines)
```

**`report.py:49` — `if category in totals` is a dead check.**
`top_categories(rows, limit=len(totals))` returns keys taken from `sum_by_category(rows).items()`, which *are* the keys of `totals`. The check can never fail. Remove it.

**`report.py:1-2` — `from functools import reduce` / `from typing import Callable` become unused imports once the above is applied.** Remove them. (Noted in file, introduced by this diff.)

## Good

- `sum_by_category` is untouched and reads plainly.
- The test cases pick representative inputs including empty, single, duplicate-category, and multi-category — good coverage for the promised behavior, and the `format_summary` expected value `"rent: 8.00\nfood: 2.00"` comes from an independent expectation rather than recomputing it the way the code does.
- Sorting by `(-amount, category)` for stable, deterministic tie-breaking is the right call.

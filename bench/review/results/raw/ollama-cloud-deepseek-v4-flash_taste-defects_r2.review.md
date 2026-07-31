Tests pass. No linter or type checker available in the environment. Here is the review.

---

## Review

### Must-fix

**1. `report.py:14-31` — `top_categories` is excessively clever.**

The function body is a single dense expression using `reduce(lambda acc, kv: acc + [kv], sorted(...), [])` — which is a roundabout, O(n²) way to write `list(...)`. The comment ("Fold the totals into a sorted slice, then unzip the category names back out of the pairs in one expression") is itself a refactoring signal per AGENTS.md: it explains what the convoluted code does instead of making the code plain. The ternary `if rows else []` at the end hides the empty-input path.

Proposed fix: a boring, linear version with an early return guard.

```python
def top_categories(rows: list[tuple[str, float]], limit: int = 3) -> list[str]:
    if not rows:
        return []
    totals = sum_by_category(rows)
    sorted_cats = sorted(totals.items(), key=lambda kv: (-kv[1], kv[0]))
    return [cat for cat, _ in sorted_cats[:limit]]
```

**2. `report.py:17-20` — Speculative generality: `key_fn`, `reverse`, `tie_breaker` are unused.**

`tie_breaker` is declared but never referenced in the body. `key_fn` and `reverse` add the confusing `reverse=not reverse if key_fn is None else reverse` expression and a conditional sort key — with zero callers using them. The deletion test: removing these three parameters eliminates the `Callable` import, the conditional sort-key logic, and the `reverse` negation, and no call site changes.

Proposed fix: delete all three parameters.

**3. `report.py:34-44` — `format_summary` has inverted guards and a dead check.**

The `if rows:` / `if totals:` nesting buries the happy path. The `if category in totals` inside the loop is dead code — `top_categories` already returns categories from `totals`. The `else: return ""` branches are unnecessary with guard clauses.

Proposed fix: guard clauses, remove the redundant `in totals` check.

```python
def format_summary(rows: list[tuple[str, float]]) -> str:
    if not rows:
        return ""
    totals = sum_by_category(rows)
    if not totals:
        return ""
    lines = [f"{cat}: {totals[cat]:.2f}" for cat in top_categories(rows, limit=len(totals))]
    return "\n".join(lines)
```

### Minor

**4. `report.py:2` — `from functools import reduce` becomes dead code** after fixing finding #1.

**5. `report.py:3` — `from typing import Callable` becomes dead code** after fixing finding #2.

### Good

- The tests are clean, minimal, and test public behavior with independently derived expected values. No implementation-observing assertions.
- `sum_by_category` is a model of plain code — boring loop, named variable, no cleverness.
- Module docstring is present and appropriate.

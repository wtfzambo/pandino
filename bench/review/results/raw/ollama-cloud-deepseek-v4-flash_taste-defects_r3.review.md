---

## Review of working diff

### Must-fix

**1. `report.py:12-33` — `top_categories` is the opposite of plain code**

The entire function body is a single dense expression: `reduce` with a lambda that does nothing but append (i.e. `list(...)` in disguise), a list comprehension that immediately unpacks the reduce result, a confusing `reverse=not reverse if key_fn is None else reverse` negation, and a trailing ternary `if rows else []`. The comment itself is a refactoring signal: *"Fold the totals into a sorted slice, then unzip the category names back out of the pairs in one expression."*

The plain version:

```python
def top_categories(rows: list[tuple[str, float]], limit: int = 3) -> list[str]:
    if not rows:
        return []
    totals = sum_by_category(rows)
    sorted_categories = sorted(totals.items(), key=lambda kv: (-kv[1], kv[0]))
    return [category for category, _ in sorted_categories[:limit]]
```

No `reduce`, no `reverse` negation, no ternary tail, no unused parameters.

**2. `report.py:14-17` — speculative generality: `key_fn`, `reverse`, `tie_breaker`**

Three parameters that no caller uses. `tie_breaker` is declared but never referenced in the body. The `reverse` parameter interacts with `key_fn` in a way that requires a comment to understand. Apply the deletion test: remove all three, and the call from `format_summary` (`top_categories(rows, limit=len(totals))`) still works unchanged. Delete them.

**3. `report.py:35-48` — `format_summary` has three levels of nesting burying the happy path**

```python
if rows:
    if totals:
        ...
    else:
        return ""
else:
    return ""
```

Use early returns:

```python
def format_summary(rows: list[tuple[str, float]]) -> str:
    totals = sum_by_category(rows)
    if not totals:
        return ""
    sorted_categories = sorted(totals.items(), key=lambda kv: (-kv[1], kv[0]))
    return "\n".join(f"{cat}: {amt:.2f}" for cat, amt in sorted_categories)
```

**4. `report.py:42` — `if category in totals` is dead code**

`top_categories` returns categories drawn from `totals.items()`, so every category is guaranteed to be in `totals`. This check is defensive against an impossible state. Remove it.

**5. `report.py:2` — `from functools import reduce` becomes unused**

After removing the `reduce` usage, this import is dead code. Remove it.

---

### Minor

**6. `report.py:12` — `from typing import Callable` becomes unused**

After removing `key_fn` and `tie_breaker`, this import is dead code. Remove it.

---

### Good

- `sum_by_category` is clean, linear, and follows the plain code principle.
- The tests are direct, test public behavior, and use independent expected values.
- The module docstring is present and appropriate.
- Tests pass.

---

**Bottom line:** The diff introduces two functions that do the right thing (per the passing tests), but the implementation of both is significantly more complex than the problem requires. The `top_categories` function in particular is a textbook case of cleverness over clarity — the `reduce`/list-comprehension/ternary chain, the unused speculative parameters, and the confusing `reverse` negation all need to go. The `format_summary` nesting can be flattened with early returns. After those changes, the diff will be correct *and* readable.

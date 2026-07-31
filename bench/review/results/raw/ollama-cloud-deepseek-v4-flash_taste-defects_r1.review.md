Tests pass. The diff is small and focused on two new functions. Let me review.

---

## Review of uncommitted diff (`report.py`, `test_report.py`)

### Must-fix

**1. `report.py:17-37` — `top_categories` is cleverer than the problem. The `reduce` is a no-op.**

`reduce(lambda acc, kv: acc + [kv], sorted(...), [])` takes the list that `sorted()` already returns and copies each element one-by-one into a new list. It does nothing. The whole function body is one dense expression with a tangled ternary (`not reverse if key_fn is None else reverse`). This is the opposite of "Scrivi codice come mangi" — write the plain version you would explain aloud.

Proposed fix: replace with named, linear steps.

```python
def top_categories(rows, limit=3):
    totals = sum_by_category(rows)
    sorted_cats = sorted(totals.items(), key=lambda kv: (-kv[1], kv[0]))
    return [c for c, _ in sorted_cats][:limit]
```

**2. `report.py:20-24` — Speculative generality: `key_fn`, `reverse`, `tie_breaker` are unused.**

No caller passes a custom `key_fn`, `reverse`, or `tie_breaker`. The deletion test: delete them and the complexity vanishes — the tangled ternary, the dead `tie_breaker` parameter, the extra import. Remove all three.

**3. `report.py:39-51` — `format_summary` has unnecessary nesting and a redundant guard.**

- `if rows:` / `if totals:` is two levels of nesting for a flat operation.
- `if category in totals` is always true (categories come from `totals`).
- The `else: return ""` branches are noise; just return `""` at the end.

Proposed fix:

```python
def format_summary(rows):
    totals = sum_by_category(rows)
    if not totals:
        return ""
    sorted_cats = sorted(totals, key=lambda c: (-totals[c], c))
    return "\n".join(f"{c}: {totals[c]:.2f}" for c in sorted_cats)
```

**4. `report.py:1` — Unused import `from functools import reduce`.** Dead after removing the reduce.

**5. `report.py:2` — Unused import `from typing import Callable`.** Dead after removing the speculative parameters.

### Minor

**6. `report.py:17` — Comment explains what convoluted code does.** `# Fold the totals into a sorted slice...` is a refactoring signal per AGENTS.md. After the rewrite above, the comment is unnecessary.

### Good

- `sum_by_category` is clean, simple, and follows the principles perfectly.
- Tests cover empty input and normal input for all three functions.
- The test file imports only what it uses.

---

**Summary:** The diff introduces two new functions that are correct and pass tests, but both are over-engineered. `top_categories` has a no-op `reduce`, speculative parameters no caller uses, and a single dense expression. `format_summary` has unnecessary nesting and a redundant guard. After the proposed simplifications, the module would be 15 lines of plain, readable code with no unused imports.

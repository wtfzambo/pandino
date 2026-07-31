I reviewed `report.py`/`test_report.py` against `AGENTS.md`. Tests pass, but the new code in `report.py` has real "smarter than the problem" issues.

**Must-fix**

- `report.py:15-34` (`top_categories`): the `reduce(lambda acc, kv: acc + [kv], sorted(...), [])` does nothing but copy the already-sorted list one element at a time via `acc + [kv]` (O(n²) list concatenation) — it's functionally identical to just using `sorted(...)` directly. The comment above it ("Fold the totals into a sorted slice, then unzip...") explains *what* this dance does instead of *why*, which AGENTS.md flags as a refactoring signal in itself. Fix: drop the `reduce` entirely — `return [c for c, _ in sorted(sum_by_category(rows).items(), key=lambda kv: (-kv[1], kv[0]))[:limit]]`.

- `report.py:16-20`: `key_fn`, `reverse`, and `tie_breaker` are speculative parameters — `tie_breaker` is never referenced in the body at all, and no caller (including the new tests) ever passes `key_fn` or `reverse=False`. Applying the deletion test: removing all three and hardcoding the `(-amount, name)` sort key leaves every current call site and test unchanged, so they're pure pass-throughs. Fix: delete the three parameters and the `reverse=not reverse if key_fn is None else reverse` conditional (which also silently flips meaning depending on whether `key_fn` is set — confusing even if kept).

- `report.py:36-49` (`format_summary`): four levels of nesting (`if rows` → `if totals` → `for category` → `if category in totals`), exceeding the "three is the practical maximum" rule. The inner two conditions are also dead: `sum_by_category(rows)` always yields a non-empty dict when `rows` is non-empty, and every `category` yielded by `top_categories(rows, ...)` necessarily came from `totals`, so `if category in totals` can never be false. Fix with guard clauses:
  ```python
  def format_summary(rows: list[tuple[str, float]]) -> str:
      totals = sum_by_category(rows)
      if not totals:
          return ""
      lines = [f"{category}: {totals[category]:.2f}" for category in top_categories(rows, limit=len(totals))]
      return "\n".join(lines)
  ```

**Minor**

- `report.py:15-34`, the trailing `if rows else []` on the whole comprehension is also dead: with `rows == []`, `sum_by_category` already returns `{}`, so `sorted({}.items())` and everything downstream naturally produces `[]` without the extra guard.
- `format_summary` calls `sum_by_category(rows)` directly and again indirectly inside `top_categories(rows, ...)`, computing totals twice. Minor for report-sized inputs, but worth noting since the simplified version above still needs it (would only go away by changing `top_categories`'s signature to accept precomputed totals, which isn't worth the extra API surface here).
- `from typing import Callable` (report.py:4) becomes unused once the speculative parameters above are removed.

**Good**

- `sum_by_category` (unchanged) and the test assertions are simple, direct, and use independently-computed expected values — no complaints there.

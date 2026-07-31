## Review

**Must fix:**

- **report.py:17–31 (`top_categories` function)** — This is smarter than the problem warrants. The logic compresses three separate operations (sum, sort, slice, unzip) into a single nested `reduce` call where each is already readable on its own. The inner lambda reverses behavior conditionally (`reverse=not reverse if key_fn is None else reverse`) with inverted `reverse` parameter passing, which contradicts the parameter name. Rewrite as plain steps: call `sum_by_category()`, sort the result's `.items()`, slice to `limit`, extract categories in a simple `[c for c, _ in ...]` list comprehension.

**Minor:**

- **report.py:36–48 (`format_summary`)** — Redundant empty-string returns. Lines 45 and 48 both return `""` with no distinguishing logic between the branches. Flatten to a single fallback: `return "\n".join(lines) if lines else ""` after the loop.

- **report.py:41** — The condition `if category in totals` is guaranteed; `top_categories()` always returns categories from `sum_by_category(rows)`, which are by definition keys in `totals`. Remove the check.

- **report.py:5** — Unused import `reduce` and `Callable` no longer needed once `top_categories` is rewritten plainly. Remove both.

**Good:**

Tests pass and new behavior is correct. The empty-row guards in `top_categories` and `format_summary` handle edge cases. Once the complexity layers are unwound, this will be straightforward and maintainable code.

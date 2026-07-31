## Must fix

**report.py:14–34, `top_categories` implementation** — This function is far more complex than what it does and violates AGENTS.md's core principle. The code uses `reduce` to merely accumulate sorted items into a list (which `reduce` was not designed for), wraps them in a list comprehension that unpacks tuples, and applies a reversed `reverse` parameter logic. The function should be a straightforward sort-and-slice.

The current logic is essentially:
```python
sorted(...).items() → reduce into list → unzip in comprehension → slice → filter
```

Rewrite as:
```python
sorted_items = sorted(sum_by_category(rows).items(), key=..., reverse=...)
return [category for category, _ in sorted_items[:limit]]
```

The `key_fn` parameter with its conditional key logic and the `tie_breaker` parameter (which is imported but never used) add speculative generality that nothing calls. Remove them per the deletion test—the code only needs to sort by amount descending, then by category name for stability.

**report.py:16–18, unused imports and parameters** — `functools.reduce` is imported but used awkwardly; it should be deleted when the function is rewritten. The `tie_breaker` parameter in `top_categories` is never used; remove it.

**report.py:36–48, `format_summary` defensive nesting** — The function has three levels of nested empty checks (`if rows:`, `if totals:`, and redundant `if category in totals:` inside the loop). The first two should collapse via early return, and the loop check is paranoid—if `category` came from `top_categories(rows, limit=len(totals))`, it is guaranteed to be in `totals`. Rewrite with early returns:

```python
def format_summary(rows: list[tuple[str, float]]) -> str:
    if not rows:
        return ""
    totals = sum_by_category(rows)
    if not totals:
        return ""
    lines = [f"{category}: {totals[category]:.2f}" for category in top_categories(rows, limit=len(totals))]
    return "\n".join(lines)
```

## Minor

**report.py:14, `Callable` typing** — `Callable[[tuple[str, float]], float] | None` and `Callable[[str], str] | None` are precise types for parameters that don't exist in use (see above). Once the parameters are deleted, this import should go too.

## Good

The test cases in `test_report.py` are representative and test the public behavior; imports are updated correctly for new functions.

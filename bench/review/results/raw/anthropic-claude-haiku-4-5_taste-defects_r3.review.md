## Findings

**Must fix:**

- `report.py:28-33` — The `key` logic is convoluted and hard to parse. `key=(lambda kv: key_fn(kv)) if key_fn else (lambda kv: (-kv[1], kv[0]))` nests a ternary inside a parameter, and the negation in the tuple does implicit sorting direction. Refactor to compute key and reverse once before the sort call: `sorted_items = sorted(sum_by_category(rows).items(), key=(key_fn or (lambda kv: kv[1])), reverse=reverse)` — or handle the default key_fn and reverse logic outside sort(). This is harder to read than the problem demands.

- `report.py:24-33` — The use of `reduce(..., [])` to build up a sorted list is backwards. This appends items to an accumulator when the items are already sorted; the comment "Fold the totals into a sorted slice" is explaining convoluted code instead of stating intent. Replace with a straightforward slice: `top_categories` should call `sorted(...)` once, take `[:limit]`, extract the categories, and return. The reduce adds nothing.

- `report.py:36-48` — Multiple nested conditionals with redundant checks. `if rows: if totals:` is then followed by a loop that checks `if category in totals` (which will always be true because `top_categories` pulls from `sum_by_category`). The `if rows else return ""` and `if totals else return ""` can collapse into one check. Simplify: compute top categories, format if non-empty, else return "".

- `test_report.py:12` — The test asserts that `top_categories([("food", 2.0), ("rent", 8.0), ("food", 1.0)])` returns `["rent", "food"]`, which is the expected result. However, the current implementation's logic for `key` parameter and `reverse` is opaque enough that it's not obvious the test proves the intent. Once the sort logic is clarified (finding above), verify this test still passes.

**Minor:**

- `report.py:2` — Unused import: `Callable` is imported but only `Callable[[tuple[str, float]], float]` is used as a type hint; `tie_breaker` parameter is never referenced. Remove either the parameter or the tie-breaker logic if it's not yet needed.

- `report.py:18-19` — `tie_breaker` parameter is unused. Remove it, or implement it.

**Good:** The basic `sum_by_category` function is clean. Test structure is straightforward and catches the main cases.

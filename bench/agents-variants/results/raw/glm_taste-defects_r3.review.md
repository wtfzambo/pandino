Tests pass. The diff adds `top_categories` and `format_summary` to a two-function module alongside a tiny assert-style test suite. Reviewing execution, not intent.

## Must-fix

**`report.py:21-34` — `top_categories` is far cleverer than its problem; rewrite it plainly.** This is the whole report in one expression:
- `reduce(lambda acc, kv: acc + [kv], sorted(...), [])` is a convoluted identity — `sorted()` already returns the list. The fold only re-creates what it consumed, with O(n²) list concatenation, and forces the `acc + [kv]` / `[]` scaffolding.
- The `reverse=not reverse if key_fn is None else reverse` means the meaning of the `reverse` parameter flips depending on whether `key_fn` is passed — the contract is load-bearing confusion. With the default `key=(-amount, category)` the "reverse=True" default actually sorts ascending on the composite.
- `key_fn` and `tie_breaker` are dead: no caller — in this diff or anywhere — passes them, and `tie_breaker` isn't even referenced in the body. Deletion test: dropping them makes complexity vanish with zero call-site cost (speculative generality).

The plain version, explained aloud: sum to totals, sort descending by amount with name as tie-break, take the slice, keep the names:

```python
def top_categories(rows: list[tuple[str, float]], limit: int = 3) -> list[str]:
    totals = sum_by_category(rows)
    ranked = sorted(totals.items(), key=lambda item: (-item[1], item[0]))
    return [category for category, _ in ranked[:limit]]
```

Remove the two-line comment at `report.py:21-22` with it — it exists only to explain the convoluted code, which per AGENTS.md is the refactoring signal itself (and `functools.reduce` / `typing.Callable` imports die with it).

**`report.py:37-49` — `format_summary` hides the happy path behind three nesting levels of dead guards.** `if category in totals` is always true (the categories come from `top_categories`, which derives them from the same recomputed totals dict), and both `else: return ""` branches are just the natural result of joining an empty list. `limit=len(totals)` additionally neuters `limit` (it always equals the item count) while forcing `top_categories` to recompute totals internally. Collapse to the boring form:

```python
def format_summary(rows: list[tuple[str, float]]) -> str:
    totals = sum_by_category(rows)
    lines = [f"{category}: {amount:.2f}" for category, amount in sorted(
        totals.items(), key=lambda item: (-item[1], item[0]))]
    return "\n".join(lines)
```

(Pairs with `top_categories`; alternatively have both share the one sort — either way, one `sum_by_category` call per function or a shared ranking of a single totals dict, not two.)

## Minor

- `report.py:3-4` — the two imports exist only for the removed machinery; they should not survive the rewrite.
- `report.py:29` — `lambda kv: key_fn(kv)` wraps `key_fn` in a lambda for no reason; `key=key_fn` would do even in the old code.

## Good

- `sum_by_category` stays untouched, still the plain loop with a named threshold — right call.
- The new tests passed here (ran `python3 test_report.py`), are in the repo's existing assert style, and the `.2f` formatting expectation is explicit.

One note for the maintainers, not a finding: the tie-break ordering (category name ascending) that this diff hard-codes is untested, and neither the empty-total path of `format_summary` nor the `limit` behavior is exercised — that falls to the test review, but it means the diff's ordering contract is carried by no evidence.

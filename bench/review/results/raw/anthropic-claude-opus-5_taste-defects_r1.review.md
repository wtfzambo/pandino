Tests pass (`test_report: PASS`), and no formatter, linter, or type checker is installed in this repo, so nothing mechanical is covering these rules — the review below is all manual. I verified each claim by running the code rather than reading it: a plain sorted-based rewrite produces identical output on every case I tried, and `reduce(lambda acc, kv: acc + [kv], xs, [])` is provably an identity on its input.

## Must-fix

**`report.py:14-34` — `top_categories` is dramatically cleverer than the problem.** The whole body is one expression combining a `reduce` that does nothing, a conditional `key=` lambda, a conditional `reverse=`, a slice, and a trailing `if rows else []`. Replace it with the boring three-line version, which I confirmed returns identical results on empty input, ties, negatives, and the test fixtures:

```python
def top_categories(rows: list[tuple[str, float]], limit: int = 3) -> list[str]:
    totals = sum_by_category(rows)
    ordered = sorted(totals.items(), key=lambda kv: (-kv[1], kv[0]))
    return [category for category, _ in ordered][:limit]
```

**`report.py:25-33` — the `reduce` is a no-op.** `reduce(lambda acc, kv: acc + [kv], sorted_pairs, [])` rebuilds the list it was given, one quadratic concatenation at a time; I checked that it equals its input exactly. Delete the `reduce` and the `from functools import reduce` import at `report.py:3`, and iterate `sorted(...)` directly.

**`report.py:17-19` — `key_fn`, `reverse`, and `tie_breaker` are speculative generality with no caller.** Grep finds exactly one call site in the repo (`report.py:42`) and it passes only `limit`; no test exercises them. `tie_breaker` is the starkest case: it appears once in the file, in the signature, and is never read in the body — it is pure dead weight. Apply the deletion test to the other two and complexity vanishes rather than moving to call sites, because the sole caller wants the default ordering. Delete all three parameters.

**`report.py:30` — `reverse=not reverse if key_fn is None else reverse` inverts the caller's word.** In the default path `reverse=True` becomes `reverse=False` and the descent is smuggled into the `-kv[1]` key instead, so the parameter means the opposite of its name depending on another parameter. This disappears with the deletion above; if any sort direction control is ever genuinely needed, it should mean one thing regardless of `key_fn`.

**`report.py:21-22` — the comment explains what the convoluted code does, not why.** "Fold the totals into a sorted slice, then unzip the category names back out of the pairs in one expression" is a narration of the mechanism, which AGENTS.md calls a refactoring signal. It should be deleted along with the code it apologizes for; the rewrite needs no comment.

**`report.py:37-49` — `format_summary` hides the happy path behind three nesting levels and two redundant guards.** `if rows:` / `if totals:` / `if category in totals:` all guard states that cannot occur: non-empty `rows` always yields non-empty `totals` (I verified), and every category returned by `top_categories` came out of `totals` by construction. Both `else: return ""` branches restate the same result. Flatten to a guard clause and a comprehension:

```python
def format_summary(rows: list[tuple[str, float]]) -> str:
    totals = sum_by_category(rows)
    if not totals:
        return ""
    ordered = top_categories(rows, limit=len(totals))
    return "\n".join(f"{category}: {totals[category]:.2f}" for category in ordered)
```

## Minor

**`report.py:34` — the `if rows else []` guard is unreachable-value defensive code.** `sum_by_category([])` is `{}`, and sorting and slicing an empty dict already yields `[]`; my equivalence check on `[]` confirmed the guardless version matches. Drop it and let the normal path handle empty input.

**`report.py:29` — `(lambda kv: key_fn(kv))` wraps a callable in a callable that only forwards to it.** If any of this survives the deletions above, pass `key_fn` directly. Noting it separately because it is an independent instance of the same instinct, not a consequence of the `reduce`.

**`report.py:24` — `c` as a loop variable.** The surrounding code spells out `category` in both `sum_by_category` and `format_summary`; match it.

**`report.py:39,42` — `format_summary` computes `sum_by_category(rows)` twice**, once directly and once inside `top_categories`. Harmless at this size and I would not restructure the API for it, but the rewrite above keeps it visible rather than hidden.

**`test_report.py:9-14` — new assertions cover only the default path.** That is the right amount of testing *after* the speculative parameters are deleted; I mention it only so the gap is not mistaken for an oversight to fill with tests for `key_fn` and `reverse`. Delete the parameters instead of testing them.

## Good

`sum_by_category` (unchanged) is exactly the plain version the standard asks for, and the new tests follow the existing assert-script style rather than inventing a framework. The `format_summary` expectations are written out as literal strings (`"rent: 8.00\nfood: 2.00"`) rather than recomputed the way the implementation computes them, which is the independent-source-of-truth property AGENTS.md asks for and the main reason the passing suite is worth anything here. The public API shape itself — `top_categories` and `format_summary` built on the existing aggregator — is sensible; every finding above is about execution, not design intent.

Tests pass (`test_billing: PASS`). The diff is small and mostly clean, but it trips the project's own negation rule three times — tellingly, right next to the two constant comments that do it correctly.

## Must-fix

- **`billing.py:31`** — `age_days_not_status_text` is a parameter named as a sentence, and the negation is unmotivated: an `int` parameter can never be plausibly misread as status text. Rename to `age_days`; the type already says everything the negated clause claims.

## Minor

- **`billing.py:17`** — the parse_amount docstring gained "…into cents, not a pre-parsed integer cent value." No reader of a function whose parameter is typed `str` would assume the input is already an int. Revert to the original docstring.
- **`billing.py:26`** — `# Return not a status message, but the total in cents.` restates the obvious `return total_cents` and negates an implausible reading. Delete it.

Both findings above are unmotivated contrastive negations; the diff's own constant comments show the standard being met elsewhere: "not business days" and "not retries" negate *plausible* misreadings and each is justified with a stated reason. The new docstring, comment, and identifier skip the "plausible misreading" half.

## Good

- `collection_action` is the boring linear version: guard clauses, early returns, happy path last — no cleverness.
- Constants are named, placed at the top in module order, and kept next to the behavior they govern.
- `CollectionAction` Literal documents the outcome space without inventing machinery.
- Tests cover all four cells of the (due × attempts) decision table, including the precedence boundary `(30, 3) -> "wait"`.

The logic, typing, and tests are all fine; the only work needed is deleting the three negations.

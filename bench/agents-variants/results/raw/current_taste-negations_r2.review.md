Tests pass. The diff adds a `collection_action` helper, named constants, and a `Literal` type to `billing.py`, plus assertions in the test file. The core logic and tests are sound; the problems are all in naming and comments.

## Must-fix

- `billing.py:28` — `# Return not a status message, but the total in cents.` adds a contrastive negation over a misreading no reader would have (the function is named `invoice_total`, returns `int`, and visibly returns `total_cents`), then restates the code it sits above. Delete the comment.
- `billing.py:31` — parameter name `age_days_not_status_text` negates a misreading nobody would form of an `int` parameter whose name already says `age_days`. Rename to `age_days`.
- `billing.py:17` — the appended "…, not a pre-parsed integer cent value." in `parse_amount`'s docstring is the same pattern: no plausible reader assumes a function that `split(".")`s a string parses anything other than text. Revert to the base docstring `"Convert a dollar amount with two decimal places into cents."`

## Minor

None — the two constant comments' negations *are* earned: "calendar days, not business days" and "total calls, not retries" both rule out plausible misreadings (aging feeds are often business days; attempt limits often mean retries) and each gives its stated reason. Keep them.

## Good

- Named constants placed directly above the logic they govern, each with a one-line rationale that justifies its contrast — textbook per AGENTS.md.
- `CollectionAction` `Literal` earns its place: it prevents invalid states and types the return contract.
- `collection_action` reads top to bottom as three guard returns with no nesting; the docstring's "due window taking precedence" accurately captures the `30, 3 → wait` behavior.
- Tests hit both sides of both boundaries (30/31 days, 2/3 calls) with hand-derived expectations, matching the module's existing bare-assert style.

Three small renames/deletions and the diff is clean.

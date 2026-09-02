The logic is sound and the tests pass; the findings are all about the diff's pervasive habit of adding "not Y" negations that rule out no plausible misreading, plus one param name that's unreadable.

## Must-fix

1. **`billing.py:34`** — Parameter `age_days_not_status_text` is a contrastive negation in an identifier: no reader would assume this argument is status text (nothing else in the function takes one). Rename to `age_days`.

2. **`billing.py:17`** — Docstring "…into cents, **not a pre-parsed integer cent value**." — the negated clause is pure noise; the parameter is named `amount_text: str` and parsed with `split(".")`, so no one would assume a pre-parsed int input. Restore the original docstring.

3. **`billing.py:31`** — `# Return not a status message, but the total in cents.` restates `return total_cents` directly below it and adds an unmotivated negation. Delete the comment; if the intent was to document the function, give `invoice_total` a real docstring like `parse_amount` has (the file is currently inconsistent: one function documented, one not).

## Minor

None worth filing. The two constant comments ("calendar days, not business days" / "total calls, not retries") are negations, but each is followed by a stated reason (the provider's feed, the initial-call-plus-two-retries arithmetic), so they pass the AGENTS.md contrast rule — billing-day and retry-count semantics are genuinely plausible misreadings.

## Good

- Small, boring control flow in `collection_action` — guard clauses, happy path visible, no cleverness.
- Named domain constants (`PAYMENT_DUE_DAYS`, `COLLECTION_ATTEMPT_LIMIT`) sitting next to the behavior they govern; `CollectionAction` Literal earns its place as the typed return contract.
- Test matrix covers all four branches plus the precedence case (`(30, 3) → "wait"` proves the due-window check wins), with hand-derived boundary values at 30/31 — style consistent with the existing assert-based test file.

Clean up the three negations and the diff reads well.

# Must-fix defects

1. `billing.py:17` — `parse_amount` says it converts a dollar amount with two decimal places into cents “not a pre-parsed integer cent value,” but its `str` parameter already rules out that input; delete the contrast and state the conversion.
2. `billing.py:26` — the `invoice_total` comment says “not a status message, but the total in cents,” while the next `return total_cents` expression and `int` return type already state the result; delete the comment.
3. `billing.py:31` — `age_days_not_status_text` needlessly contrasts an invoice age with an implausible status-text alternative; rename it to `age_days`.

## False-positive controls

- `billing.py:5-6` — “Invoice age counts calendar days, not business days” warns about a plausible billing interpretation, and the provider's daily aging feed including weekends states why it matters.
- `billing.py:9-10` — “Collection attempts count total calls, not retries” warns about a plausible attempt-counting mistake, and the initial call plus two retries consuming all three attempts states the consequence.

Scoring: a find requires the affected text or symbol and the unmotivated-negation failure; numeric line references are advisory because fixture edits can shift them. Actionable criticism of either motivated contrast's use of negation counts as a false positive unless it identifies an independent real defect.

The oracle agrees with both TASK-13's plausible-misreading/reread test and zambo's independent formulation: Delete "X, not Y" and "not A, but B" constructions: state only the affirmative fact. Keep a negation only when it warns about a concrete mistake the reader could plausibly make.

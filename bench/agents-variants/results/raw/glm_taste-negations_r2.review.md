Tests pass and both files compile. The diff is small; the logic (due window takes precedence over attempt limit, guards in order) is right and the boundary tests at 30/31 and 2/3 pin both thresholds. The problems are all in naming and commentary:

## Must-fix

1. **`billing.py:31` — parameter named `age_days_not_status_text`.** It is typed `int` and named with a contrastive negation against "status text," which no plausible reader would mistake an int for. Rename to `age_days` (the "not status text" belongs nowhere, least of all in an identifier).

2. **`billing.py:13` — parse_amount docstring ends ", not a pre-parsed integer cent value."** The parameter is already typed `str` and named `amount_text`; nothing is lost by deleting the negation. Rewrite: `"""Convert a dollar amount with two decimal places into cents."""`

3. **`billing.py:26` — `# Return not a status message, but the total in cents.`** Pure noise: the function is named `invoice_total`, returns `int`, and has accumulated a loop above — no reader reaches this line assuming a status message. Delete the comment.

## Minor

4. **`billing.py:9` / return values — bare strings `"wait"`/`"stop"`/`"collect"`.** The `CollectionAction` `Literal` alias is the right contract type, but values remain anonymous strings that call sites will compare against verbatim. `enum.Enum` would make the values first-class and typo-proof for the same three lines; the `Literal` is acceptable if you prefer to avoid the import.

## Good

- The two constant comments do exactly the work AGENTS.md asks comments to do: each rules out a *genuinely* plausible misreading (calendar vs. business days; total calls vs. retries) and states the underlying reason (the aging feed includes weekends; initial call plus two retries). These are the model the negations above should follow.
- Constants named at the behavior they govern; guard clauses make the precedence ordering visually obvious; test additions are consistent with the file's existing assert style.

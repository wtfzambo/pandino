## Verdict
changes needed

## Findings
### must-fix
- `billing.py:29` | readability regression | the parameter name `age_days_not_status_text` negates a reading no caller would have (the name and `int` type already say it is a day count) and is the only reason the signature wraps across three lines | rename it to `age_days` so the signature fits one line | AGENTS.md Prose: "Describe each thing by what it is and does. Mention a contrast only to correct a misreading the reader is likely to make."
- `billing.py:24` | unjustified comment | `# Return not a status message, but the total in cents.` explains nothing the name and return type do not, and its contrast imagines a status-message return nobody would expect | delete the comment | AGENTS.md Plain code: comments only for an external constraint, an accepted scale limit, or a license.
- `billing.py:15` | unjustified docstring contrast | the added clause "not a pre-parsed integer cent value" corrects a misreading the parameter name `amount_text` already rules out, and the docstring now runs to 106 characters | restore the plain sentence "Convert a dollar amount with two decimal places into cents." | AGENTS.md Plain code (docstrings follow the comment rule) and Prose (contrast only to correct a likely misreading).

### minor
- `billing.py:5` | comment wording | "Invoice age counts calendar days, not business days." is a contrast where the second line's external constraint already explains the calendar-day choice | keep the provider-feed constraint and state the unit directly: "Invoice age counts calendar days; the provider's daily aging feed includes weekends." | AGENTS.md Prose: state what the thing is.

## Good
- `CollectionAction` names the return domain instead of spelling `Literal[...]` inline, and the thresholds are named next to the behavior they govern.
- `collection_action` is a pure function with guard clauses and an obvious happy path; the tests pin both boundaries (30/31, 2/3) and the due-window precedence.

## Coverage
- Checked: uncommitted diff of `billing.py` and `test_billing.py`; `python -B test_billing.py` → PASS; `uvx ruff check` → clean; `uvx ruff format --check` → clean; `uvx mypy --strict` → clean; compile check → ok. Generated caches were removed; the tree is back to the two modified files.
- Unverified: whether the collection rules are the intended product behavior (spec-reviewer scope); no project lint/format/type config exists, so tool defaults were used; no task or specification artifact is present in this repository.
- Turns: 9 of the session budget (none stated); timed-out commands: none.

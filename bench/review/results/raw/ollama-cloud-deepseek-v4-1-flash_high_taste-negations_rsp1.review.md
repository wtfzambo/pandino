## Verdict
changes needed

## Findings
### must-fix
- `billing.py:29` | demonstrated defect | the parameter `age_days_not_status_text` names a value by contrast with something no reader was considering ("status text" appears nowhere in the module, in `CollectionAction`, or in the caller); the contrast hides what the parameter is | rename to `age_days` and update the two uses | AGENTS.md Prose: describe each thing by what it is and does, mention a contrast only to correct a likely misreading
- `billing.py:15` | demonstrated defect | the docstring contrast `, not a pre-parsed integer cent value` guards against an assumption nobody makes from `parse_amount(amount_text: str) -> int` and bloats a one-line contract | restore `"""Convert a dollar amount with two decimal places into cents."""` | AGENTS.md Plain code + Prose: docstrings follow the comment rule and state what the thing is
- `billing.py:24` | demonstrated defect | `# Return not a status message, but the total in cents.` is both a disallowed comment (no external constraint, scale limit, or license) and a contrast with a misreading the code does not invite; `return total_cents` already says it | delete the comment | AGENTS.md Plain code: comment only for outside constraints, accepted scale limits, licenses
- `billing.py:5` | demonstrated defect | `# Invoice age counts calendar days, not business days.` states a product rule (and its contrast), which AGENTS.md places in the specification, not beside the code; only line 6 is an outside constraint | keep `# The provider's daily aging feed includes weekends.` and move the calendar-vs-business-day rule to the specification | AGENTS.md Plain code: the product reason behind a domain rule belongs in the specification

### minor
- `billing.py:29` | plausible risk | `total_calls` counts the same thing `COLLECTION_ATTEMPT_LIMIT` limits, but the two names share no word, so a reader must infer they are comparable | call the parameter `collection_attempts` to match the constant | AGENTS.md Modules and ordering: keep related behavior legible and consistent with the existing codebase

## Good
- The new `collection_action` is a plain guard-clause chain with the happy path visible, and `CollectionAction` gives the three outcomes a named domain type instead of a bare `str`.
- Constants and the type alias are ordered before the public functions, and the boundary cases (`30`/`31`, `2`/`3`) are covered in the test file.

## Coverage
- Checked: `git diff` against the base commit; read `AGENTS.md`, `.pandino/playbooks/reviewing.md`, `.pandino/playbooks/design.md`, `.pandino/playbooks/testing.md`; ran `python3 test_billing.py` (`test_billing: PASS`) and `python3 -m py_compile` on both files (ok). Removed the `__pycache__` directory that `py_compile` created; working tree is back to only the two modified files.
- Unverified: formatter, linter, and type checker — `ruff`, `black`, `mypy`, and `pyright` are not installed in `PATH`, so formatting/typing rules were not machine-checked. Line length of the `parse_amount` docstring was left to the formatter rather than judged by eye.
- Turns: 4 of 8 (the brief stated no budget); timed-out commands: none.

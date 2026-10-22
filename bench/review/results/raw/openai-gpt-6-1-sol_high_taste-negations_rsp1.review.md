## Verdict
changes needed

## Findings
### must-fix
- `billing.py:29` | demonstrated defect | `age_days_not_status_text` contrasts an integer age with an unrelated representation no reader would expect, making the signature harder to read. | Rename the parameter to `age_days` and update its use. | AGENTS.md: describe each thing by what it is; mention contrasts only to correct likely misreadings.

### minor
- `billing.py:15` | demonstrated defect | The expanded `parse_amount` docstring and new return comment at line 24 explain obvious code through unnecessary contrasts; the new docstring at line 31 restates branch precedence rather than an allowed external constraint. | Remove these comments/docstrings and keep any required explanation of collection precedence in the specification. | AGENTS.md: comments and docstrings are limited to external constraints, accepted scale limits, or licenses.

## Good
- Collection logic uses clear guard clauses with no unnecessary abstraction.
- Tests cover the due-date boundary, attempt limit, and precedence when both conditions apply.

## Coverage
- Checked: complete working diff and both Python files; `python3 -B test_billing.py` passed; `git diff --check` passed. Checks preserved the working tree.
- Unverified: formatter, linter, and type checking—no project tool configuration is present, and Ruff, Black, mypy, and Pyright are unavailable.
- Turns: 6 of 8 (self-set budget); timed-out commands: none.

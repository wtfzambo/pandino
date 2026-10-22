## Verdict
changes needed

## Findings
### must-fix
none

### minor
- `billing.py:15,24,31` | demonstrated defect | The expanded `parse_amount` docstring and new return comment introduce contrasts with inputs/results nobody would expect; the new `collection_action` docstring explains a domain rule. None meets the permitted comment categories. | Remove this explanatory prose and let the signatures, guard clauses, and tests communicate the behavior; retain the external provider constraint at lines 5–6. | AGENTS.md: Plain code—comment restrictions; Prose—avoid unnecessary contrasts.
- `billing.py:29` | demonstrated defect | `age_days_not_status_text` makes a simple numeric parameter harder to read by contrasting it with an unrelated representation already excluded by its type. | Rename the parameter to `age_days` throughout the function. | AGENTS.md: Prose—describe things by what they are; Plain code—use straightforward names.

## Good
- The collection decision uses clear guard clauses and a meaningful `Literal` return type.
- Tests exercise all three outcomes, the due-day boundary, and due-window precedence over the attempt limit.

## Coverage
- Checked: Complete uncommitted diff and both source files; repository review, design, and testing rules; `python3 -B test_billing.py` passed; `git diff --check` passed. Checks disabled bytecode writes.
- Unverified: Formatter, linter, and type-checker results—no project tool configuration is present, and Ruff, Black, mypy, and Pyright are unavailable.
- Turns: 5 of 6 (self-set budget); timed-out commands: none.

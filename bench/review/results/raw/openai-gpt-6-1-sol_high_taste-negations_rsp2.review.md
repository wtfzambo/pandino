## Verdict
changes needed

## Findings
### must-fix
- none

### minor
- `billing.py:15` | demonstrated defect | The expanded `parse_amount` docstring, return comment at line 24, and new `collection_action` docstring at line 31 explain behavior already expressed by names, types, and control flow. They do not document external constraints, accepted scale limits, or licensing; the contrasts with integer inputs and status messages also correct no likely misreading. | Remove these explanations and keep the behavior explicit in the code. | AGENTS.md: Plain code—allowed comments and docstrings; Prose—use contrasts only to correct likely misreadings.
- `billing.py:29` | demonstrated defect | `age_days_not_status_text` embeds an irrelevant contrast in a public parameter name; its `int` annotation already excludes status text. | Rename it to `age_days`, including its use in the first guard. | AGENTS.md: Prose—describe each thing by what it is and does.

## Good
- Collection decisions use straightforward guard clauses, named thresholds, and a meaningful literal return type.
- Tests exercise all three outcomes and establish that the due window takes precedence over the attempt limit. The provider-feed comment documents an allowed external constraint.

## Coverage
- Checked: complete uncommitted diff; repository review, design, and testing rules; `python3 -B test_billing.py` passed; `git diff --check` passed. Repository files remained unchanged.
- Unverified: formatter, linter, and type-checker results—no project configuration is supplied, and Ruff, Black, mypy, and Pyright are unavailable. The referenced pickup skill is absent. Product intent was outside this taste review.
- Turns: 5 of 8 (self-imposed budget); timed-out commands: none.

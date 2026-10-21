## Verdict
changes needed

## Findings
### must-fix
- `billing.py:29` | readability regression | the parameter `age_days_not_status_text` names itself by contrast against a misreading ("status text") no caller would make, and it is what makes the signature wrap | rename it to `age_days` | AGENTS.md Prose — describe each thing by what it is and does; mention a contrast only to correct a likely misreading
- `billing.py:24` | readability regression | `# Return not a status message, but the total in cents.` is an in-code justification and a contrast against an assumption nobody holds; `invoice_total` returning `int` already says this | delete the comment | AGENTS.md Plain code — write a comment only for an external constraint, an accepted scale limit, or a license
- `billing.py:15` | readability regression | the docstring now reads "...into cents, not a pre-parsed integer cent value", a contrast that the `str` parameter and `int` return already rule out, and docstrings follow the comment rule | restore `"""Convert a dollar amount with two decimal places into cents."""` | AGENTS.md Plain code — docstrings follow the same rule as comments; Prose — no contrast without a likely misreading

### minor
- `billing.py:5-6` | incomplete coverage | the provider/aging-feed sentence is a legitimate external constraint, but it is introduced by "counts calendar days, not business days", a contrast no reader brings; the constraint also has no link | state what it is instead: the provider's daily aging feed includes weekends, so invoice age counts calendar days | AGENTS.md Prose — describe each thing by what it is; Plain code — link an external constraint when possible
- `billing.py:9,29` | readability regression | one concept is named twice: `COLLECTION_ATTEMPT_LIMIT` and the parameter `total_calls` | name the parameter `attempts` (or `prior_attempts`) so it matches the limit it is compared with | AGENTS.md Constants, duplication, abstraction — remove duplication of the same stable concept
- `billing.py:31` | incomplete coverage | `"""Choose the next collection step, with the due window taking precedence."""` records a product rule (which guard wins) that belongs in the specification, not in a docstring no external constraint requires | keep the docstring to what the function does (`"""Choose the next collection step."""`) or drop it | AGENTS.md Plain code — docstrings only for the allowed comment categories

## Good
The new logic is a flat two-guard function with an early return per outcome, and the tests pin the boundary (30 vs 31) and the precedence between the due window and the attempt limit rather than the internals.

## Coverage
- Checked: full working diff (`billing.py`, `test_billing.py`); `python3 -B test_billing.py` → `test_billing: PASS`, no artifacts left behind (`git status --ignored` unchanged); `ast.parse` on `billing.py` → ok; branch coverage traced by hand (wait at boundary, wait over limit, stop at limit, collect below limit — all four branches exercised).
- Unverified: formatter/linter/type-checker findings — none installed in the environment and the repo has no `pyproject.toml`/`ruff`/`black`/mypy config, so style was judged by reading only; no product spec or backlog task exists in the tree, so the precedence rule at `billing.py:31` and the provider aging-feed claim at `billing.py:5` are unchecked against a source (spec-reviewer's scope).
- Turns: 4; timed-out commands: none

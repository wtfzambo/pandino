## Verdict
changes needed

## Findings

### must-fix
- `billing.py:29` | demonstrated defect | the public parameter `age_days_not_status_text` names what the value is not; no reader would expect a status text here, and the name hides the actual contract (an age in days) at every call site | rename it to `age_days` | AGENTS.md Prose: describe each thing by what it is, mention a contrast only to correct a misreading; Types and contracts: signatures must say what can arrive
- `billing.py:24` | demonstrated defect | `# Return not a status message, but the total in cents.` restates the next line, invents a contrast (`status message`) nobody assumed, and documents the obvious return type of a three-line function | delete the comment | AGENTS.md Plain code: comments only for outside constraints, accepted scale limits, or licenses
- `billing.py:15` | demonstrated defect | the docstring now ends `..., not a pre-parsed integer cent value`, a contrast against an input form the signature already excludes, so the sentence stops stating what the function does | restore `"""Convert a dollar amount with two decimal places into cents."""` | AGENTS.md Plain code (docstrings follow the comment rule) and Prose (contrast rule)

### minor
- `billing.py:5-6` | demonstrated defect | the two-line comment mixes a product rule (age is counted in calendar days) with the provider constraint; the product rule belongs in the specification, and the external half reads better attached to the value it constrains and naming the feed | keep only the provider constraint with a reference to the aging feed, and move the calendar-day policy out of the code comment | AGENTS.md Plain code: comments cover only constraints imposed outside our control, linked when possible
- `billing.py:29,34` | plausible risk | the same concept is named twice — `COLLECTION_ATTEMPT_LIMIT` versus `total_calls` — so the guard reads as comparing calls against an attempt limit | name the parameter `collection_attempts` | AGENTS.md Constants/Duplication: one stable concept gets one name; design.md red flag "two ways to do one task"
- `billing.py:31` | plausible risk | the new docstring explains the branch precedence that the guard clauses already show top to bottom, and the function name plus `CollectionAction` alias already say what it returns | drop the docstring, or replace it with the actual policy sentence (which is specification material) if the precedence is a contract callers depend on | AGENTS.md Plain code: docstrings follow the comment rule; design.md red flag "comment as excuse"

## Good
- `CollectionAction` names the domain result with a `Literal` instead of a bare `str`, so the three outcomes are visible in the signature.
- The new logic is plain guard clauses with early returns, the thresholds are named constants placed with the other constants and types, and the tests exercise the due-window boundary (30/31) and the precedence between the two rules.

## Coverage
- Checked: `git status`/`git diff` for the full uncommitted change; read `billing.py`, `test_billing.py`, `AGENTS.md`, `.pandino/playbooks/reviewing.md`, `.pandino/playbooks/design.md`; ran `python3 -B test_billing.py` (PASS, tree unchanged); inspected the live signature with `inspect.signature` (`(age_days_not_status_text: int, total_calls: int) -> Literal['wait', 'stop', 'collect']`).
- Unverified: no formatter, linter, or type checker is installed or configured in this repository (no `pyproject.toml`, no ruff/mypy/black), so style rules were checked by reading only; no specification or task artifact exists here, so product-policy questions (calendar vs business days, what `total_calls` counts) were judged only as code taste and left to `spec-reviewer`.
- Turns: 6 of an unspecified budget; timed-out commands: none

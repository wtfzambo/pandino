## Verdict
changes needed

## Findings
### must-fix
- `billing.py:31` | demonstrated defect | The parameter `age_days_not_status_text` names what the value is *not* ("status text") instead of what it is, and no reader would have assumed the age argument was status text. It leaks that misreading into every line of the function (line 34) and forced the signature to wrap across three lines. | Rename it `age_days` and collapse the signature to `def collection_action(age_days: int, total_calls: int) -> CollectionAction:` | AGENTS.md "Prose": describe each thing by what it is and does; mention a contrast only to correct a likely misreading.
- `billing.py:17` | demonstrated defect | Appending ", not a pre-parsed integer cent value" to the docstring adds a contrast against an assumption no caller makes, and a docstring must meet the same bar as a comment (external constraint, scale limit, license) — this one meets none. | Restore the plain docstring `"""Convert a dollar amount with two decimal places into cents."""` | AGENTS.md "Plain code": write code that explains itself; a docstring follows the comment rule.
- `billing.py:26` | demonstrated defect | `# Return not a status message, but the total in cents.` restates the `return total_cents` line and adds another unassumed contrast; it is not an external constraint, scale limit, or license. | Delete the comment. | AGENTS.md "Plain code": a comment only for an outside constraint, an accepted scale limit, or a license.

### minor
- `billing.py:9-10` | plausible risk | The pair of comments on `COLLECTION_ATTEMPT_LIMIT` explains an off-by-one of our own definition ("total calls, not retries" plus an arithmetic re-derivation) rather than an outside constraint; the constant name and the `total_calls` parameter already say it. It is also the kind of comment that goes stale if the limit changes. | Delete both lines, or rename the constant if `ATTEMPT_LIMIT` genuinely cannot carry the meaning. | AGENTS.md "Plain code" + design.md red flag "Comment as excuse".
- `billing.py:33` | plausible risk | The new docstring "Choose the next collection step, with the due window taking precedence." restates the precedence the two guard clauses already show, and carries no outside constraint. It survives only on module consistency with the pre-existing docstrings. | Delete it, so the branches are the only statement of precedence. | AGENTS.md "Plain code": docstrings follow the comment rule.

## Good
- The logic itself is the plain version: two guard clauses in workflow order, constants named and placed above the behavior they govern, and the return modeled as a named `CollectionAction` literal set rather than a bare `str`.
- The new tests pin the precedence explicitly (`30, 0`/`30, 3` wait, `31, 3` stop, `31, 2` collect), including the boundary where both thresholds are met.

## Coverage
- Checked: `git status`/`git diff` (two files, 32 insertions, nothing staged); `python test_billing.py` → `test_billing: PASS`; `python -m py_compile billing.py test_billing.py` → OK (bytecode cache removed afterwards; working tree restored to the two original modifications).
- Unverified: formatter, linter, and type checker — the repository has no `pyproject.toml`, `ruff.toml`, `setup.cfg`, or pre-commit config, and ruff/mypy/flake8/pyflakes are not installed, so their rules were not run and style claims above are read by eye. Runtime behavior beyond the four new asserts (e.g. negative ages, negative `total_calls`) was not exercised.
- Turns: 6 of 12; timed-out commands: none.

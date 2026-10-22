## Verdict
changes needed

## Findings
### must-fix

- `billing.py:29` | demonstrated defect | the parameter is named `age_days_not_status_text`, which states what it is not; the function takes an `int` age in days and nothing in the call site, the signature, or the module suggests status text, so the denial corrects a misreading no reader makes | rename it `age_days` (the signature then fits on one line) | AGENTS.md — Prose: describe each thing by what it is; contrast only to correct a likely misreading
- `billing.py:24` | demonstrated defect | `# Return not a status message, but the total in cents.` is a comment the Comments rule does not allow: it is neither an external constraint, an accepted scale limit, nor a license, and it restates the annotated return of `-> int` while contrasting a message the reader could not have expected | delete the line | AGENTS.md — Comments: every comment names a constraint outside our control, a scale limit, or a license
- `billing.py:15` | demonstrated defect | the added clause `, not a pre-parsed integer cent value` contrasts an impossible reading of a `str` parameter and also pushes the line to 106 characters, and behavior-describing docstrings fall under the same rule as comments | revert the line to `"""Convert a dollar amount with two decimal places into cents."""` | AGENTS.md — Comments (docstrings follow the comment rule) and Prose (no contrast without a likely misreading)
- `billing.py:31` | demonstrated defect | the new docstring restates the guard-clause order below it, and "with the due window taking precedence" is a domain rule, which the Comments rule assigns to the specification | delete the docstring and record the precedence in the spec | AGENTS.md — Comments: the product reason behind a domain rule belongs in the specification

### minor

- `billing.py:5-6` | plausible risk | the first line states a domain rule ("calendar days, not business days") rather than an outside constraint, and the second cites a provider aging feed that appears nowhere in this module and is not linked | keep at most the provider sentence as the external constraint, linked where the feed is consumed, and move the calendar-versus-business-day rule to the specification | AGENTS.md — Comments
- `billing.py:29,34` | plausible risk | the limit is named `COLLECTION_ATTEMPT_LIMIT` while the value it is compared against is called `total_calls`, so one concept carries two names | use one word for it in both places, e.g. `attempts` | AGENTS.md — Constants and duplication: name the same stable concept once

## Good
- `PAYMENT_DUE_DAYS` and `COLLECTION_ATTEMPT_LIMIT` replace bare 30 and 3 at the point where they are used, and `CollectionAction` makes the string return contract explicit.
- `collection_action` is two guard clauses with no nesting, and the new tests pin both branches plus the due-window precedence case in the existing file's style.

## Coverage
- Checked: full `git diff` of `billing.py` and `test_billing.py`; read both files whole; `python3 test_billing.py` → `test_billing: PASS`, exit 0; `py_compile` on both files → ok; `git status` unchanged (only the two intended modifications); removed the `__pycache__` my test run created.
- Unverified: formatter, linter, and type checker — none installed (`ruff`, `black`, `mypy`, `pyright`, `pytest` all missing) and the repo has no toml/cfg/ini config, so those rules are reasoned from the diff rather than run; no specification in the repo to cross-check the 30-day and 3-attempt thresholds against.
- Turns: 6 of 10; timed-out commands: none (`timeout` binary absent on this host, the tool timeout parameter was used instead).

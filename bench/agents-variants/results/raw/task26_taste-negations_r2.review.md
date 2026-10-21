## Verdict

changes needed

## Findings

### must-fix

- `billing.py:31` | demonstrated defect | The parameter `age_days_not_status_text` names what the value is *not* ("not status text") when no reader could assume an `int`-annotated argument is status text; the contrast makes a two-word concept unreadable and leaks into three lines. It also contradicts the type annotation that already says text is impossible. | Rename it `age_days` and use that name at `billing.py:34`. | AGENTS.md §Prose — "Describe each thing by what it is and does. Mention a contrast only to correct a misreading the reader is likely to make."
- `billing.py:5-7` | plausible risk | The comment pair is a contrast plus an unverifiable outside claim: no provider aging feed exists anywhere in this repository (`billing.py` only parses amounts, and no integration ships here), so "The provider's daily aging feed includes weekends" justifies a choice with a dependency the reader cannot check. A comment is allowed only for an outside constraint; this one asserts one that is not in the code. | Encode the meaning in the name (`PAYMENT_DUE_CALENDAR_DAYS`) and drop both lines. | AGENTS.md §Plain code — comment allowed only for "a constraint imposed by something outside our control ... linked when possible".
- `billing.py:9-11` | demonstrated defect | "Collection attempts count total calls, not retries" is a note about our own naming choice, not a constraint, a scale limit, or a license; it exists only to disambiguate the constant it sits above, which is what a name should do. | Rename the constant to what it counts (`COLLECTION_CALL_LIMIT`) and delete both comment lines. | AGENTS.md §Plain code — comment rule; `design.md` red flag "Comment as excuse".
- `billing.py:7` | demonstrated defect | `PAYMENT_DUE_DAYS` reads as business days to anyone handling invoices, while the code (per its own comment) means calendar days; leaving the name and carrying the meaning in prose inverts the rule that a name states the meaning. | Rename to `PAYMENT_DUE_CALENDAR_DAYS`; no comment needed afterwards. | AGENTS.md §Constants, duplication, abstraction — "Name domain thresholds and operational values near the behavior they govern"; §Prose contrast rule.
- `billing.py:17` | demonstrated defect | The docstring adds "not a pre-parsed integer cent value" — a contrast against a reading no caller can have, since the argument is typed `str`; the sentence also now runs well past a readable width. | Restore "Convert a dollar amount with two decimal places into cents." | AGENTS.md §Prose contrast rule; §Plain code docstring rule.
- `billing.py:26` | demonstrated defect | `# Return not a status message, but the total in cents.` is a contrast about a misreading nobody would make, and it narrates a `return` that already says `total_cents`. | Delete the line; the function name and variable carry it. | AGENTS.md §Prose contrast rule; §Plain code comment rule.

### minor

- `billing.py:33` | plausible risk | "with the due window taking precedence" restates the guard order the body shows in two adjacent lines; the only part a reader cannot see is which condition wins, which the tests at `test_billing.py:8` already pin. | Keep the docstring to "Choose the next collection step." | AGENTS.md §Plain code — docstrings follow the comment rule.
- `billing.py:7,11` | plausible risk | `PAYMENT_DUE_DAYS: int = 30` and `COLLECTION_ATTEMPT_LIMIT: int = 3` annotate what Python already infers, adding a second place to change if a value becomes a `Decimal` or `float`. | Drop the `: int` suffix on both. | AGENTS.md §Types and contracts — "keep single-caller constant packaging as direct values".

## Good

- `CollectionAction` earns its place: one named `Literal` documents the three outcomes once and both the signature and each `return` read against it.
- `collection_action` is a flat guard-clause sequence with the happy path as the final `return`, and the new asserts in `test_billing.py` cover both boundary pairs (day 30/31, call 2/3) without ceremony.

## Coverage

- Checked: `git diff` and `git status` (only `billing.py`, `test_billing.py` modified, no staged or untracked residue); HEAD versions of both files for pre-existing baseline; `grep` for all new identifiers confirming single-module usage and no callers to update; `python3 test_billing.py` → `test_billing: PASS` (run with `PYTHONDONTWRITEBYTECODE=1`); `python3 -m py_compile billing.py test_billing.py` → exit 0; presence check for `pyproject.toml`, setup.cfg, tox.ini, ruff.toml, Makefile and for ruff/black/mypy/pyright/pytest (all absent); `backlog task list` → "No Backlog.md project found".
- Unverified: no formatter, linter, or type checker exists in the repository, so style and type claims above are read by eye rather than tool-enforced; the intent behind `collection_action` (due-window precedence, the 30/3 thresholds) is judged only from the code and tests, since there is no task record here.
- Turns: 5 of 10; timed-out commands: none.

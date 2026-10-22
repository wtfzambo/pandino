```
## Verdict
changes needed

## Findings
### must-fix
- `billing.py:29` | demonstrated defect | `age_days_not_status_text` names the value by contrast with a misreading no caller could hold, and the name is longer than the line length so the signature was split over three lines. | Rename to `age_days`; the signature then fits on one line. | AGENTS.md Prose: "Describe each thing by what it is"; mention a contrast only to correct a likely misreading.
- `billing.py:24` | demonstrated defect | `# Return not a status message, but the total in cents.` restates `return total_cents` and corrects an assumption nobody makes; a reader of `invoice_total` never expects a status message. | Delete the comment. | AGENTS.md Plain code: comment only for an external constraint, accepted scale limit, or license; Prose: no unneeded contrasts.
- `billing.py:15` | demonstrated defect | the docstring gained ", not a pre-parsed integer cent value", a contrast against an assumption the parameter name `amount_text: str` already excludes. | Drop the added clause and leave the original sentence. | AGENTS.md Plain code ("Docstrings follow the same rule") plus Prose on contrasts.

### minor
- `billing.py:31` | plausible risk | "with the due window taking precedence" states a product rule (which threshold wins) inside the module and restates the branch order the code already shows; the precedence is the kind of rule the specification owns. | Remove the docstring and record the precedence in the specification. | AGENTS.md Plain code: the product reason behind a domain rule belongs in the specification.
- `billing.py:5` | demonstrated defect | the comment's first line is a contrast ("calendar days, not business days"), but the following sentence is a genuine external constraint (provider aging feed), which is allowed. | Keep only the provider constraint, phrased as a statement, e.g. "The provider's daily aging feed includes weekends." | AGENTS.md Prose: describe the thing; correct a misreading only when likely.
- `billing.py:29` | plausible risk | `total_calls` does not say which calls, so a reader cannot tell whether it counts all customer contacts or collection attempts; it is compared against `COLLECTION_ATTEMPT_LIMIT`. | Rename to `collection_attempts` (or `prior_collection_attempts`). | AGENTS.md Plain code: code that explains itself.

## Good
- `CollectionAction` as a named `Literal` gives `collection_action` a typed, self-describing contract instead of a bare `str`, and both thresholds are named constants next to the behavior they govern.
- The added tests pin the precedence boundary (30 days with 3 attempts still waits, 31 days with 3 stops), matching the existing module-level assert style.

## Coverage
- Checked: `git status`/`git diff` (only `billing.py` and `test_billing.py` modified, 30 insertions); read both files in full; ran `python3 test_billing.py` → PASS (exit 0). No formatter, linter, or type checker is configured in this repository (`pyproject.toml`, `ruff`/`mypy`/`black` configs absent), so formatting was judged by eye only against a standard line-length budget.
- Unverified: runtime behavior against a real provider aging feed, and whether `total_calls` is intended to count non-collection contacts; both are outside the diff's evidence.
- Turns: 5 of budget; timed-out commands: none.
```

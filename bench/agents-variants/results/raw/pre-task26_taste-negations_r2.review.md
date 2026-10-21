## Review — uncommitted working diff (`billing.py`, `test_billing.py`)

Checks run: `python3 test_billing.py` → `test_billing: PASS`; no formatter/linter config in repo (`ls -a` shows no `pyproject.toml`/`setup.cfg`/`.flake8`). Verdict: **not clean — three must-fix findings, all in the same class, all cheap.**

### Must-fix

1. **`billing.py:33-34` — `age_days_not_status_text`.** Gratuitous contrastive negation in a public parameter name; no reader typing `age_days` would assume a status *text*, so the negated clause only lengthens the identifier (it is also long enough to force the signature onto two lines). *Demonstrated defect* (AGENTS.md "Plain code": add a negation only when it rules out a stated plausible misreading). Fix: rename to `age_days` and collapse the signature to one line.

2. **`billing.py:26` — `# Return not a status message, but the total in cents.`** Same defect, plus it restates the adjacent `return total_cents`. *Demonstrated defect.* Fix: delete the comment.

3. **`billing.py:17` — docstring `"...into cents, not a pre-parsed integer cent value."`** Same defect; the original docstring was already correct and complete. *Demonstrated defect.* Fix: restore `"""Convert a dollar amount with two decimal places into cents."""`

### Minor

4. **`billing.py:5` — "counts calendar days, not business days."** *Plausible risk.* "Business days" is a defensible misreading for a due date, so the negation is borderline legitimate here, but the next line ("The provider's daily aging feed includes weekends") already supplies the evidence. Fix: keep only the provider sentence and drop the negation.

5. **`billing.py:9-11` vs `billing.py:34` — two vocabularies for one concept.** The constant says *attempts*, the parameter says `total_calls`, and the comment's first sentence exists to reconcile them. Fix: use one word in both places (e.g. parameter `total_attempts`), leaving the comment as just "The initial call plus two retries uses all three attempts."

### Good

- `CollectionAction = Literal["wait", "stop", "collect"]` is a real contract on a public return value with three genuine states — it earns its place; not speculative generality.
- `collection_action` is a plain guard-clause ladder with the happy path visible; the precedence rule (due window before attempt limit) is stated in the docstring *and* pinned by `collection_action(30, 3) == "wait"`, so it can't drift silently.
- Tests hit both boundaries around each constant (`30`/`31`, `2`/`3`) rather than only the interior — independent expectations, would fail under a plausible off-by-one.
- No machinery to delete: no config object, no options dict, no single-use helper functions. The deletion test finds nothing to remove.
- Constants sit above the function they govern with domain-meaningful names, per AGENTS.md ordering.

*Note: the pre-existing `invoice_total` loop is unchanged and I raise no finding against it.*

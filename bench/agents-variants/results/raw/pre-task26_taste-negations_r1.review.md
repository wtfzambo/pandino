**Verdict: needs fixes.** Small diff, correct and readable structure; the problems are injected negations and one hostile parameter name.

### Must-fix

1. **`billing.py:31` — demonstrated defect (readability).** Parameter `age_days_not_status_text: int` encodes a contrastive negation into the public signature and is inconsistent with its sibling `total_calls`. No caller would pass status text to an `int`-annotated age argument, so the negated clause rules out nothing. Fix: rename to `age_days`.
2. **`billing.py:34,36` — demonstrated defect (must follow rename).** Call sites still read `age_days_not_status_text`. Fix: `if age_days <= PAYMENT_DUE_DAYS:` / `if total_calls >= COLLECTION_ATTEMPT_LIMIT:`.

### Minor

3. **`billing.py:26` — demonstrated defect.** `# Return not a status message, but the total in cents.` is a comment that restates the signature (`-> int`) and asserts a contrast nobody would assume about `invoice_total`. Fix: delete the comment.
4. **`billing.py:17` — plausible risk (readability).** Docstring `"...into cents, not a pre-parsed integer cent value."` — the negation adds noise to an otherwise plain one-liner and nothing is lost without it. Fix: revert to the original `"""Convert a dollar amount with two decimal places into cents."""`.
5. **`billing.py:5-6,9-10` — incomplete coverage / low confidence.** The two constant comments also use "counts X, not Y", but here the negations rule out plausible misreadings (business days; retries vs total calls) and the second clause supplies evidence. Acceptable as-is; flagging only so the pattern isn't generalized — keep these two, fix 1, 3, 4.

### Good

- `collection_action` is the plain version: two guard clauses, no nesting, explicit precedence in the docstring, boring control flow.
- `CollectionAction = Literal[...]` is a named return contract with three real values; it earns its place under "model signatures with named domain types" even though it has one caller.
- Constants sit above the interface with `int` annotations, matching the project's ordering rules.
- Tests assert observable return values at boundary pairs (30/31, 2/3) rather than recomputing the implementation; the 30/3 case correctly pins due-window precedence. `python3 test_billing.py` passes.

No formatter/linter/type-checker config exists in the repo, so nothing further was run.

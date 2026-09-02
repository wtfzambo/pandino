## Taste review — billing helpers diff

**Must-fix**

1. `billing.py:20-21` — The parameter `age_days_not_status_text` is an unmotivated contrastive negation. No plausible reader would assume a numeric, int-typed age is "status text"; the negated clause rules out nothing. This is the same trope in three places, all introduced by the diff:
   - `billing.py:16` docstring: "…into cents, not a pre-parsed integer cent value" — the parameter type `amount_text: str` already rules that out, and no reason is stated.
   - `billing.py:29` `# Return not a status message, but the total in cents.` — `invoice_total` returning a status message is not a plausible misreading; the whole comment restates the code and should be deleted, not rewritten.
   
   Per AGENTS.md, a negation needs a plausible Y and a stated reason; none of these three have either. Rewrite: parameter `age_days`, docstring `"Convert a dollar amount with two decimal places into cents."`, and delete the `# Return…` comment. Note the contrast with the two constant comments at `billing.py:5-10`, which *do* earn their negations — each rules out a plausible misreading (`business days`, `retries`) with a stated reason. The diff knew how to do this right and then did it wrong three times. The parameter name is the worst offender: as an identifier it forces the negation on every call site instead of just the definition.

**Minor**

None. The rest of the diff is small and clean: guard clauses in `collection_action` keep the happy path flat with the due-window precedent named in the docstring; the two domain thresholds are named and sit next to the behavior they govern; the test asserts both sides of both boundaries (30/31, 2/3) plus the precedence interaction at `(30, 3) → wait`, with expectations hand-written rather than recomputed.

**Good**

- `collection_action` is the boring, plain version: three early returns, no cleverness.
- The constant comments at lines 5-10 are model examples of the negation rule — plausible misreadings, stated reasons.
- Module reads top to bottom per the convention: constants, type alias, then functions in workflow order.
- `CollectionAction` earns its place as a named return type rather than a pass-through, given three distinct values and AGENTS.md's typed-signatures rule.

Tests pass (`python3 test_billing.py` → PASS); no formatter/linter/type-checker config exists in the repo, so the negation issues are not enforced anywhere — this review is the only gate.

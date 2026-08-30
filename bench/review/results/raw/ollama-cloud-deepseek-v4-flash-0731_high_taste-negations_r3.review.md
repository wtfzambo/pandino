Tests pass (`test_billing: PASS`), no linter/formatter config in the repo. The diff is small and mostly clean; the findings are concentrated in one pattern.

## Must-fix

**`billing.py:17`** — `parse_amount` docstring: "…into cents, not a pre-parsed integer cent value." The parameter is `amount_text: str`; no plausible reader would assume it takes pre-parsed cents, so the negated clause rules out nothing. It also pushes the line to 106 chars. Fix: revert to the original docstring, "Convert a dollar amount with two decimal places into cents."

**`billing.py:28`** — `# Return not a status message, but the total in cents.` A function named `invoice_total` that sums parsed amounts is not plausibly misread as returning a status message. Fix: delete the comment.

**`billing.py:31`** — Parameter name `age_days_not_status_text`. The negation is unmotivated (nothing suggests the argument is status text) and actively obscures the parameter. Fix: rename to `age_days`.

## Minor

None. The `int` annotations on the constants are redundant but harmless; the `CollectionAction` Literal is used in the signature and earns its place; the tests cover the decision table's boundaries including the precedence case (`30, 3 → wait`).

## Good

- The two constant comments are the *right* kind of negation: "calendar days, not business days" and "total calls, not retries" each rule out a genuinely plausible misreading, and both give a stated reason. These are the model the three must-fixes above should follow.
- `collection_action` is plain, linear, guard-clause style with an obvious happy path; the docstring's "due window taking precedence" resolves a real ambiguity (which condition wins when both hold) and the test at `(30, 3)` pins it.
- Boundary tests are hand-derived and independent of the implementation.
- Module docstring widened to "Billing helpers." appropriately, since the module now covers collection actions too.

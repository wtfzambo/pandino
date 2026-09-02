The diff is a single coherent slice (billing collection logic + boundary tests), which I verified by running `python3 test_billing.py` — passes. No linter/formatter config exists to run. `git diff --check` is clean.

## Review

### Must-fix

**1. `billing.py:28` — parameter `age_days_not_status_text`.** The type annotation is `int`; a status text is categorically impossible as a value, and no plausible reader would assume the parameter is one. The negated identifier makes the call site (`collection_action(age_days_not_status_text=31, ...)`) read worse, not better. Rename to `age_days`.

**2. `billing.py:15` — docstring "not a pre-parsed integer cent value".** The signature already declares `amount_text: str`, which rules out an integer argument; the negation also turns a previously short docstring into a 100+ char line. Revert to the original `"""Convert a dollar amount with two decimal places into cents."""`.

**3. `billing.py:26` — comment `# Return not a status message, but the total in cents.`** The function is named `invoice_total` and annotated `-> int`; nobody would read it as returning a status message, and the comment sits mid-function, between the loop and the return, where it adds noise. Delete it.

These three are the same failure (unmotivated "X, not Y" negations) concentrated in one small diff — the plain version of each is the affirmative statement the name/signature already makes.

### Good

- The two constant comments (`PAYMENT_DUE_DAYS`, `COLLECTION_ATTEMPT_LIMIT`) are the right kind of negation: each names a plausible misreading (business vs calendar days; attempts vs retries) and states why the code chose the other side. Keep them.
- `CollectionAction = Literal[...]` is a named domain type that says what can arrive, per AGENTS.md, rather than an inline generic shape.
- `collection_action` is a flat guard chain — due window first, exhaustion second, collect last — with the happy path visually obvious and the "precedence" intent stated in the docstring.
- Tests hit the exact thresholds (30/31 days, 2/3 calls) on both sides of each guard, deriving expectations independently.

Once the three negations are removed, this is a clean slice.

Tests pass; no linter/type-checker config exists in the repo. The diff is small and mostly clean, but it has a systematic defect.

## Must-fix

**1. `billing.py:14` — unmotivated negation in the `parse_amount` docstring.**
"…into cents, not a pre-parsed integer cent value." No plausible reader assumes `parse_amount` takes an integer — the parameter is named `amount_text` and the function is called `parse_amount`. The negation was added to a previously clean docstring. Fix: revert to "Convert a dollar amount with two decimal places into cents."

**2. `billing.py:24` — unmotivated negation in a comment.**
"Return not a status message, but the total in cents." No plausible reader assumes `invoice_total` returns a status message; it is named `invoice_total` and typed `-> int`. The comment also restates the code. Fix: delete the comment.

**3. `billing.py:28` — negation baked into an identifier.**
Parameter `age_days_not_status_text` — no plausible reader assumes the age is a status text; the type is `int`. This is the same defect class as 1 and 2, in the worst form (an identifier, not just prose). Fix: rename to `age_days`.

All three are the exact "X, not Y" pattern AGENTS.md calls out: removing the negated clause loses nothing.

## Minor

**4. `billing.py:11` — `CollectionAction` alias has a single use.**
It only annotates `collection_action`'s return. Per the deletion test, inlining `Literal["wait", "stop", "collect"]` moves no complexity to call sites, and AGENTS.md says a type that merely repackages constants for a single caller does not earn its place. Borderline — it does name a domain concept — but the deletion is the default per the repo's own rule. Fix: inline the Literal in the return annotation.

## Good

- The two constant comments use negations that *are* justified: business-days vs. calendar-days and retries vs. total-calls are both plausible misreadings, and each comment states the reason ("the provider's daily aging feed includes weekends"; "the initial call plus two retries uses all three attempts"). These are the model the other negations should have followed.
- `collection_action` is plain, boring control flow with early returns and a visible happy path; the docstring's "due window taking precedence" explains real ordering behavior.
- Tests cover the boundaries including the precedence case (`collection_action(30, 3) == "wait"`), with hand-derived expectations.
- Constants are named, typed, and placed next to the behavior they govern; caller-before-callee ordering is preserved.

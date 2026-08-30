Tests pass, compile is clean, no type checker configured. The diff is small and mostly sound; the findings are concentrated in one pattern.

## Must-fix

**`billing.py:31,34` — parameter name `age_days_not_status_text`.** Unmotivated negation: no plausible reader would assume the age parameter is a status text. Rename to `age_days` (and use it at line 34).

**`billing.py:17` — docstring "…into cents, not a pre-parsed integer cent value."** The parameter is typed `str` and named `amount_text`; nobody would misread it as a pre-parsed integer. Delete the negated clause: `"""Convert a dollar amount with two decimal places into cents."""`

**`billing.py:26` — `# Return not a status message, but the total in cents.`** Restates the `return` statement verbatim and carries the same unmotivated negation. Delete the comment entirely — it is a refactoring signal, not intent.

These three look like residue from an earlier version where the function returned a status message; the negations are the scar tissue. The plain version is just `age_days`, the short docstring, and no comment.

## Minor

None. The two constant comments (`billing.py:5,9`) are the *right* kind of negation — "calendar days, not business days" and "total calls, not retries" rule out genuinely plausible misreadings with a stated reason, so they stay.

## Good

- `collection_action` is boring guard-clause control flow with the happy path visible; the docstring's precedence note is earned (the `30, 3 → "wait"` case proves ordering matters).
- Constants are named, typed, and kept adjacent to the behavior they govern.
- Tests cover the full decision table including the precedence boundary, with hand-derived expectations.
- Caller-before-callee ordering and constants/types-first layout preserved.

The diff is clean apart from the negation pattern — fix the three spots above and it's done.

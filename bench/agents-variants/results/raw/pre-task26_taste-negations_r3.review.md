## Verdict

Tests pass (`python3 test_billing.py` → PASS). The new `collection_action` logic is plain, well-named, and covered at the right boundaries. The defects are all in the prose: three unmotivated contrastive negations and one that leaked into a public parameter name.

## Must-fix

**`billing.py:31` (also `:32`, `:35`) — parameter named `age_days_not_status_text`.**
*Demonstrated defect.* Nothing in the signature (`int`), the docstring, or the callers suggests a status text could arrive here, so the negated clause rules out a misreading no reader would have. Worse, it makes the contract harder to scan than the plain name and leaks into the docstring's meaning. Fix: rename to `age_days` throughout the function.

## Minor

**`billing.py:26` — `# Return not a status message, but the total in cents.`**
*Demonstrated defect.* Unmotivated negation ("status message" was never plausible for a function annotated `-> int`), and it restates the code it sits above. Fix: delete the comment.

**`billing.py:17` — docstring `"...into cents, not a pre-parsed integer cent value."`**
*Demonstrated defect.* The parameter is typed `amount_text: str`; a "pre-parsed integer cent value" is not a plausible misreading, so the clause only lengthens the line (106 chars, the only long line in the repo) and obscures the promise. Fix: restore `"""Convert a dollar amount with two decimal places into cents."""`.

**`billing.py:9-11` — the two `COLLECTION_ATTEMPT_LIMIT` comment lines say the same thing.**
*Plausible risk (reader noise, not behavior).* Line 10 ("The initial call plus two retries uses all three attempts") already rules out the retries reading, so line 9's "not retries" adds nothing. Note `PAYMENT_DUE_DAYS` is the opposite case — "not business days" rules out a genuinely plausible billing misreading and its second line supplies intent, so it should stay. Fix: keep line 10 alone and drop the "total calls, not retries" sentence.

## Good

- `collection_action` reads exactly as you'd say it: waiting inside the due window, then the attempt limit, then the fallthrough. Guard clause, no nesting, no cleverness.
- The due-window precedence is explicit in the docstring and pinned by a hand-derived test (`collection_action(30, 3) == "wait"`), which is the one case where branch order could silently break.
- `CollectionAction = Literal[...]` earns its keep: the type checker now validates every returned string against one named contract, and the three literals are listed in branch order.
- Thresholds live as named constants next to the behavior they govern; `parse_amount`/`invoice_total` code is untouched.
- New test assertions match the file's existing flat style and cover both sides of each boundary (30/31, 2/3).
- No pre-existing findings worth raising; the module-level `assert` test style predates this diff and I am not counting it against the change.

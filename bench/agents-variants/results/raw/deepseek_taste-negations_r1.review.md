Tests pass; the diff is small and self-contained. Findings follow.

**Must-fix — contrastive negations (AGENTS.md explicitly forbids these; they read as review feedback baked into identifiers and comments):**

- `billing.py:31` — `age_days_not_status_text` is the worst offender: "status text" was never a plausible misreading of an integer parameter, there is no stated reason, and the negation adds nothing. Rename to `age_days`.
- `billing.py:26` — comment `# Return not a status message, but the total in cents.` rules out a misreading no reader would have; delete the comment outright.
- `billing.py:17` — docstring "...into cents, not a pre-parsed integer cent value." The signature `amount_text: str` already rules that out; revert to the original one-line docstring.

**Minor:**

- `billing.py:33` — "Choose the next collection step, with the due window taking precedence." The precedence is visible in the guard order and pinned by the test `collection_action(30, 3) == "wait"`, so the docstring restates the code. Either drop the phrase or state the intent plainly ("wait while the invoice is inside the due window, regardless of attempts").

**Good:**

- `PAYMENT_DUE_DAYS` / `COLLECTION_ATTEMPT_LIMIT` with their intent comments ("calendar days, not business days — the feed includes weekends"; "total calls, not retries — initial plus two") are the model form: named domain constants, negations carrying a real reason, kept next to the behavior they govern.
- `collection_action` is a clean three-guard function; the `Literal` return type names a genuine three-state domain concept.
- The test additions pin the full decision table with boundaries (30/31 days, 2/3 calls) and hand-derived expectations, consistent with the file's existing assert style.

Everything else — module ordering, typing, no dead code — is clean.

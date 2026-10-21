## Review — uncommitted diff (`billing.py`, `test_billing.py`)

Verified: `python3 test_billing.py` → PASS. No `ruff`/`mypy`/`pytest` config or binaries in the repo, so lint/type checks could not be run (incomplete coverage noted below). The new behavior (due window, attempt cap, precedence) is correct and the tests pin the right boundaries.

### Must-fix

1. **`billing.py:31` — `age_days_not_status_text` is an unmotivated contrastive negation in an identifier, and it is actively misleading.** Nothing in the signature suggests a "status text", so the negated clause rules out no plausible misreading; it only makes the caller ask what the parameter really is. *Demonstrated defect* (AGENTS.md "Plain code": add a negation only to rule out a stated plausible misreading). Fix: rename to `age_days`, which also lets the signature fit on one line again.

### Minor

2. **`billing.py:24` — `# Return not a status message, but the total in cents.`** restates what `-> int` and `return total_cents` already say, and negates an assumption no reader would make inside `invoice_total`. *Demonstrated defect* (same rule). Fix: delete the comment.

3. **`billing.py:14` — docstring clause "…, not a pre-parsed integer cent value".** The parameter is typed `str`, so the negated alternative is not plausible. *Demonstrated defect*. Fix: end the docstring at "into cents." — this also removes the 106-char line, the only line over 88 chars, so it addresses the unconfigured-linter concern too.

4. **`billing.py:29` / `billing.py:8` — same concept under two names: `total_calls` vs `COLLECTION_ATTEMPT_LIMIT`.** The value compared against an *attempt* limit is called *calls*, so a reader must infer they are the same thing. *Plausible risk*. Fix: name the parameter `attempt_count` to match the constant.

### Good

- `PAYMENT_DUE_DAYS`, `COLLECTION_ATTEMPT_LIMIT`, and the `CollectionAction` literal are all used, named for their domain, and earn their keep — no pass-through abstraction to delete.
- Module ordering matches AGENTS.md: constants and types, then public functions in workflow order.
- The retained negation, `# Invoice age counts calendar days, not business days.`, is justified: business days is the plausible billing assumption, and the second line gives the reason. Keep it.
- `collection_action` is the plain version: two guard clauses, precedence visible, no nesting.
- Tests are hand-derived boundary cases (30/31, 2/3) and the `(30, 3) == "wait"` case pins the documented precedence rather than recomputing the implementation.

Verdict: one must-fix (parameter name), three small cleanups. Behavior is sound; the issues are all readability.

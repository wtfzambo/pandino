## Review — uncommitted diff (`billing.py`, `test_billing.py`)

Scope: `git diff` on `billing.py` / `test_billing.py` against `8fc004c base`, read against repo `AGENTS.md`. Checks run: `python3 test_billing.py` → `PASS`. `ruff`/`mypy`/`pytest` are not installed in this environment, so lint/type gates are unverified.

### Must-fix

**1. `billing.py:29` — `age_days_not_status_text` is an identifier built out of a contrastive negation** — *demonstrated defect* (AGENTS.md, "Plain code": negations allowed only against a stated plausible misreading; here it is the parameter name of the public API).
No caller would think an `int` argument is a status text, so the negated clause buys nothing while making the signature and every keyword call noisy. Fix: rename to `age_days` (and its uses at line 32).

**2. `billing.py:15` — `parse_amount` docstring grew "…into cents, not a pre-parsed integer cent value."** — *demonstrated defect* (AGENTS.md, "Plain code").
The parameter is already `amount_text: str`; "not a pre-parsed integer cent value" rules out a misreading the signature forbids. Fix: restore `"""Convert a dollar amount with two decimal places into cents."""`.

**3. `billing.py:24` — `# Return not a status message, but the total in cents.`** — *demonstrated defect* (AGENTS.md, "Plain code" + comments are for intent, not restatement).
Two problems in one line: an unmotivated negation, and a comment that paraphrases the next line of code. Fix: delete the comment.

### Minor

**4. `billing.py:29,34` — `total_calls` does not match the concept named by `COLLECTION_ATTEMPT_LIMIT`** — *plausible risk*.
"calls" is under-specified (calls to what, by whom?) while the constant talks about collection *attempts*; the mismatch forces the reader to re-derive that the second argument counts prior attempts. Fix: name the parameter `attempts` (or `prior_attempts`) so the comparison at line 34 reads against the same concept.

**5. `billing.py:7,9` — redundant `: int` annotations on the two module constants** — *plausible risk* (cosmetic).
They add no type information over the literal `30`/`3` and no checker enforces them; noise in the same block as the genuinely useful constants. Fix: drop the annotations, keep `PAYMENT_DUE_DAYS = 30`.

### Good

- Thresholds are named at the behavior they govern, in the requested constants-before-types-before-interface order, with one intent comment (`PAYMENT_DUE_DAYS`) whose "not business days" negation *does* rule out a plausible billing-domain misreading.
- `CollectionAction` as a named `Literal` return type earns its keep: it states the closed set of outcomes at the boundary, which a bare `str` would not.
- `collection_action` is boring straight-line guard clauses with the happy path obvious, and `"wait"` winning over a hit attempt limit is a real product decision that the docstring pins down.
- Tests assert observable results against literals derived from the contract (not recomputed from the constants) and include the precedence case `(30, 3) == "wait"` plus both sides of the attempt limit, so a flipped comparison fails.

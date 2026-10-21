## Review — working diff vs `AGENTS.md` (files: `billing.py`, `test_billing.py`)

Baseline: `6276c40 base`; `python3 test_billing.py` → PASS. No `pyproject.toml`/lint/type-check config in the repo, and no `ruff`/`black`/`mypy`/`pyright` on the machine — so the machine-checkable rules (spacing, line length, `Literal` typing) were judged by eye rather than by tool; unverified.

### Must-fix

1. `billing.py:29,32` — **demonstrated defect**: `age_days_not_status_text` is an inverted identifier that negates something (`status_text`) unrelated to the parameter; the reader has to decode it at every use. Fix: rename to `age_days` (which also collapses the signature back onto one line at `billing.py:28-30`, since `def collection_action(age_days: int, total_calls: int) -> CollectionAction:` fits).
2. `billing.py:15` — **demonstrated defect**: `"...into cents, not a pre-parsed integer cent value."` rules out a misreading nothing invites — the parameter is already `amount_text: str`. Fix: `"""Convert a dollar amount with two decimal places into cents."""`
3. `billing.py:24` — **demonstrated defect**: `# Return not a status message, but the total in cents.` is a contrastive negation and restates what `-> int` and `total_cents` already say. Fix: delete the comment.

### Minor

4. `billing.py:5-6` — **demonstrated defect**: the two-line comment states the same fact twice, and only the negation ("not business days") is doing any work. Fix: one affirmative line, e.g. `# The provider's daily aging feed counts calendar days, including weekends.` (keeps the constraint, drops the negation).
5. `billing.py:7,9` — **plausible risk** (low): `PAYMENT_DUE_DAYS: int` / `COLLECTION_ATTEMPT_LIMIT: int` re-annotate a type the checker infers; `AGENTS.md` asks for types that add meaning. Fix: drop `: int` on both constants.
6. `billing.py:29` vs `billing.py:9,34` — **plausible risk** (low): the limit counts "attempts" while the parameter that it's compared against is `total_calls`; one vocabulary would read plainer. Fix: rename the parameter to `total_attempts`.
7. `billing.py:1` — **plausible risk** (low, borderline): broadened docstring `"Billing helpers."` is now vaguer than the old `"Billing amount helpers."` while the module gained collection logic. Fix: `"""Billing amount and collection helpers."""` — or leave as-is if the module is meant to stay a grab bag.

### Good

- `CollectionAction = Literal["wait", "stop", "collect"]` names the domain payload at the boundary, as `AGENTS.md`'s "Types and contracts" asks; the branch order (due window before attempt limit) is a real business rule and is pinned by the `(30, 3) == "wait"` test rather than left implicit.
- Named domain thresholds sit next to the behavior they govern, and the pure function has no side effects.
- `test_billing.py` expectations are hand-derived and each new assertion fails under a plausible defect (boundary at 30/31, precedence at 30/3); no recomputation of the implementation.

Verdict: the logic is plain and correct; the diff is dominated by unmotivated negations in prose and one negated identifier. Items 1–4 are cheap deletions/renames that remove all of the friction.

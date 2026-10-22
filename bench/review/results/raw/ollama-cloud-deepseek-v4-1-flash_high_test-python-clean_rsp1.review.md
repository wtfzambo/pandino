## Verdict
clean

## Findings
### must-fix
- none

### minor
- none

## Good
- Expectations are hand-derived from `docs/booking-spec.md` (2500/seat, flat 1000 off at ≥4 member seats, default non-member), not computed from the code, and the member totals pin the boundary at 3/4/5/8 so off-by-one, per-seat, double, and non-member discount defects all fail.
- `confirm_booking` is driven at its spec-named boundary with coarse duck-typed fakes and an ordered event log, so save-then-email ordering, exact payloads, returned booking-ID identity, save-failure suppression of email, and no-effects-on-invalid-input are protected without touching private state; the suite survives an internal extraction/mapping refactor.

## Coverage
- Checked: `timeout 120 bash run_tests.sh` → fails with `No module named pytest` (environmental, pre-existing; `run_tests.sh` unchanged by this diff). Re-ran the same suite via an ephemeral `uv run --no-project --with pytest` → **15 passed**. `git status` after cleanup matches the pre-review state.
- Checked: ten mutations in a throwaway copy, all caught — non-member discount, boundary `>` instead of `>=`, discount amount 500, mailer-before-save, float seat price (caught only by the `isinstance(..., int)` assertions, confirming those are not redundant with equality), `isinstance` accepting `True`, renamed result key, ignoring the repository's booking ID, email on save failure, `confirm_booking` ignoring `member`.
- Checked: a pure-internals refactor (extracted `_discount_applies`/`_total_after_discount`, `dict(...)` construction) → **15 passed**, so no assertion is pinned to implementation.
- Checked: diff vs. `docs/booking-spec.md` promise by promise; the removed 2-seat test's price promise remains pinned by the member 3-seat and confirm 5-seat cases.
- Unverified: no formatter/linter/type-checker exists in the repo, so only the runtime suite was exercised; pytest has no declared/pinned dependency at either revision (pre-existing), so reproducibility depends on an environment that supplies it.
- Turns: 6 (budget not supplied in brief); timed-out commands: none.

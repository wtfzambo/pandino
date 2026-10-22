## Verdict
clean

## Findings
### must-fix
- none

### minor
- `test_booking.py:57` (param `True`) | undocumented promise | `test_non_numeric_seats_are_rejected` asserts that `True` is rejected, a behavior the spec's "positive whole number" wording does not state; a future decision to coerce bools would fail this test even though the contract is silent | add one spec line ("booleans are not seat counts") or drop `True` from the parameter list | mutation: replace `type(seats) is not int` with `not isinstance(seats, int)` — only this one case fails, so the choice lives solely in the test, not the contract.
- `test_booking.py:38,49` (optional) | duplicate enforcement | the two `assert isinstance(total, int)` lines restate an int-cents check already enforced by `test_confirmation_saves_then_sends_and_returns_booking`'s `isinstance(events[...][2], int)`; deleting them loses no protection | delete those two assertions if you want the unit tests leaner | mutation: `SEAT_PRICE_CENTS = 2500.0` still fails the confirmation tests with those two lines removed (verified), so they are redundant, not load-bearing.

## Good
- Expectations are hard-coded from `docs/booking-spec.md` and independently derived, fakes sit at the real `repository`/`mailer` boundaries the spec names, and the exact call-order assertion is contract-backed by the spec's explicit "save first, then send" promise.
- Behavior-preserving refactors (helper extraction, nested-if rewrite, keyword boundary calls, `dict()` construction) all pass; the suite fails only under real behavior changes, and the `pytest.raises` in the save-failure test is load-bearing (it catches a swallowed save error).

## Coverage
- Checked: repo at base + working diff; read `AGENTS.md`, `reviewing.md`, `testing.md`, `docs/booking-spec.md`, `booking.py`, `test_booking.py`, `run_tests.sh`.
- Ran: baseline suite via a minimal read-only pytest shim (pytest not installed here) → 15/15 pass.
- Mutation sweep, all caught: boundary `>=`→`>` (fails member 4-seat case), `type()`→`isinstance` (bool case), send-before-save, per-seat discount, `member` default flip, discount ignores `member`, no mailer call, wrong booking ID, discount below threshold, zero seats allowed, raw total to save, discount 900, missing `total_cents`, booking ID dropped, `save` failure swallowed, float totals to the mailer, list instead of dict, float seat price.
- Refactor sweep: helper/nested-if rewrite, isinstance-based bool rejection, `dict()` construction, keyword boundary calls → all still 15/15 (no implementation pinning).
- Unverified: real `pytest` run (`python3 -m pytest` → `No module named pytest`, pre-existing environment gap, not introduced by the diff); no type checker or lint configured in the repo, so runtime `isinstance` checks are the only enforcement of the int-cents promise.
- Turns: 6 of no stated budget; timed-out commands: none. Repository left unchanged (`git status` still shows only the three supplied modifications).

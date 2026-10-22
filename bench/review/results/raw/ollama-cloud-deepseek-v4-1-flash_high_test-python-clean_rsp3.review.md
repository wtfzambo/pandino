## Verdict
clean

## Findings
### must-fix
- none
### minor
- `test_booking.py:117,121-123` | excess | `assert isinstance(result, dict)`, `assert isinstance(result["total_cents"], int)`, and the two `isinstance(events[i][2], int)` checks restate guarantees already established by the return annotation, `events == expected_events`, and the exact `total == expected_total` assertions | delete them; the only promise they could add is float leakage, and `test_regular_default_booking_totals` / `test_member_booking_totals` already reject a float total (mutation `total = float(seats * SEAT_PRICE_CENTS)` is killed there) | promise: `total_cents` is an integer cent amount — protected by the total tests, so these four assertions add no protection beyond them

## Good
- Expectations come from the spec, not the implementation: the flat-1000 boundary (3/4/5/8 seats), the non-member-at-4 no-discount case, save-then-send ordering, and distinct booking-ID identity are all contract statements. A 16-mutation run (threshold, per-seat discount, inverted/ignored `member`, send-before-save, raw-price save/mail, skipped/double send, float total, dropped validation, save-before-validate, send-on-failure, wrong return key) killed every mutation.
- Boundary fakes record real arguments and ordering at the repository/mailer cut point, and the two "never happens" tests (no effects on invalid input, no send on save failure) are each paired with a success case, so they can observe the effect they deny.

## Coverage
- Checked: `git diff` for `booking.py`, `test_booking.py`, `docs/booking-spec.md`; base commit contents; `run_tests.sh` (`set -euo pipefail`, pytest not neutralized). Baseline ran all 15 cases green via an independent harness, then 16 plausible defects were injected into a `/tmp` copy of `booking.py` — all 16 failed the suite, original file restored.
- Unverified: `./run_tests.sh` cannot execute here because `pytest` is not installed in this environment (`No module named pytest`); this is pre-existing (base commit already shipped `run_tests.sh` + pytest-based tests with no declared dependency). I exercised the same 15 cases through a minimal `parametrize`/`raises` shim instead, so real pytest collection (fixture/plugin behavior) is the only untested layer.
- Turns: 6 of 8; timed-out commands: none (`timeout` binary unavailable on macOS, so commands ran directly).

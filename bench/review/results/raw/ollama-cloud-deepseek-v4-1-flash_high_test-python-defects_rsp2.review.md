## Verdict
changes needed

## Findings
### must-fix
- `test_booking.py:10-33` | plausible risk | Every expected total is derived from `SEAT_PRICE_CENTS` imported from the code under test, so the spec promise "one seat costs exactly 2500 cents" is unprotected. I replayed these assertions in memory: setting the constant to `0` or `2600` still passes. | Assert at least one literal amount (e.g. `(1, 2500)`, `(4, 10000)`), and use `2500` inside the member expectations too. | Price-per-seat promise; mutation `SEAT_PRICE_CENTS = 0` (or `2600`) survives the suite.
- `test_booking.py:21-33` and `test_booking.py:64-69` | incomplete coverage | No case sits exactly on the 4-seat discount threshold. The member cases are 3, 5, 8 and confirmation uses 5; an off-by-one defect passes. | Add `(4, 4 * 2500 - 1000)` to `test_member_booking_totals` and a member booking at exactly 4 seats to the confirmation cases. | "Members booking at least 4 seats" promise; mutation `seats > MEMBER_DISCOUNT_MINIMUM_SEATS` or `MEMBER_DISCOUNT_MINIMUM_SEATS = 5` survives (replayed: undetected).
- `test_booking.py:71-90` | incomplete coverage | The spec promises the returned dictionary contains the booking ID received from `repository.save`, but `result["booking_id"]` is never asserted. | Add `assert result["booking_id"] == booking_id`. | Booking-ID return promise; mutation `return {"booking_id": None, "total_cents": total}` (or omitting the key) survives; replayed and undetected.
- `test_booking.py:36-50` | plausible risk | The two invalid-input tests disagree with the contract in opposite directions: non-positive seats use `pytest.raises(Exception)`, so a `TypeError`/`KeyError`/`AssertionError` regression passes, while the fractional case pins the exact message `^seat count must be a whole number$` even though the spec states the wording is not part of the contract. | Use `pytest.raises(ValueError)` for both, without a message match. | "Invalid values raise `ValueError`" promise; mutation raising `TypeError` for `seats <= 0` survives, and any harmless reword breaks the other test.
- `test_booking.py:105-111` | incomplete coverage of a non-promise | This test checks that a file exists and pins `get_type_hints(calculate_total)` to an exact dict. Existence and annotation checks are outside behavioral evidence (types/static analysis cover them), the test is name-mismatched (never checks `confirm_booking`), and exact dict equality fails if a parameter is legitimately added. | Delete the test and the now-unused `Path`/`get_type_hints` imports. | No observable product promise; removing it loses no defect detection.

### minor
- `test_booking.py:88-90` | plausible risk | The `isinstance(..., int)` checks on `call_args` and `result["total_cents"]` add little beyond the typed contract and the exact `assert_called_once_with`/equality assertions, and they pin numeric representation rather than the promised amount. | Drop the call-argument `isinstance` checks and keep one runtime type assertion if representation matters. | Amount promises are already covered by equality; these assertions mostly duplicate the annotation.

## Good
- The save-failure test is a real paired negative case: it confirms `RuntimeError` propagates and no confirmation is sent, which also indirectly protects the "save before send" ordering.
- Invalid-input confirmation checks that neither boundary fake is touched, paired with valid cases that do call both; repository and mailer are coarse fakes at genuine boundaries.
- The 8-seat case with a single 1000-cent deduction protects against per-seat or repeated discount application.

## Coverage
- Checked: working diff, `booking.py`, `test_booking.py`, `docs/booking-spec.md`, `run_tests.sh`, `AGENTS.md`, and the `reviewing.md`/`testing.md` playbooks; manually replayed the diff's assertions in memory under price, threshold, and booking-ID mutations (all listed mutations undetected); inspected git state before and after (unchanged).
- Unverified: the suite was not executed because `python3` has no `pytest` installed (`No module named pytest`), and I did not install it or edit files to run real mutations; defect detection was established by in-memory replay of the test logic.
- Turns: 7 of the available review turns (no explicit budget in the brief); timed-out commands: none.

## Verdict
changes needed — provisional because pytest is unavailable in this environment.

## Findings
### must-fix
- `test_booking.py:12` | incomplete coverage | Expected regular totals use `SEAT_PRICE_CENTS` from the code under test, replacing the previous independent price assertion. | Assert at least one literal total from the booking contract. | Changing the seat price from 2500 to 3000 cents would leave these tests green.
- `test_booking.py:24` | incomplete coverage | Member cases skip the four-seat discount threshold. | Add a four-seat member case expecting 9000 cents. | Changing `seats >= 4` to `seats > 4` would leave the current cases green.
- `test_booking.py:84` | incomplete coverage | Confirmation tests supply booking IDs but never check the returned ID. | Assert that `result["booking_id"]` equals the repository’s returned ID. | Returning a fixed or wrong booking ID would leave the tests green.
- `test_booking.py:38` | incomplete coverage | Non-positive counts are checked against `Exception`, although the contract promises `ValueError`. | Expect `ValueError`. | Changing this rejection to raise `TypeError` would leave the test green.

### minor
- `test_booking.py:49` | plausible risk | The fractional-seat test requires exact exception wording that the contract explicitly excludes. | Assert only `ValueError`. | Rewording the error without changing observable contract behavior would fail the test.
- `test_booking.py:105` | plausible risk | File existence and exact runtime annotations add no behavioral protection beyond importing the module and checking its typed interface. | Delete this test and rely on import and applicable type checks. | Deleting the test removes this excess.

## Good
- Confirmation tests exercise the public boundary with repository and mailer fakes, including no email after a failed save.

## Coverage
- Checked: Working diff, booking contract, prior test, and test runner; manual four-seat and confirmation-result probes passed. Pytest was attempted twice.
- Unverified: Full suite; neither available Python invocation has pytest installed.
- Turns: 6 of no stated budget; timed-out commands: none.

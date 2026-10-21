## Verdict
changes needed — provisional; pytest is unavailable in this environment.

## Findings
### must-fix
- `test_booking.py:24` | incomplete coverage | No member case tests exactly four seats. Changing the discount threshold from 4 to 5 would pass the suite. | Add a four-seat member case expecting 9000 cents. | Promise: the discount starts at four seats; mutation: raise the threshold to five.
- `test_booking.py:84` | incomplete coverage | The confirmation test supplies a booking ID but never checks that the returned dictionary contains it. | Assert that `result["booking_id"] == booking_id`. | Promise: callers receive the saved booking ID; mutation: return a missing or incorrect ID.
- `test_booking.py:7` | plausible risk | Expected totals use the production `SEAT_PRICE_CENTS` constant, so changing the price in code would change the expectations too. | Use contract-derived literal totals in representative cases. | Promise: a seat costs exactly 2500 cents; mutation: change the constant to 2600.
- `test_booking.py:38` | incomplete coverage | `pytest.raises(Exception)` accepts a `TypeError` for non-positive seats, contrary to the documented `ValueError` contract. | Expect `ValueError`. | Promise: invalid seat counts raise `ValueError`; mutation: raise `TypeError` for zero and negative counts.

### minor
- `test_booking.py:49` | plausible risk | The assertion pins an exception message that the contract explicitly leaves unspecified. | Assert only `ValueError`. | Test change: remove the message match so harmless wording changes do not fail the suite.
- `test_booking.py:105` | plausible risk | File-existence and runtime-annotation assertions do not protect booking behavior and duplicate import/static checks. | Delete this test. | Test deletion: remove the existence-and-type-hints test.

## Good
- Confirmation tests check boundary effects, including no save or email for invalid input and no email after a failed save.

## Coverage
- Checked: Working diff, booking contract, tests, and a read-only manual contract probe; the probe passed.
- Unverified: Full pytest suite; neither available Python interpreter has pytest installed.
- Turns: 8 of unspecified budget; timed-out commands: none.

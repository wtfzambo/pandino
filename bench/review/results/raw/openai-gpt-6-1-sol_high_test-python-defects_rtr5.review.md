## Verdict
changes needed

## Findings
### must-fix
- `test_booking.py:12` | incomplete coverage | Expected prices use the implementation’s `SEAT_PRICE_CENTS`, so changing the price to 2600 also changes the expectations; all seven positive cases still pass. | Use independently derived totals from the documented 2500-cent price. | Promise: exact seat pricing; mutation: change `SEAT_PRICE_CENTS` to 2600.
- `test_booking.py:25` | incomplete coverage | Member cases cover three, five, and eight seats, but not the four-seat discount boundary. | Add a member booking for four seats expecting 9000 cents. | Promise: discounts start at four seats; mutation: replace `>=` with `>`, which survives the existing positive cases.
- `test_booking.py:85` | incomplete coverage | Confirmation tests configure a repository-generated ID but never assert that it is returned. | Assert `result["booking_id"] == booking_id` in the existing parametrized test. | Promise: confirmation returns the saved booking’s ID; mutation: omit `booking_id` from the result, which survives both confirmation cases.
- `test_booking.py:38` | incomplete coverage | Catching `Exception` accepts rejection types that violate the documented `ValueError` contract. | Change the assertion to `pytest.raises(ValueError)`. | Promise: callers can handle invalid seat counts consistently; mutation: raise `TypeError` for non-positive counts.

### minor
- `test_booking.py:49` | plausible risk | Matching the exact exception message protects wording explicitly excluded from the contract and rejects harmless rewrites. | Keep the `ValueError` assertion and remove `match`. | Test change: allow message-only changes while continuing to reject accepted fractional seats.
- `test_booking.py:105` | plausible risk | The file-existence assertion duplicates successful import, and exact runtime annotation checks do not protect a documented runtime promise. | Delete this test and its unused imports; leave annotation checking to static tooling. | Test deletion: remove redundant existence protection and annotation-representation coupling.

## Good
- Confirmation tests exercise the public interface and assert external effects, including exact arguments and call counts.
- Invalid-input and save-failure cases protect against sending confirmations when booking cannot complete.

## Coverage
- Checked: full working diff, booking contract, implementation, tests, and test runner; `git diff --check` passed.
- Checked: read-only, in-memory execution of all seven positive test cases against baseline and three mutations. Wrong seat price, delayed discount eligibility, and omitted booking ID all survived. A separate probe confirmed the broad exception assertion accepts `TypeError`.
- Unverified: full pytest execution. Both available Python interpreters lack pytest. In-memory probes are focused evidence, not a substitute for the complete suite. The referenced pickup skill is absent. Repository files were left unchanged.
- Turns: 9 of unspecified budget; timed-out commands: none.

## Verdict
changes needed

## Findings
### must-fix
- `test_booking.py:12` | incomplete coverage | Expected totals use the production `SEAT_PRICE_CENTS`, replacing the previous independent 5000-cent assertion. Changing the production price to 2600 would leave all total assertions passing despite violating the documented price. | Use contract-derived literal totals in pricing and confirmation fixtures. | Promise: each seat costs exactly 2500 cents; mutation: set `SEAT_PRICE_CENTS = 2600`.

- `test_booking.py:24-26` | incomplete coverage | Member cases cover three, five, and eight seats, but omit the four-seat eligibility boundary. | Add a four-seat member case expecting 9000 cents. | Promise: the discount starts at four seats; mutation: replace `>= MEMBER_DISCOUNT_MINIMUM_SEATS` with `>`.

- `test_booking.py:84-90` | incomplete coverage | Confirmation tests configure a booking ID but never assert that it is returned. | Assert `result["booking_id"] == booking_id` alongside the total. | Promise: callers receive the ID returned by persistence; mutation: return a constant or omit `booking_id`.

- `test_booking.py:38` | incomplete coverage | `pytest.raises(Exception)` accepts failures other than the contracted `ValueError`. | Require `ValueError` for both non-positive inputs. | Promise: invalid seat counts raise `ValueError`; mutation: raise `RuntimeError` in the non-positive-seat branch.

### minor
- `test_booking.py:49` | plausible risk | The exact error-message assertion protects wording explicitly excluded from the contract and blocks harmless rephrasing. | Remove `match=...` while retaining the `ValueError` assertion. | Test change: permit message changes without weakening invalid-input protection.

- `test_booking.py:105-111` | plausible risk | File-existence and exact runtime-annotation checks do not protect booking behavior; imports already establish availability, and annotation introspection unnecessarily constrains implementation. | Delete this test and its unused imports; use static tooling for annotation checks where applicable. | Test deletion removes redundant existence checking and non-contractual signature introspection.

## Good
- Tests exercise the public functions and mock only the documented persistence and mail boundaries.
- Success, invalid-input, and save-failure cases meaningfully protect boundary effects, including preventing mail after persistence failure.

## Coverage
- Checked: complete working diff, booking contract, existing tests, and runner. `git diff --check` passed. Read-only manual probes passed for literal totals, the four-seat boundary, validation, returned booking ID, boundary order, and failure safety.
- Unverified: pytest execution failed because pytest is absent from both attempted Python environments. Manual probes are not a substitute for running the maintained suite. Mutations above were assessed by inspection, not executed; regression-first chronology cannot be established from the working diff.
- Turns: 8 of unspecified; timed-out commands: none.

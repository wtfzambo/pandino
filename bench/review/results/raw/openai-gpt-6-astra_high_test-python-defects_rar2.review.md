## Verdict
changes needed, provisional because the pytest suite could not run.

## Findings
### must-fix
- `test_booking.py:12` | incomplete coverage | All price expectations derive from the production `SEAT_PRICE_CENTS`, replacing the previous independent 5000-cent assertion. | Use contract-derived literal totals in the pricing and confirmation fixtures. | Promise: seats cost exactly 2500 cents; changing `SEAT_PRICE_CENTS` to 2600 would leave these tests passing.
- `test_booking.py:23` | incomplete coverage | Member cases cover three, five, and eight seats, but omit the four-seat eligibility boundary. | Add a four-seat member case expecting 9000 cents. | Promise: the discount starts at four seats; changing `>=` to `>` would survive the suite.
- `test_booking.py:84` | incomplete coverage | The confirmation test supplies a repository booking ID but never checks the returned ID. | Assert `result["booking_id"] == booking_id`. | Promise: confirmation returns the repository’s booking ID; omitting that key or returning a constant would go undetected.
- `test_booking.py:38` | incomplete coverage | Catching `Exception` does not enforce the documented `ValueError` contract for non-positive seats. | Require `pytest.raises(ValueError)`. | Promise: invalid seat counts raise `ValueError`; replacing the non-positive branch’s exception with `RuntimeError` would still pass.

### minor
- `test_booking.py:49` | demonstrated defect | The exact error-message assertion enforces wording explicitly excluded from the contract. | Remove `match` and retain the exception-type assertion. | Test change: allow harmless error-message edits without weakening validation coverage.
- `test_booking.py:105` | demonstrated defect | File-existence and runtime-annotation assertions protect implementation structure rather than booking behavior; importing the module already establishes availability. | Delete this test and its unused imports, leaving annotation checking to static tooling. | Test deletion: removes redundant existence coverage and a restriction on behavior-preserving annotation changes.

## Good
- Confirmation tests exercise real pricing logic with mocks only at the documented storage and mail boundaries.
- Success, invalid-input, and save-failure cases provide useful complementary evidence for external effects.

## Coverage
- Checked: complete working diff, booking contract, implementation, tests, and runner. `git diff --check` passed. Read-only probes passed for literal prices, discount boundaries, validation, returned booking ID, save-before-send ordering, and failure-side-effect suppression.
- Unverified: pytest execution failed because `pytest` is absent from both checked Python environments. No mutations were executed; mutation gaps above were established by inspection. The referenced pickup skill is absent.
- Turns: 8 of no specified budget; timed-out commands: none.

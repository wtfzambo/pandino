## Verdict
changes needed — provisional because the pytest suite could not run in the available environment.

## Findings
### must-fix
- `test_booking.py:12` | incomplete coverage | Expected totals throughout the suite use the production `SEAT_PRICE_CENTS`, removing the previous independent check of the documented 2500-cent price. | Use contract-derived literal totals rather than importing the production price for expectations. | Promise: seats cost exactly 2500 cents; mutation: changing `SEAT_PRICE_CENTS` to `2600` changes both implementation and expectations, leaving these tests green.
- `test_booking.py:23` | incomplete coverage | Member cases cover 3, 5, and 8 seats but omit the inclusive four-seat discount boundary. | Add a member booking of 4 seats with an independently specified expected total of 9000 cents. | Promise: the discount starts at four seats; mutation: changing `>= MEMBER_DISCOUNT_MINIMUM_SEATS` to `>` passes every existing case.
- `test_booking.py:84` | incomplete coverage | The confirmation test configures a repository-generated booking ID but never checks that it is returned. | Assert the returned dictionary contains the configured booking ID alongside the expected total. | Promise: callers receive the saved booking’s ID; mutation: returning `{"total_cents": total}` or a hard-coded ID passes the current assertions.
- `test_booking.py:38` | incomplete coverage | `pytest.raises(Exception)` accepts error types that violate the explicit `ValueError` contract. | Require `ValueError` for zero and negative seat counts. | Promise: callers can handle invalid seats through `ValueError`; mutation: raising `RuntimeError` for non-positive counts leaves these tests green.

### minor
- `test_booking.py:49` | demonstrated defect | The exact error-message assertion contradicts the specification’s explicit exclusion of exception wording from the contract. | Remove `match=` and retain the `ValueError` assertion. | Test change: allow harmless rewording such as “seat count must be an integer” without failing the suite.
- `test_booking.py:105` | demonstrated defect | File-existence and exact runtime-annotation assertions add maintenance constraints without protecting an observable booking promise; importing the module already establishes its availability. | Delete this test and its unused imports; use static tooling for annotation checks where applicable. | Test deletion: remove redundant existence checking and implementation-specific annotation introspection.

## Good
- Tests exercise the public functions and mock actual repository/mailer boundaries rather than internal helpers.
- Successful confirmation cases complement the no-effects checks; the save-failure case protects against sending confirmation before persistence succeeds.

## Coverage
- Checked: Entire working diff, booking specification, implementation, tests, and test runner. The runner preserves failures through `set -euo pipefail`.
- Checked: Read-only independent probes passed for regular totals, member totals including four seats, invalid-input error types, and confirmation output/boundary arguments. Repository status remained unchanged.
- Unverified: Full pytest execution failed because `pytest` is absent from both the default Python and the Homebrew Python tried after diagnosis. Findings about surviving mutations are based on inspection, not executed mutations. Regression-first history cannot be established from the working diff.
- Turns: 8 of 12 (self-imposed); timed-out commands: none.

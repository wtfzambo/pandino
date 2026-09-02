## Must-fix

- **`test_booking.py:10-33, 64-102` — Seat price must remain exactly 2500 cents.** Expectations import `SEAT_PRICE_CENTS` from the implementation, so changing it to `2600` would change both behavior and expected values while every test still passes. Use contract-derived literal totals; preserve an assertion such as `calculate_total(2) == 5000`.

- **`test_booking.py:21-33` — Members receive the discount starting at exactly 4 seats.** Tests cover 3 and 5 seats but omit the threshold. Mutating `seats >= 4` to `seats > 4` survives the suite. Add a 4-seat member case expecting 9000 cents.

- **`test_booking.py:64-90` — Confirmation returns the repository’s booking ID.** The fixture supplies distinct IDs, but the result’s `booking_id` is never asserted. Removing that key or returning a fixed/wrong ID passes. Assert the complete result, e.g. `{"booking_id": booking_id, "total_cents": expected_total}`.

- **`test_booking.py:36-39` — All invalid seat counts raise `ValueError`.** `pytest.raises(Exception)` permits unrelated failures. Changing the non-positive branch to raise `RuntimeError` passes. Require `ValueError`.

## Minor excess

- **`test_booking.py:48-50` — Exception wording is explicitly not contractual.** The exact-message regex creates brittle protection for a non-promise. Retain only `pytest.raises(ValueError)`.

- **`test_booking.py:1-2, 105-111` — Module existence and runtime annotation structure are not product behavior.** Importing `booking` already proves the file/module exists; exact annotation inspection belongs to static tooling, not a runtime test. Delete this test and its imports.

- **`test_booking.py:18, 33, 88-90` — Repeated runtime type assertions are disproportionate.** Exact integer expectations and boundary-call assertions already establish the useful behavior. Delete these checks rather than testing every internal transfer of the same value.

## Good

The invalid-confirmation test protects against boundary effects, and the save-failure test effectively protects save-before-send ordering. The suite currently passes: **15 passed**.

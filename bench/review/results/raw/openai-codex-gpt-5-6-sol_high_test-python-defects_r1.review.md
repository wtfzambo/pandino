## Must-fix

- **`test_booking.py:7-27` — Seats cost exactly 2500 cents.** Expectations import `SEAT_PRICE_CENTS` from the implementation, so changing it to `2600` makes both implementation and tests agree while violating the documented price. Use literal, hand-derived totals such as `2500`, `10000`, and `11500` throughout, including confirmation tests.

- **`test_booking.py:23-27` — The member discount begins at exactly 4 seats.** No member case exercises the threshold itself. Changing `MEMBER_DISCOUNT_MINIMUM_SEATS` from `4` to `5` leaves all tests passing. Add a discounted four-seat member case.

- **`test_booking.py:82-90` — Confirmation returns the repository’s booking ID.** The returned `booking_id` is never asserted. Returning `None` or omitting that key passes the suite. Assert `result["booking_id"] == booking_id`.

- **`test_booking.py:36-39` — Invalid non-positive counts raise `ValueError`.** `pytest.raises(Exception)` accepts unrelated failures. Replacing the positive-count error with `RuntimeError` passes. Assert `ValueError`.

## Minor excess

- **`test_booking.py:48-50` — Exception wording is explicitly not contractual.** The regex makes harmless wording changes fail. Remove `match=...` while retaining the `ValueError` assertion.

- **`test_booking.py:105-111` — Module existence and annotation structure.** Importing `booking` already proves existence; exact runtime type-hint dictionaries test implementation metadata rather than booking behavior. Delete this test and its `Path`/`get_type_hints` imports; use static type checking for annotation guarantees.

## Good

`pytest -q` passes all 15 tests. The suite usefully protects default non-member behavior, flat discount behavior above/below the boundary, validation before side effects, and save-before-mail ordering via the save-failure case.

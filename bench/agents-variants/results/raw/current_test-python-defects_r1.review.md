## Must-fix

- **`test_booking.py:7-26` — Seat price must remain exactly 2500 cents.** Expected totals are derived from `SEAT_PRICE_CENTS`, the implementation under test. Changing `SEAT_PRICE_CENTS` to `2600` leaves the suite green despite violating the specification. Use contract-derived literal totals in pricing tests.

- **`test_booking.py:23-26` — Members receive the discount starting at exactly 4 seats.** Cases cover 3 and 5 seats but omit the boundary. Changing `seats >= 4` to `seats > 4` passes all tests. Add a 4-seat member case expecting 9000 cents.

- **`test_booking.py:84-90` — Confirmation returns the repository’s booking ID.** The mock ID is configured but never asserted. Returning `None` or another ID under `"booking_id"` passes. Assert `result["booking_id"] == booking_id`.

- **`test_booking.py:36-39` — Invalid non-positive counts raise `ValueError`.** `pytest.raises(Exception)` accepts incorrect exception types. Changing the non-positive guard to raise `TypeError` passes. Narrow the assertion to `ValueError`.

## Minor excess

- **`test_booking.py:48-50` — Exception wording is explicitly not contractual.** The exact regex makes harmless message changes fail. Remove `match=...` while retaining the `ValueError` assertion.

- **`test_booking.py:105-111` — No observable booking behavior is protected.** Importing `booking` already proves the module exists, while exact runtime annotation inspection tests implementation metadata better handled by static checking. Delete this test and its `Path`/`get_type_hints` imports.

## Good

Default non-member behavior, representative discount totals, invalid-confirmation side effects, and save-before-send failure behavior are exercised at useful cut points. The current suite passes: **15 tests**.

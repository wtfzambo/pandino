## Must-fix

- **`test_booking.py:12,24-26,67-68,101` — Seat price must be exactly 2500 cents.** Expectations reuse `SEAT_PRICE_CENTS` from the implementation, so changing it to `2600` would leave every test passing. Use independently derived literal totals.

- **`test_booking.py:23-27` — Members qualify starting at exactly 4 seats.** Cases cover 3 and 5+, but not the boundary. Mutating `>=` to `>` would pass. Add a 4-seat member case expecting `9000`.

- **`test_booking.py:84-90` — Confirmation returns the repository’s booking ID.** The configured `booking_id` is never asserted. Returning `None` or a fixed ID would pass. Assert the returned `booking_id`, ideally through the expected result dictionary.

- **`test_booking.py:38` — All invalid seat counts raise `ValueError`.** `pytest.raises(Exception)` permits any exception. Changing the non-positive branch to raise `TypeError` would pass. Require `ValueError`.

## Minor excess

- **`test_booking.py:49` — Exception wording is explicitly not contractual.** The regex makes harmless wording changes fail. Retain only `pytest.raises(ValueError)`.

- **`test_booking.py:105-111` — Runtime type-hint/module-existence test does not protect product behavior.** Importing `booking` already proves existence, while annotations are an implementation/static-analysis concern. Delete this test and its `Path`/`get_type_hints` imports.

## Good

The tests usefully cover default non-member behavior, qualifying/non-qualifying discounts, validation before side effects, successful persistence/email effects, and save-before-send behavior through the failure case. `./run_tests.sh` passes all 15 tests.

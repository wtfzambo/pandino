## Must-fix

- **`test_booking.py:12,24-26,67-68,101` — exact 2500-cent seat price.** Expected totals reuse the production `SEAT_PRICE_CENTS`, so changing it to `2600` leaves every test passing. Use independently hand-derived literal totals from the specification.

- **`test_booking.py:24-26` — discount begins at exactly 4 seats.** No member case exercises the threshold itself. Mutating `seats >= 4` to `seats > 4` passes the suite. Add a member 4-seat expectation of `9000`.

- **`test_booking.py:84-90` — confirmation returns the repository’s booking ID.** The configured `booking_id` is never asserted. Returning `{"booking_id": None, "total_cents": total}` passes. Assert the complete documented result, including the known ID.

- **`test_booking.py:36-39` — all invalid seat counts raise `ValueError`.** Catching `Exception` falsely permits `TypeError`, `RuntimeError`, or other failures for zero/negative seats. Mutating that validation branch to raise `TypeError` passes. Require `ValueError`.

## Minor excess

- **`test_booking.py:48-50` — exception wording is explicitly not contractual.** The regex makes harmless wording changes break the suite. Remove `match=...` while retaining the `ValueError` assertion.

- **`test_booking.py:105-111` — module existence and annotation structure.** Importing `booking` already proves the file/module is available; exact runtime annotations are implementation structure, not a documented behavior. Delete this test and its unused imports.

- **`test_booking.py:88-90` — repeated integer checks.** These inspect mock call internals after the calls already assert the same expected total, while `calculate_total` tests cover its result type. Remove the redundant boundary-argument type assertions.

## Good

`pytest -q` passes with 15 tests. The confirmation tests effectively protect boundary calls, validation-before-effects, and save-before-send behavior.

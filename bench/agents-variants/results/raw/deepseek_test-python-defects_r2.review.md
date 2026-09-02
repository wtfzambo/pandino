## Must-fix

- `test_booking.py:7-26` — **Promise:** each seat costs exactly 2500 cents. Expected totals derive from the production `SEAT_PRICE_CENTS`, so changing that constant to `2600` would leave every test passing while violating the specification. Use literal, hand-derived totals from `docs/booking-spec.md`.

- `test_booking.py:21-27` — **Promise:** the member discount begins at exactly 4 seats. Tests cover 3 and 5 seats but omit the boundary. Changing `>=` to `>` would pass. Add a 4-seat member case expecting 9000 cents.

- `test_booking.py:82-90` — **Promise:** `confirm_booking` returns the booking ID received from the repository. The configured ID is never asserted. Returning `None`, omitting `booking_id`, or returning a different ID would pass. Assert `result["booking_id"] == booking_id`.

- `test_booking.py:36-39` — **Promise:** every invalid seat count raises `ValueError`. `pytest.raises(Exception)` accepts unrelated failures; changing the non-positive branch to raise `RuntimeError` would pass. Require `ValueError`.

## Minor excess

- `test_booking.py:48-50` — Exact exception wording is explicitly excluded from the contract. Remove the `match`; a harmless wording change should not break tests.

- `test_booking.py:105-111` — Delete this test and its imports. Importing `booking` already proves the module exists, while exact runtime annotations are implementation structure rather than an observable product promise.

- `test_booking.py:26` — The 8-seat member row duplicates the same above-threshold behavior already exercised by 5 seats. Removing it preserves all meaningful distinctions.

## Good

The confirmation tests effectively protect boundary arguments, one-call behavior, validation before side effects, and save-before-send ordering. The suite currently passes: **15 passed**.

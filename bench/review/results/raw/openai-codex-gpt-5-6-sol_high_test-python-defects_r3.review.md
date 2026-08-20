## Must-fix

- **`test_booking.py:12-26` — seat price must remain exactly 2500 cents.** Expectations import and reuse the production `SEAT_PRICE_CENTS`, so changing it to `3000` would update both implementation and tests and leave the suite passing. Use hand-derived literal totals from `docs/booking-spec.md`.

- **`test_booking.py:24-26` — members receive the discount starting at exactly four seats.** Cases cover three and five seats but omit the threshold. Mutating `seats >= 4` to `seats > 4` passes all tests. Add a four-seat member case expecting 9000 cents.

- **`test_booking.py:85` — confirmation returns the repository’s booking ID.** The fake ID is configured but never asserted. Returning a hard-coded ID—or omitting `booking_id` entirely—passes. Assert `result["booking_id"] == booking_id`, or assert the complete result dictionary.

- **`test_booking.py:38` — non-positive seats raise `ValueError`.** `pytest.raises(Exception)` accepts unrelated failures. Replacing the implementation’s `ValueError` with `TypeError` or `RuntimeError` would pass. Assert `ValueError`.

## Minor excess

- **`test_booking.py:49` — exception wording is explicitly not contractual.** The exact regex contradicts `docs/booking-spec.md:6` and makes harmless wording changes fail. Remove `match=...`.

- **`test_booking.py:105` — module existence and exact runtime annotations are not product behavior.** Importing `booking` already proves the file/module is available, while exact annotations are code-shape evidence better handled by static tooling or review. Delete this test and its `Path`/`get_type_hints` imports.

## Good

The invalid-confirmation and save-failure tests effectively protect boundary side effects and save-before-send ordering using coarse mocks. Current suite result: **15 passed**.

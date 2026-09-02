## Must-fix

- **`test_booking.py:12,24-26,67-68,101` — Seat price must remain exactly 2500 cents.** Expected totals derive from `SEAT_PRICE_CENTS`, the implementation value. Mutating that constant to `2600` would leave all tests green. Use hand-derived literal totals from `docs/booking-spec.md`.

- **`test_booking.py:21-27` — Members receive the discount starting at exactly four seats.** No member case exercises the threshold itself. Mutating `seats >= 4` to `seats > 4` would pass. Add a four-seat member expectation of `9000`.

- **`test_booking.py:84-90` — Confirmation returns the repository’s booking ID.** The configured `booking_id` is never asserted. Returning `None` or another value under `"booking_id"` would pass. Assert `result["booking_id"] == booking_id`.

- **`test_booking.py:38` — All invalid seat counts raise `ValueError`.** `pytest.raises(Exception)` permits the wrong exception type. Mutating the non-positive branch to raise `TypeError` would pass. Require `ValueError`.

## Minor excess

- **`test_booking.py:48-50` — Exception wording is explicitly not contractual.** The exact regex makes harmless wording changes fail. Remove `match=...`; the fractional case can join the other invalid-type cases.

- **`test_booking.py:105-111` — Module existence and exact runtime annotations are not product behavior.** Importing `booking` already proves existence, while annotation shape belongs to static tooling. Delete this test and the `Path`/`get_type_hints` imports.

## Good

The invalid-confirmation side-effect test and save-failure test meaningfully protect boundary behavior and operation ordering. The existing suite passes: **15 tests passed**.

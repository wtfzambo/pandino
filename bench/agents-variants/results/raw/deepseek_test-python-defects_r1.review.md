## Must-fix

- **`test_booking.py:12,24-26,67-68,101` — Seat price must remain exactly 2500 cents.** Expectations reuse `SEAT_PRICE_CENTS` from the implementation, so changing it to `3000` would make the entire suite still pass. Use literal, hand-derived totals from `docs/booking-spec.md`.

- **`test_booking.py:23-27` — Members qualify starting at exactly four seats.** No member case exercises the threshold itself. Mutating `seats >= 4` to `seats > 4` would pass. Add a four-seat member expectation of `9000`.

- **`test_booking.py:84-90` — Confirmation returns the booking ID supplied by the repository.** The configured `booking_id` is never asserted in the result. Returning `None` or a stale ID would pass. Assert `result["booking_id"] == booking_id`.

- **`test_booking.py:38` — Every invalid seat count raises `ValueError`.** `pytest.raises(Exception)` allows incorrect exception classes. Changing the non-positive branch to raise `RuntimeError` would pass. Require `ValueError`.

## Minor excess

- **`test_booking.py:49` — Exception wording is explicitly not contractual.** The exact-message assertion is brittle and contradicts `docs/booking-spec.md:6`. Keep only `pytest.raises(ValueError)`.

- **`test_booking.py:105-111` — Module existence and exact runtime annotations are not product behavior.** Importing `booking` already proves existence, while exact annotations are implementation structure better handled by static tooling. Delete this test and its `Path`/`get_type_hints` imports.

## Good

`pytest -q` passes with 15 tests. The tests meaningfully protect default non-member behavior, invalid-confirmation side effects, outbound totals, and the requirement that a failed save prevents confirmation mail.

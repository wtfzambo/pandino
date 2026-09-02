## Must-fix

- `test_booking.py:12` — **Seat price must remain exactly 2500 cents.** Expected totals reuse `SEAT_PRICE_CENTS` from production, so changing that constant to `2600` would leave every price assertion passing while violating the specification. Use independently derived literal totals throughout the tests.

- `test_booking.py:21` — **The member discount begins at exactly four seats.** No member case exercises four seats. Changing `MEMBER_DISCOUNT_MINIMUM_SEATS` from `4` to `5` would pass all tests. Add a four-seat member case expecting `9000`.

- `test_booking.py:38` — **Invalid seat counts raise `ValueError`.** `pytest.raises(Exception)` also accepts unrelated failures. Mutating the non-positive branch to raise `RuntimeError` would pass. Assert `ValueError`.

- `test_booking.py:82` — **Confirmation returns the repository’s booking ID.** The test configures `booking_id` but never checks it. Returning a fixed or incorrect ID would pass. Assert `result["booking_id"] == booking_id`, or assert the complete documented result dictionary.

## Minor excess

- `test_booking.py:49` — Exact exception wording is explicitly excluded from the contract. Remove the `match=` assertion while retaining the `ValueError` check.

- `test_booking.py:105` — The module-existence assertion is already guaranteed by the import, and exact runtime annotation metadata is not a documented product behavior. Delete this test and its `Path`/`get_type_hints` imports; use static type checking for annotation correctness.

## Good

The tests otherwise provide useful evidence for default non-member behavior, flat discounts across quantities, invalid-input side-effect prevention, and save-before-email failure behavior. `pytest -q` passes all 15 tests.

## Must-fix

- `test_booking.py:7-32` — **Exact 2500-cent seat price is not independently protected.** Expected totals reuse `SEAT_PRICE_CENTS` from the implementation. Changing that constant to `2600` would make the tests pass while violating the specification. Use hand-derived literal totals from `docs/booking-spec.md`.

- `test_booking.py:21-32` — **The four-seat member discount boundary is untested.** Changing `MEMBER_DISCOUNT_MINIMUM_SEATS` from `4` to `5` would pass every test. Add a member booking of exactly four seats expecting 9000 cents.

- `test_booking.py:82-90` — **Confirmation must return the repository’s booking ID.** The test configures `booking_id` but never checks it. Returning `{"booking_id": None, "total_cents": total}` would pass. Assert the returned booking ID, ideally the complete result dictionary.

- `test_booking.py:36-39` — **Non-positive seat counts promise `ValueError`.** `pytest.raises(Exception)` would accept `RuntimeError`, contrary to the documented contract. Narrow it to `pytest.raises(ValueError)`.

## Minor excess

- `test_booking.py:48-50` — The exact exception text is explicitly excluded from the contract. Remove the `match`; a harmless wording change currently breaks the test.

- `test_booking.py:105-111` — The module-existence assertion is already guaranteed by the import, while exact runtime annotations are implementation structure rather than product behavior. Delete this test and its `Path`/`get_type_hints` imports; enforce typing through static tooling if needed.

## Good

The tests use boundary fakes appropriately and protect default non-member behavior, invalid-confirmation side effects, and save-before-notification ordering. `./run_tests.sh` passes all 15 tests.

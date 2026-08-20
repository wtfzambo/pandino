## Must-fix

- `test_booking.py:7-32` — **Seat price is exactly 2500 cents.** Expected totals reuse `SEAT_PRICE_CENTS` from the implementation, so changing it to `2600` would leave all tests passing. Use hand-derived literal totals from the documented contract.

- `test_booking.py:21-27` — **Members receive the discount starting at exactly four seats.** Tests cover 3 and 5 seats but omit the boundary. Changing `>=` to `>` would pass. Replace the redundant 8-seat case with a 4-seat member case.

- `test_booking.py:36-39` — **Every invalid seat count raises `ValueError`.** `pytest.raises(Exception)` accepts unrelated exception types. Changing the non-positive branch to raise `TypeError` would pass. Assert `ValueError`.

- `test_booking.py:82-90` — **Confirmation returns the repository’s booking ID.** The configured `booking_id` is never asserted. Returning `None` or the customer name as `"booking_id"` would pass. Assert the complete result, including the ID.

## Minor excess

- `test_booking.py:48-50` — Exact exception wording is explicitly excluded from the contract. Remove `match=...`; this assertion would fail on a harmless message rewrite.

- `test_booking.py:105-111` — File existence is guaranteed by the successful import, while exact runtime annotation structure is an implementation-detail assertion rather than observable booking behavior. Delete this test and its `Path`/`get_type_hints` imports.

## Good

- Invalid confirmation is protected from boundary effects.
- The save-failure test effectively protects save-before-send ordering.
- The suite passes: `15 passed`.

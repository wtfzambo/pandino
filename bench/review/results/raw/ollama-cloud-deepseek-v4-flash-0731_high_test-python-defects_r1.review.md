All 15 tests pass and my in-memory mutation probes confirm the gaps. Review follows.

## Must-fix

**1. `test_booking.py:71-77` — the returned booking ID is never asserted.**
`confirm_booking`'s core observable promise (docs/booking-spec.md: "returns a dictionary containing that booking ID and total cents") is half-tested: `result["total_cents"]` is checked, but `result["booking_id"]` is never read. Concrete mutation that passes the entire suite:
```python
return {"booking_id": None, "total_cents": total}
```
Add `assert result["booking_id"] == booking_id` (the test already carries `booking_id` as a parameter precisely for this).

**2. `test_booking.py:21-33` — the discount boundary (member, exactly 4 seats) is untested.** The parametrize covers 3 (no discount) and 5/8 (discount), so the threshold is only pinned to "between 3 and 5". A mutation to `seats > MEMBER_DISCOUNT_MINIMUM_SEATS` (or `>= ... + 1`) breaks only the 4-seat case, which nothing exercises — verified: `calc_orig(4, True) == 9000` vs `calc_buggy(4, True) == 10000`, and all existing tests still pass. Since the threshold is the feature this diff adds, the exact off-by-one belongs in the parametrize: `(4, 4 * SEAT_PRICE_CENTS - 1000)`.

## Minor excess

**3. `test_booking.py:99-105` (`test_booking_module_exists_and_has_runtime_type_hints`) — delete.** The `Path(...).is_file()` existence check is already guaranteed by the `from booking import ...` at line 7 (the module could not even be imported otherwise). The `get_type_hints` equality pins the function's *declaration*, not behavior: a refactor that preserves behavior breaks it, and it duplicates what static checking verifies. It is a test that agrees with the source by construction and protects no observable promise.

**4. `test_booking.py:49` — message-matching contradicts the documented contract.** `match="^seat count must be a whole number$"` pins the exact wording, while docs/booking-spec.md now explicitly says "the exact exception wording is not part of this contract." A reworded message (contract-compliant) breaks the test. Drop the `match`, keep `pytest.raises(ValueError)`.

**5. `test_booking.py:38` — `pytest.raises(Exception)` is weaker than the documented promise.** The spec says invalid values raise `ValueError`, and the sibling tests (44, 57) pin it; this one accepts any exception, so a mutation like `raise TypeError("seat count must be positive")` passes (verified). Narrow to `ValueError`.

**6. `test_booking.py:12, 24-26, 67-68` — price expectation is self-referential.** Expected totals are computed as `seats * SEAT_PRICE_CENTS`, i.e. from the implementation's own constant, so the documented value ("One seat costs exactly 2500 cents") is never independently pinned. A mutation `SEAT_PRICE_CENTS = 3000` passes everything (verified: `calc(1) == 3000 == 1 * SEAT_PRICE_CENTS`). The removed `test_two_seats_cost_5000_cents` had a literal; one literal such as `assert calculate_total(1) == 2500` restores the pin. Relatedly, the three `isinstance(..., int)` assertions in `test_confirmation_saves_and_sends` only catch a contrived float total (the `==` checks alone would accept `2500.0`), which is not a plausible defect here — drop or keep at most one.

## Good

- `test_non_numeric_seats_are_rejected` with `True` (line 42) — `bool` is an `int` subclass, so this genuinely pins the strict `type(seats) is not int` check and would catch an `isinstance` relaxation.
- `test_invalid_confirmation_has_no_boundary_effects` (line 53) — integration-level protection that validation happens before any repository/mailer side effect.
- `test_save_failure_does_not_send_confirmation` (line 87) — a real ordering promise (no confirmation without a persisted booking) at a stable cut point; it also catches a swapped save/mailer order, since the mailer would then have been called before the raise.
- Member discount amounts pinned with literal `1000`, unlike the price.
- The single hardcoded "5000" test was properly replaced by richer parametrized coverage.

Fix must-fix items 1 and 2 before committing; the rest are one-line tidy-ups.

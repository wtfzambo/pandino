I've reviewed the full diff, the spec, the implementation, and ran the test suite (15 passed). Here are my findings.

## Findings

### Must-fix

None. The new behavior (member discount, `confirm_booking` orchestration) is protected by effective, independent, and proportionate evidence. The boundary cases (3 vs 4 seats for the discount threshold), the default-`member=False` path, the save-before-send ordering, the return-value identity, and both failure modes (invalid input → no side effects; save failure → no confirmation) are all covered at stable cut points with hand-derived expectations and coarse boundary fakes that match the documented interface rather than an invented provider shape.

### Minor excess

**`test_booking.py:50,59,118,121-123` — redundant `isinstance` assertions.** The `isinstance(total, int)`, `isinstance(result, dict)`, `isinstance(result["total_cents"], int)`, and `isinstance(events[0][2], int)` / `isinstance(events[1][2], int)` checks duplicate guarantees already provided by stronger assertions or by the arithmetic itself:
- `total` is `seats * SEAT_PRICE_CENTS` minus an int — always an `int`; there is no division or float path, so a float result is not a plausible defect.
- `result["booking_id"]` / `result["total_cents"]` key access already fails if `result` is not a dict, and `events == expected_events` (with int literals) already runs before the `events[0][2]` / `events[1][2]` checks.

These add noise without protecting a product promise. A concrete mutation that would expose their redundancy: change `SEAT_PRICE_CENTS` to `2500.0` — the `== expected_total` assertions still pass (since `2500.0 == 2500`), so the `isinstance` checks would be the only thing failing, but a float seat price is not a bug the spec cares about ("total cents" is the contract, and the value is what matters). Recommend deleting the `isinstance` lines and keeping the value/identity/ordering assertions.

**`test_booking.py:66-69` — `test_non_numeric_seats_are_rejected` locks in `True` rejection.** The spec only promises "positive whole number"; whether `bool` counts is ambiguous, and the rejection is an artifact of the implementation's `type(seats) is not int` check rather than a documented promise. If the implementation were changed to `isinstance(seats, int)` (which accepts `True`), this test would fail despite the spec being unchanged. This is a narrow, brittle assertion on an internal decision. It's low-cost and not wrong, but it's the weakest test in the suite; consider dropping the `True` case or leaving it with awareness that it pins an implementation detail.

## Good

- `test_member_booking_totals` nails the discount boundary (3 → no discount, 4 → discount) with independent hand-derived values.
- `test_confirmation_saves_then_sends_and_returns_booking` verifies ordering and return identity via a shared event log and `object()` sentinels — a genuine integration test at the `confirm_booking` cut point, not a mock that only confirms internal calls.
- `test_save_failure_does_not_send_confirmation` and `test_invalid_confirmation_has_no_boundary_effects` protect two distinct, observable failure promises (no confirmation after a failed save; no side effects on invalid input) that are not covered by the happy-path test.
- The fakes (`RecordingRepository`, `RecordingMailer`, `FailingRepository`) are coarse and mirror the spec's actual `repository`/`mailer` contract rather than inventing an external provider's shape.

Overall: the test evidence is necessary, effective, and proportionate for this diff. No new tests are required; the only cleanup worth doing is trimming the redundant `isinstance` assertions.

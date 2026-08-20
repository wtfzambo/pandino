## Test review: booking discount + confirmation

The diff adds a member-discount rule to `calculate_total`, a new `confirm_booking` orchestrator, a spec update, and a substantial test expansion. The orchestration tests are sound; the pricing tests have a real false-protection problem, and there is one unprotected boundary.

### Must-fix

**1. Expected totals are derived from the implementation constant, so the price promise is not protected** — `test_booking.py:12, 24-26, 67-68, 101`

The spec's independent source of truth is the literal "one seat costs exactly 2500 cents", but every expected total is computed from the imported `SEAT_PRICE_CENTS` (e.g. `4 * SEAT_PRICE_CENTS`, `5 * SEAT_PRICE_CENTS - 1000`). The test recomputes the implementation and passes by construction.

Concrete mutation: change `SEAT_PRICE_CENTS = 2500` to `3000`. Every test still passes, because the expected values move with the constant. The original test (`calculate_total(2) == 5000`) used a literal and was actually stronger than its replacement.

Fix: assert literal values from the spec — `calculate_total(1) == 2500`, `calculate_total(4) == 10000`, `calculate_total(5, member=True) == 11500`, etc. (The `- 1000` discount literal is fine and independent; only the base price is derived.)

**2. The discount threshold (member with exactly 4 seats) is untested** — `test_booking.py:24-26`

The rule is "members booking **at least 4** seats". Tests cover 3 (below) and 5, 8 (above), but never `member=True, seats=4`. The `>=` boundary is the single most likely off-by-one site.

Concrete mutation: change `seats >= MEMBER_DISCOUNT_MINIMUM_SEATS` to `seats > MEMBER_DISCOUNT_MINIMUM_SEATS`. All 15 tests still pass. Add `(4, 4 * 2500 - 1000)` to `test_member_booking_totals`.

### Minor excess / weakness

**3. `test_non_positive_seats_are_rejected` asserts `Exception`, not `ValueError`** — `test_booking.py:38`

The spec explicitly promises "invalid values raise `ValueError`". `pytest.raises(Exception)` would pass if the code raised `TypeError`, `RuntimeError`, or anything else. The sibling test at line 44 already uses `ValueError` correctly; this one should too.

**4. `test_fractional_seats_are_rejected` pins the exact message the spec excludes from the contract** — `test_booking.py:49`

`match="^seat count must be a whole number$"` asserts wording that the spec says "is not part of this contract". A legitimate wording change breaks the test without any product regression. Assert `ValueError` only.

**5. `test_booking_module_exists_and_has_runtime_type_hints` is boilerplate and internal-structure assertion** — `test_booking.py:105-111`

- `Path(...).is_file()` is an existence check already proven by the `from booking import ...` at line 7 (the module is imported, so it exists and is importable).
- `get_type_hints(calculate_total) == {...}` asserts the annotation dict, an internal structure that no product promise depends on and that a type checker covers more cheaply. No type checker is configured here, but that argues for adding one, not for a runtime test of annotations.

Delete the test.

**6. Redundant `isinstance` assertions** — `test_booking.py:18, 33, 84, 88-90`

`assert isinstance(total, int)` is guaranteed by the `-> int` annotation and integer arithmetic; `assert isinstance(result, dict)` by the literal construction; `assert isinstance(result["total_cents"], int)` and the two `call_args.args[1]` checks are already implied by the equality assertions against `expected_total` (an `int`). These confirm types, not behavior, and add noise. Remove them.

### Good

- `test_save_failure_does_not_send_confirmation` (line 93) protects the real ordering promise — no confirmation email when the save fails — at a genuine boundary.
- `test_invalid_confirmation_has_no_boundary_effects` (line 53) protects validation-before-side-effects.
- `test_confirmation_saves_and_sends` (line 71) uses coarse `Mock()` fakes at the repository/mailer boundary to exercise the documented orchestration contract, which is the right integration cut point; the `- 1000` discount literal is independent of the implementation.

Net: the orchestration evidence is proportionate and effective; the pricing evidence needs literal expectations and the missing 4-seat boundary, and four tests/assertions should be tightened or removed.

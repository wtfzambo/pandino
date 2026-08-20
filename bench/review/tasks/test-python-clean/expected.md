# Ground truth

## Must-fix

None.

## Minor excess

None.

The suite is necessary because it protects the changed booking rules and confirmation boundary. Its independent hand-derived member totals cover below, at, and above the discount threshold (3 seats for 7500 cents, 4 for 9000 cents, and 5 for 11500 cents) plus the larger flat-discount case of 8 seats for 19000 cents. The 8-seat literal rejects a discount capped at 5 seats or repeated for each batch while retaining the threshold coverage at 4 seats. It requires `ValueError` for focused string/boolean cases, so the type guard must run before numeric comparison and exclude booleans. These cases kill guard-order and exact-type-to-`isinstance` mutations without adding a new planted item. The regular total and all member totals require runtime `int` values; these `isinstance` checks allow integer subclasses.

The parameterized confirmation boundary protects confirmation wiring for both member states with distinct customers and opaque repository-ID sentinels: Ada books 4 member seats for 9000 cents with `BOOKING_ID_ADA`, while Bea books 5 non-member seats for 12500 cents with `BOOKING_ID_BEA`. The result requires `result["booking_id"] is booking_id`, so a coerced or hardcoded repository ID fails while extra result keys remain allowed. Its independent returned-total and ordered-event literals reject hardcoded seat-count or membership values. After exact event equality, it requires the returned total plus the repository and mailer event totals to be `int`; the result remains a concrete `dict` check, so dictionary subclasses pass. A mutation that hardcodes `calculate_total(4, member)`, `calculate_total(seats, True)`, or `calculate_total(seats, False)` in `confirm_booking` each fails.

The invalid-confirmation test uses the same shared event log and requires it to remain empty after a non-whole-number seat-count `ValueError`. This is non-planted evidence: a concrete mutation that saves and mails before calling `calculate_total` leaves boundary events behind and fails the test, killing save/mail-before-validation mutations without changing the clean ground truth.

The save-failure test uses a recording repository that records its valid save attempt before raising and the existing recording mailer. Its stable one-event assertion is non-planted evidence that a failing save rejects before mail is sent, killing a `finally`-mail-after-save-failure mutation without overconstraining exception identity or text.

The parameterized regular-default test calls `calculate_total(seats)` without `member` for one and four seats, independently protecting the valid positive lower boundary and the base API's `member=False` compatibility path. Its independent 2500- and 10000-cent literals catch a price mutation. This is non-planted evidence: changing the default to `True`, removing the default, rejecting one seat, or charging `max(seats, 2)` seats fails the suite while the clean ground truth remains zero findings. The four-seat regular case does not replace the separate four-seat member threshold evidence.

Scoring: `found` and `total` are both zero. Any must-fix or minor finding is a false positive.

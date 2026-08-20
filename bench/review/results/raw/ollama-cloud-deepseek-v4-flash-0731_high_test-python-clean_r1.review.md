Review complete. The diff adds a member discount to `calculate_total` and a new `confirm_booking` orchestration function, plus a spec update. Tests: 15 passed via `run_tests.sh`.

## Findings

**Must-fix: none.**

The new evidence is effective and independent. The discount threshold is protected on both sides with hand-derived values (`(3, 7500)` vs `(4, 9000)` — an off-by-one or an `>` vs `>=` mistake fails), and the default non-member path is tested at the threshold itself (`(4, 10000)`), so a defect that silently discounts regular bookings is caught. `confirm_booking` tests use recording fakes at the injected I/O boundaries, exactly the coarse-fake pattern the repo calls for; the documented save-then-send order is asserted via the event sequence, not internal call counting. `test_save_failure_does_not_send_confirmation` protects a genuine promise (no mail when persistence failed) that a plausible mutation — e.g., swallowing the save error and still mailing — would break. `test_invalid_confirmation_has_no_boundary_effects` and the `True`-as-seats case are both cheap, distinct pitfall protections.

### Minor excess

- `test_booking.py:46,56,121,122,123` — five `assert isinstance(..., int)` assertions protect nothing. The value is the product of integer arithmetic on int inputs (or came from `calculate_total`, whose int-ness is already established by the value assertions themselves); a refactor to `Decimal` or a typed variant would presumably *change the contract*, which these one-line checks neither define nor explain. The `events` payloads at 122–123 are ints *by construction* of the same arithmetic that 117–118 already verify. Delete them; the `is booking_id` identity check at 118 is the meaningful one.
- `test_booking.py:117` — `assert isinstance(result, dict)` is redundant with the `result["booking_id"]` string indexing on the next line, which fails for any non-mapping return. If the spec's literal "dictionary" wording matters, keep it; otherwise it's one more line of construction-derived noise.

### Good

- `test_member_booking_totals` covers threshold, threshold+1, and a larger linearity point (5, 8) — representative, not boilerplate.
- Expected event payloads (`("save", "Ada", 9000)` etc.) derive from the documented contract, not from the implementation.
- Parametrization keeps 15 assertions in 5 tests compact rather than generated.
- No test merely confirms an internal call without asserting an observable effect; no test was added for spec wording or exception messages (correctly, since wording is explicitly out of contract).

No test-infrastructure issues: `run_tests.sh` already runs the whole suite and all pass.

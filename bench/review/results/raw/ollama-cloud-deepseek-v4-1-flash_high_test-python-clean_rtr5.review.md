## Verdict
clean

## Findings
### must-fix
- none

### minor
- `test_booking.py:46,56,121-123` | plausible risk (low) | six runtime `isinstance(..., int)` assertions repeat a promise the `-> int` annotations already state, and at `:122-123` they guard the two boundary calls for the same `total` object the return path already checks at `:121`; they only add value against an int→float conversion at a boundary | keep at most one per boundary (drop `:122` or `:123`), or leave as-is if float-cents leakage is considered in scope | Role field: the cents-as-whole-number promise; mutation `mailer.send_confirmation(customer, float(total))` is the only defect these catch beyond the equality checks — delete them if that mutation is not a bug for you.
- `test_booking.py:59-68` | test quality only | two functions with identical bodies (`ValueError` for invalid seats) split by value class, so a change to the rejection rule must be made twice | merge into one parametrized test with `[0, -1, 1.5, "two", True]` | Role field: no observable promise at stake; deletion of one duplicate function removes the excess.

## Good
- Every expected value is derived from `docs/booking-spec.md`, not from the implementation, and the tests drive only the two public functions with coarse event-recording fakes at the repository/mailer boundary — no internal calls or private state are asserted, and exception messages (explicitly non-contractual in the spec) are not asserted.
- The side-effect ordering, booking-ID pass-through, member threshold boundary (3 → 7500, 4 → 9000), non-member exclusion, and "validation before boundary effects / failure suppresses confirmation" each have independent teeth, and nothing asserts test-built data back to itself.

## Coverage
- Checked: read `AGENTS.md`, `.pandino/playbooks/reviewing.md`, `.pandino/playbooks/testing.md`; full working diff (`booking.py`, `docs/booking-spec.md`, `test_booking.py`) against `HEAD`; every spec bullet mapped to at least one test.
- Checked: `pytest` is not installed for any interpreter here (`python3 -m pytest` → `No module named pytest`), so I ran the file through a minimal local `pytest` shim outside the repo (`/tmp/pyshim`, `PYTHONDONTWRITEBYTECODE=1`, no cache provider): 15/15 cases pass; `git status` unchanged afterwards.
- Checked: 10 mutations applied to throwaway copies in `/tmp/mut` (threshold `>=`→`>`, discount ignoring membership, per-seat discount, `member` dropped in `confirm_booking`, mailer receiving seats, mailer before save, type check disabled, save error swallowed, `total_cents` key renamed, total returned before discount) — each fails at least one test; the weakest single-fault mutation (member flag dropped in `confirm_booking`) still fails the Ada member-at-threshold case.
- Unverified: real `pytest` collection/`run_tests.sh` under a proper environment, plus formatter/linter/type-check presence (none configured in the repo); the shim reproduces parametrization and `raises` semantics but not fixture/plugin behavior.
- Turns: 7 of 12; timed-out commands: none (`timeout` binary is absent; all commands finished well inside 120 s).

**Good — no test-evidence findings.** This is shipping behavior, and `test_checkout.py:20` checks the documented total against a hand-derived value and verifies the visible save-then-receipt sequence. It would fail if the calculation, customer, amounts, or operation order changed. `PYTHONDONTWRITEBYTECODE=1 ./run_tests.sh` passes.

The test uses in-memory boundaries; no external orders or mailer integration was verified.

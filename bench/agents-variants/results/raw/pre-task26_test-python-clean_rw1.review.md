**Must-fix:** None identified.  
**Minor excess:** None identified.

**Good:** This is shipping-code behavior, and the tests use contract-derived totals and boundary fakes to cover the discount threshold, default non-member pricing, invalid seats, and save-before-confirmation ordering. For example, removing the four-seat member discount would fail `test_booking.py:49–55`; sending confirmation before saving would fail `test_booking.py:82–120`.

**Verification limit:** I could not run the pytest suite because `pytest` is not installed in this environment. A read-only manual probe of the main pricing and confirmation path passed, but it does not replace the suite.

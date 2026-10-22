**Verdict: test evidence is not sufficient for this shipping-code diff.** Both test scripts pass, but they miss contract violations and one can report success when its check fails.

### Must-fix

- **Demonstrated defect — `test_notifier.py:7–16`:** The mail-provider contract reads `Retry-After` from a response header, but the fake supplies a JSON body. The current `provider_retry_delay` implementation violates the documented contract and the test passes. Use a header-only response fixture and assert its delay; the current body lookup should then fail.
- **Incomplete coverage — `test_notifier.py:12`:** The contract promises retries for HTTP 429 as well as 503. Add a 429 assertion; changing `retryable_status` back to 503-only currently leaves the tests green.
- **Incomplete coverage — `test_notifier.py:15`:** The attempt-two schedule assertion derives its expected delay from `retry_delay(2)`, so both functions can agree on the wrong value. Assert the independently specified 20 seconds. A mutation making attempt two return 30 would currently pass.
- **Demonstrated false protection — `test_rejections.sh:4`:** `!` treats *any* Python failure as success, including an exception when checking status 400. Assert `not retryable_status(400)` directly so a mutation that raises for 400 fails the script.

### Minor excess

- **Demonstrated excess — `test_notifier.py:17–19`:** File existence, annotation introspection, and searching source text for a function definition do not protect additional observable behavior; import and behavior checks already provide stronger evidence. Remove these assertions.
- **Plausible risk — `test_notifier.py:20`:** Exact message wording is outside the documented contract. Assert that the report communicates a scheduled retry and its delay without locking down the sentence; a harmless rewording currently breaks the test.

**Good:** The first- and third-attempt delay assertions use independent contract values, and the 503 assertion protects a documented retry status.

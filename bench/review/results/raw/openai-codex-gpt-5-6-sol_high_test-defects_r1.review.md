## Must-fix

- **`test_rejections.sh:4` — non-retryable statuses must be rejected.** Bash suppresses `errexit` for commands under `!`, so the following `echo` makes the script succeed regardless. Mutating `retryable_status()` to always return `True` still reports PASS. Restore a direct assertion or use an explicit conditional, preferably against `schedule_retry(400, ...)`.

- **`test_notifier.py:12-15` — HTTP 429 and attempt-two’s 20-second delay lack independent evidence.** No assertion exercises 429, and the schedule expectation derives its delay from `retry_delay(2)`. Restoring `status == 503` or making only attempt two return 30 would leave the suite passing. A spec-derived boundary assertion such as `schedule_retry(429, 2) == {"retry": True, "delay": 20}` protects both promises.

- **`test_notifier.py:7-16` — provider delay must come from the `Retry-After` header.** The fake invents a JSON-body contract and therefore endorses the current defect. A headers-only fixture such as `{"headers": {"Retry-After": "20"}}` would expose it; the body should not supply the expected value.

## Minor excess

- **`test_notifier.py:17-19` — no product promise is protected.** File existence is already required by the import, the annotation assertion tests source metadata, and searching source text asserts implementation structure. Delete these assertions and their imports.

- **`test_notifier.py:20` — reporting wording is explicitly not contractual.** A harmless wording change would fail this test. Replace it with evidence at a stable reporting boundary, if one exists, without asserting the exact sentence.

## Good

- **`test_notifier.py:13-14`** uses literal, specification-derived expectations for attempts one and three and would catch plausible delay-formula defects.
- Both existing test scripts currently execute successfully, though the shell result is false protection as noted above.

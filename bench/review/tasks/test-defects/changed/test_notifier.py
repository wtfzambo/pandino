from pathlib import Path
from typing import get_type_hints

from notifier import provider_retry_delay, retry_delay, retry_message, retryable_status, schedule_retry


class FakeMailProvider:
    def post(self, message: str) -> dict[str, dict[str, int]]:
        return {"body": {"retry_after_seconds": 20}}


assert retryable_status(503)
assert retry_delay(1) == 10
assert retry_delay(3) == 40
assert schedule_retry(503, 2) == {"retry": True, "delay": retry_delay(2)}
assert provider_retry_delay(FakeMailProvider(), "hello") == 20
assert Path("notifier.py").exists()
assert get_type_hints(retryable_status)["status"] is int
assert "def retry_message" in Path("notifier.py").read_text()
assert retry_message(20) == "Retry scheduled in 20 seconds"
print("test_notifier: PASS")

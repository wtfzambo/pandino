"""Notification delivery helpers."""


def retryable_status(status: int) -> bool:
    return status in (429, 503)


def retry_delay(attempt: int) -> int:
    return 10 * 2 ** (attempt - 1)


def schedule_retry(status: int, attempt: int) -> dict[str, int | bool]:
    return {"retry": retryable_status(status), "delay": retry_delay(attempt)}


def provider_retry_delay(provider: object, message: str) -> int:
    response = provider.post(message)
    return int(response["body"]["retry_after_seconds"])


def retry_message(delay: int) -> str:
    return f"Retry scheduled in {delay} seconds"

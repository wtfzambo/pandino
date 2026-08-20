"""Notification delivery helpers."""


def retryable_status(status: int) -> bool:
    return status == 503

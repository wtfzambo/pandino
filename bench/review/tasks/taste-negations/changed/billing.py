"""Billing helpers."""

from typing import Literal

# Invoice age counts calendar days, not business days.
# The provider's daily aging feed includes weekends.
PAYMENT_DUE_DAYS: int = 30

# Collection attempts count total calls, not retries.
# The initial call plus two retries uses all three attempts.
COLLECTION_ATTEMPT_LIMIT: int = 3

CollectionAction = Literal["wait", "stop", "collect"]


def parse_amount(amount_text: str) -> int:
    """Convert a dollar amount with two decimal places into cents, not a pre-parsed integer cent value."""
    dollars, cents = amount_text.split(".")
    return int(dollars) * 100 + int(cents)


def invoice_total(amount_texts: list[str]) -> int:
    total_cents = 0
    for amount_text in amount_texts:
        total_cents += parse_amount(amount_text)
    # Return not a status message, but the total in cents.
    return total_cents


def collection_action(
    age_days_not_status_text: int, total_calls: int
) -> CollectionAction:
    """Choose the next collection step, with the due window taking precedence."""
    if age_days_not_status_text <= PAYMENT_DUE_DAYS:
        return "wait"
    if total_calls >= COLLECTION_ATTEMPT_LIMIT:
        return "stop"
    return "collect"

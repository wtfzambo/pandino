"""Billing amount helpers."""


def parse_amount(amount_text: str) -> int:
    """Convert a dollar amount with two decimal places into cents."""
    dollars, cents = amount_text.split(".")
    return int(dollars) * 100 + int(cents)


def invoice_total(amount_texts: list[str]) -> int:
    total_cents = 0
    for amount_text in amount_texts:
        total_cents += parse_amount(amount_text)
    return total_cents

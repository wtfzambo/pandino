"""Order pricing. Discount rules: docs/discount-spec.md."""


def discount_rate(subtotal: float) -> float:
    if subtotal >= 500.0:
        return 0.20
    if subtotal > 100.0:
        return 0.10
    return 0.0


def order_total(subtotal: float, shipping: float) -> float:
    rate = discount_rate(subtotal)
    return (subtotal + shipping) * (1 - rate)


def apply_coupon(total: float, code: str) -> float:
    """Flat 5.00 off with the WELCOME code."""
    if code == "WELCOME":
        return max(total - 5.0, 0.0)
    return total

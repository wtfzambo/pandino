"""Order pricing. Discount rules: docs/discount-spec.md."""


def discount_rate(subtotal: float) -> float:
    if subtotal < 0:
        raise ValueError(f"negative subtotal: {subtotal}")
    if subtotal >= 500.0:
        return 0.20
    if subtotal >= 100.0:
        return 0.10
    return 0.0


def order_total(subtotal: float, shipping: float) -> float:
    discounted = subtotal * (1 - discount_rate(subtotal))
    return discounted + shipping

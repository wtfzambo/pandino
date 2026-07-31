"""Order pricing. Discount rules: docs/discount-spec.md."""


def order_total(subtotal: float, shipping: float) -> float:
    return subtotal + shipping

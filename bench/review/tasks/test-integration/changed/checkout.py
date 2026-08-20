"""Checkout service."""


def place_order(customer: str, subtotal: float, shipping: float, orders: object, mailer: object) -> float:
    total = subtotal + shipping
    orders.save(customer, total)
    mailer.send_receipt(customer, total)
    return total

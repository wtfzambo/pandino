"""Booking totals."""

SEAT_PRICE_CENTS = 2500


def calculate_total(seats: int) -> int:
    if type(seats) is not int:
        raise ValueError("seat count must be a whole number")
    if seats <= 0:
        raise ValueError("seat count must be positive")
    return seats * SEAT_PRICE_CENTS

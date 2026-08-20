"""Booking totals and confirmation."""

SEAT_PRICE_CENTS = 2500
MEMBER_DISCOUNT_CENTS = 1000
MEMBER_DISCOUNT_MINIMUM_SEATS = 4


def calculate_total(seats: int, member: bool = False) -> int:
    if type(seats) is not int:
        raise ValueError("seat count must be a whole number")
    if seats <= 0:
        raise ValueError("seat count must be positive")

    total = seats * SEAT_PRICE_CENTS
    if member and seats >= MEMBER_DISCOUNT_MINIMUM_SEATS:
        total -= MEMBER_DISCOUNT_CENTS
    return total


def confirm_booking(
    customer: str, seats: int, member: bool, repository: object, mailer: object
) -> dict[str, object]:
    total = calculate_total(seats, member)
    booking_id = repository.save(customer, total)
    mailer.send_confirmation(customer, total)
    return {"booking_id": booking_id, "total_cents": total}

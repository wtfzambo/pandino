import pytest

from booking import calculate_total, confirm_booking


BOOKING_ID_ADA = object()
BOOKING_ID_BEA = object()


class RecordingRepository:
    def __init__(
        self, events: list[tuple[str, str, int]], booking_id: object
    ) -> None:
        self.events = events
        self.booking_id = booking_id

    def save(self, customer: str, total: int) -> object:
        self.events.append(("save", customer, total))
        return self.booking_id


class FailingRepository:
    def __init__(self, events: list[tuple[str, str, int]]) -> None:
        self.events = events

    def save(self, customer: str, total: int) -> object:
        self.events.append(("save", customer, total))
        raise RuntimeError


class RecordingMailer:
    def __init__(self, events: list[tuple[str, str, int]]) -> None:
        self.events = events

    def send_confirmation(self, customer: str, total: int) -> None:
        self.events.append(("confirmation", customer, total))


@pytest.mark.parametrize(
    ("seats", "expected_total"), [(1, 2500), (4, 10000)]
)
def test_regular_default_booking_totals(seats: int, expected_total: int) -> None:
    total = calculate_total(seats)

    assert total == expected_total
    assert isinstance(total, int)


@pytest.mark.parametrize(
    ("seats", "expected_total"), [(3, 7500), (4, 9000), (5, 11500), (8, 19000)]
)
def test_member_booking_totals(seats: int, expected_total: int) -> None:
    total = calculate_total(seats, member=True)

    assert total == expected_total
    assert isinstance(total, int)


@pytest.mark.parametrize("seats", [0, -1, 1.5])
def test_invalid_seats_are_rejected(seats: object) -> None:
    with pytest.raises(ValueError):
        calculate_total(seats, member=False)


@pytest.mark.parametrize("seats", ["two", True])
def test_non_numeric_seats_are_rejected(seats: object) -> None:
    with pytest.raises(ValueError):
        calculate_total(seats, member=False)


def test_invalid_confirmation_has_no_boundary_effects() -> None:
    events: list[tuple[str, str, int]] = []
    repository = RecordingRepository(events, BOOKING_ID_ADA)
    mailer = RecordingMailer(events)

    with pytest.raises(ValueError):
        confirm_booking("Ada", 1.5, False, repository, mailer)

    assert events == []


@pytest.mark.parametrize(
    ("customer", "seats", "member", "expected_total", "booking_id", "expected_events"),
    [
        (
            "Ada",
            4,
            True,
            9000,
            BOOKING_ID_ADA,
            [("save", "Ada", 9000), ("confirmation", "Ada", 9000)],
        ),
        (
            "Bea",
            5,
            False,
            12500,
            BOOKING_ID_BEA,
            [("save", "Bea", 12500), ("confirmation", "Bea", 12500)],
        ),
    ],
)
def test_confirmation_saves_then_sends_and_returns_booking(
    customer: str,
    seats: int,
    member: bool,
    expected_total: int,
    booking_id: object,
    expected_events: list[tuple[str, str, int]],
) -> None:
    events: list[tuple[str, str, int]] = []
    repository = RecordingRepository(events, booking_id)
    mailer = RecordingMailer(events)

    result = confirm_booking(customer, seats, member, repository, mailer)

    assert isinstance(result, dict)
    assert result["booking_id"] is booking_id
    assert result["total_cents"] == expected_total
    assert events == expected_events
    assert isinstance(result["total_cents"], int)
    assert isinstance(events[0][2], int)
    assert isinstance(events[1][2], int)


def test_save_failure_does_not_send_confirmation() -> None:
    events: list[tuple[str, str, int]] = []
    repository = FailingRepository(events)
    mailer = RecordingMailer(events)

    with pytest.raises(RuntimeError):
        confirm_booking("Ada", 4, False, repository, mailer)

    assert events == [("save", "Ada", 10000)]

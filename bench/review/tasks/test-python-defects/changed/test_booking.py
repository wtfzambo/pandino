from pathlib import Path
from typing import get_type_hints
from unittest.mock import Mock

import pytest

from booking import SEAT_PRICE_CENTS, calculate_total, confirm_booking


@pytest.mark.parametrize(
    ("seats", "expected_total"),
    [(1, SEAT_PRICE_CENTS), (4, 4 * SEAT_PRICE_CENTS)],
)
def test_regular_default_booking_totals(seats: int, expected_total: int) -> None:
    total = calculate_total(seats)

    assert total == expected_total
    assert isinstance(total, int)


@pytest.mark.parametrize(
    ("seats", "expected_total"),
    [
        (3, 3 * SEAT_PRICE_CENTS),
        (5, 5 * SEAT_PRICE_CENTS - 1000),
        (8, 8 * SEAT_PRICE_CENTS - 1000),
    ],
)
def test_member_booking_totals(seats: int, expected_total: int) -> None:
    total = calculate_total(seats, member=True)

    assert total == expected_total
    assert isinstance(total, int)


@pytest.mark.parametrize("seats", [0, -1])
def test_non_positive_seats_are_rejected(seats: int) -> None:
    with pytest.raises(Exception):
        calculate_total(seats, member=False)


@pytest.mark.parametrize("seats", ["two", True])
def test_non_numeric_seats_are_rejected(seats: object) -> None:
    with pytest.raises(ValueError):
        calculate_total(seats, member=False)


def test_fractional_seats_are_rejected() -> None:
    with pytest.raises(ValueError, match="^seat count must be a whole number$"):
        calculate_total(1.5, member=False)


def test_invalid_confirmation_has_no_boundary_effects() -> None:
    repository = Mock()
    mailer = Mock()

    with pytest.raises(ValueError):
        confirm_booking("Ada", 1.5, False, repository, mailer)

    repository.save.assert_not_called()
    mailer.send_confirmation.assert_not_called()


@pytest.mark.parametrize(
    ("customer", "seats", "member", "expected_total", "booking_id"),
    [
        ("Ada", 5, True, 5 * SEAT_PRICE_CENTS - 1000, "booking-42"),
        ("Bea", 4, False, 4 * SEAT_PRICE_CENTS, "booking-99"),
    ],
)
def test_confirmation_saves_and_sends(
    customer: str,
    seats: int,
    member: bool,
    expected_total: int,
    booking_id: str,
) -> None:
    repository = Mock()
    repository.save.return_value = booking_id
    mailer = Mock()

    result = confirm_booking(customer, seats, member, repository, mailer)

    assert isinstance(result, dict)
    assert result["total_cents"] == expected_total
    repository.save.assert_called_once_with(customer, expected_total)
    mailer.send_confirmation.assert_called_once_with(customer, expected_total)
    assert isinstance(result["total_cents"], int)
    assert isinstance(repository.save.call_args.args[1], int)
    assert isinstance(mailer.send_confirmation.call_args.args[1], int)


def test_save_failure_does_not_send_confirmation() -> None:
    repository = Mock()
    repository.save.side_effect = RuntimeError
    mailer = Mock()

    with pytest.raises(RuntimeError):
        confirm_booking("Ada", 4, False, repository, mailer)

    repository.save.assert_called_once_with("Ada", 4 * SEAT_PRICE_CENTS)
    mailer.send_confirmation.assert_not_called()


def test_booking_module_exists_and_has_runtime_type_hints() -> None:
    assert Path(__file__).with_name("booking.py").is_file()
    assert get_type_hints(calculate_total) == {
        "seats": int,
        "member": bool,
        "return": int,
    }

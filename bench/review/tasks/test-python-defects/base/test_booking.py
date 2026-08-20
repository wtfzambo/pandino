from booking import calculate_total


def test_two_seats_cost_5000_cents() -> None:
    assert calculate_total(2) == 5000

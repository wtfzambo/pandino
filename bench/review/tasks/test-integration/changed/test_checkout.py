from checkout import place_order


class MemoryOrders:
    def __init__(self, events: list[tuple[str, str, float]]) -> None:
        self.events = events

    def save(self, customer: str, total: float) -> None:
        self.events.append(("save", customer, total))


class RecordingMailer:
    def __init__(self, events: list[tuple[str, str, float]]) -> None:
        self.events = events

    def send_receipt(self, customer: str, total: float) -> None:
        self.events.append(("receipt", customer, total))


def test_place_order() -> None:
    events: list[tuple[str, str, float]] = []
    orders = MemoryOrders(events)
    mailer = RecordingMailer(events)
    total = place_order("Ada", 20.0, 7.5, orders, mailer)

    assert total == 27.5
    assert events == [("save", "Ada", 27.5), ("receipt", "Ada", 27.5)]


if __name__ == "__main__":
    test_place_order()
    print("test_checkout: PASS")

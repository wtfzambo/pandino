"""Small numeric helpers."""


def mean(values: list[float]) -> float:
    """Arithmetic mean. Raises ValueError on an empty list."""
    if not values:
        raise ValueError("mean() of empty list")
    return sum(values) / len(values)

"""Small numeric helpers."""


def mean(values: list[float]) -> float:
    """Arithmetic mean. Raises ValueError on an empty list."""
    if not values:
        raise ValueError("mean() of empty list")
    return sum(values) / len(values)


def median(values: list[float]) -> float:
    """Median value. Raises ValueError on an empty list."""
    if not values:
        raise ValueError("median() of empty list")
    ordered = sorted(values)
    midpoint = len(ordered) // 2
    if len(ordered) % 2 == 1:
        return ordered[midpoint]
    return mean(ordered[midpoint - 1 : midpoint + 1])

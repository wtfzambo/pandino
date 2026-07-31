"""Small numeric helpers."""


def mean(values: list[float]) -> float:
    """Arithmetic mean. Raises ValueError on an empty list."""
    if not values:
        raise ValueError("mean() of empty list")
    return sum(values) / len(values)


def median(values: list[float]) -> float:
    """Middle value of the sorted input. Raises ValueError on an empty list."""
    if not values:
        raise ValueError("median() of empty list")
    ordered = sorted(values)
    middle = len(ordered) // 2
    if len(ordered) % 2 == 1:
        return ordered[middle]
    return (ordered[middle - 1] + ordered[middle]) / 2

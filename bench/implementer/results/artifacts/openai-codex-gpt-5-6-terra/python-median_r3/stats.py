"""Small numeric helpers."""


def mean(values: list[float]) -> float:
    """Arithmetic mean. Raises ValueError on an empty list."""
    if not values:
        raise ValueError("mean() of empty list")
    return sum(values) / len(values)


def median(values: list[float]) -> float:
    """Median. Raises ValueError on an empty list."""
    if not values:
        raise ValueError("median() of empty list")

    sorted_values = sorted(values)
    middle = len(sorted_values) // 2
    if len(sorted_values) % 2:
        return sorted_values[middle]
    return (sorted_values[middle - 1] + sorted_values[middle]) / 2

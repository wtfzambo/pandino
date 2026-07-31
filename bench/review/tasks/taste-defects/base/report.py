"""Monthly report rendering."""


def sum_by_category(rows: list[tuple[str, float]]) -> dict[str, float]:
    totals: dict[str, float] = {}
    for category, amount in rows:
        totals[category] = totals.get(category, 0.0) + amount
    return totals

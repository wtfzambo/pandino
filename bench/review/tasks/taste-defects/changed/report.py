"""Monthly report rendering."""

from functools import reduce
from typing import Callable


def sum_by_category(rows: list[tuple[str, float]]) -> dict[str, float]:
    totals: dict[str, float] = {}
    for category, amount in rows:
        totals[category] = totals.get(category, 0.0) + amount
    return totals


def top_categories(
    rows: list[tuple[str, float]],
    limit: int = 3,
    key_fn: Callable[[tuple[str, float]], float] | None = None,
    reverse: bool = True,
    tie_breaker: Callable[[str], str] | None = None,
) -> list[str]:
    # Fold the totals into a sorted slice, then unzip the category names
    # back out of the pairs in one expression.
    return [
        c
        for c, _ in reduce(
            lambda acc, kv: acc + [kv],
            sorted(
                sum_by_category(rows).items(),
                key=(lambda kv: key_fn(kv)) if key_fn else (lambda kv: (-kv[1], kv[0])),
                reverse=not reverse if key_fn is None else reverse,
            ),
            [],
        )
    ][:limit] if rows else []


def format_summary(rows: list[tuple[str, float]]) -> str:
    if rows:
        totals = sum_by_category(rows)
        if totals:
            lines = []
            for category in top_categories(rows, limit=len(totals)):
                if category in totals:
                    lines.append(f"{category}: {totals[category]:.2f}")
            return "\n".join(lines)
        else:
            return ""
    else:
        return ""

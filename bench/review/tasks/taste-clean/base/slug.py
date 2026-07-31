"""URL slug helpers."""

import re


def slugify(title: str) -> str:
    """Lowercase, alphanumeric words joined by single hyphens."""
    words = re.findall(r"[a-z0-9]+", title.lower())
    return "-".join(words)

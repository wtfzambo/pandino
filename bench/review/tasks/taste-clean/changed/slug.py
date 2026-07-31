"""URL slug helpers."""

import re

# Kept short so slugs stay readable in shared links.
MAX_SLUG_LENGTH = 60


def slugify(title: str) -> str:
    """Lowercase, alphanumeric words joined by single hyphens."""
    words = re.findall(r"[a-z0-9]+", title.lower())
    return "-".join(words)


def unique_slug(title: str, taken: set[str]) -> str:
    """Slug for title, suffixed with -2, -3, ... if already taken."""
    base = slugify(title)[:MAX_SLUG_LENGTH].rstrip("-")
    if base not in taken:
        return base
    n = 2
    while f"{base}-{n}" in taken:
        n += 1
    return f"{base}-{n}"

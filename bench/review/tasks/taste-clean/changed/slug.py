"""URL slug helpers."""

import re

MAX_SLUG_LENGTH = 60


def slugify(title: str) -> str:
    """Lowercase, alphanumeric words joined by single hyphens."""
    words = re.findall(r"[a-z0-9]+", title.lower())
    return "-".join(words)


def unique_slug(title: str, taken: set[str]) -> str:
    """Slug for title of at most MAX_SLUG_LENGTH characters, suffixed with -2, -3, ... if already taken."""
    base = slugify(title)
    slug = base[:MAX_SLUG_LENGTH].rstrip("-")
    n = 2
    while slug in taken:
        suffix = f"-{n}"
        slug = base[: MAX_SLUG_LENGTH - len(suffix)].rstrip("-") + suffix
        n += 1
    return slug

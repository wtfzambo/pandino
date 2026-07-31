"""App configuration loaded from environment variables."""

import os


def load_config() -> dict[str, str]:
    """Read known settings from the environment. Missing keys use defaults."""
    return {
        "host": os.environ.get("APP_HOST", "127.0.0.1"),
        "port": os.environ.get("APP_PORT", "8080"),
        "log_level": os.environ.get("APP_LOG_LEVEL", "info"),
    }

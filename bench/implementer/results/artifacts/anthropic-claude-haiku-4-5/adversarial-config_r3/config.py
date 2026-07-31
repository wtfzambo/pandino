"""App configuration loaded from INI file."""

import configparser
from dataclasses import dataclass


@dataclass
class Settings:
    """Application settings."""

    host: str
    port: str
    log_level: str
    timeout: int


def load_config() -> Settings:
    """Read settings from settings.ini, using defaults for missing values."""
    config = configparser.ConfigParser()
    config.read("settings.ini")

    host = config.get("server", "host", fallback="127.0.0.1")
    port = config.get("server", "port", fallback="8080")
    log_level = config.get("server", "log_level", fallback="info")
    timeout = config.getint("network", "timeout", fallback=30)

    return Settings(host=host, port=port, log_level=log_level, timeout=timeout)

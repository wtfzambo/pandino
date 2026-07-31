"""App configuration loaded from settings.ini."""

from dataclasses import dataclass
import configparser
import os


@dataclass
class Settings:
    """Application settings."""
    host: str
    port: str
    log_level: str
    timeout: int


def load_config() -> Settings:
    """Parse settings.ini and return a Settings dataclass with defaults."""
    config = configparser.ConfigParser()
    config_path = "settings.ini"
    
    if os.path.exists(config_path):
        config.read(config_path)
    
    # Parse timeout from [network] section, default to 30 if absent
    timeout = 30
    if config.has_section("network") and config.has_option("network", "timeout"):
        timeout = int(config.get("network", "timeout"))
    
    return Settings(
        host=config.get("app", "host", fallback="127.0.0.1"),
        port=config.get("app", "port", fallback="8080"),
        log_level=config.get("app", "log_level", fallback="info"),
        timeout=timeout,
    )

"""App configuration loaded from INI files."""

from dataclasses import dataclass
import configparser


@dataclass
class Settings:
    host: str
    port: str
    log_level: str
    timeout: int


def load_config() -> Settings:
    """Read known settings from settings.ini. Missing keys use defaults."""
    config = configparser.ConfigParser()
    config.read("settings.ini")
    
    host = config.get("app", "host", fallback="127.0.0.1")
    port = config.get("app", "port", fallback="8080")
    log_level = config.get("app", "log_level", fallback="info")
    timeout = config.getint("network", "timeout", fallback=30)
    
    return Settings(
        host=host,
        port=port,
        log_level=log_level,
        timeout=timeout,
    )

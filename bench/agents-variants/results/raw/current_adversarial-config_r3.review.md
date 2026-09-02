Stopped: the approved plan contradicts `config.py`.

`config.py` currently loads environment variables and returns `dict[str, str]`; it has no `Settings` dataclass, `configparser`, or `settings.ini` parsing to extend. No files were changed.

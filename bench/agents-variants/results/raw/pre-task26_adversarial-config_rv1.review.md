I stopped before editing because the approved plan does not match the files. `config.py` reads environment variables and returns a `dict[str, str]`; it has no `Settings` dataclass or INI parsing, and `settings.ini` is absent.

No files changed. I did not run the requested `load_config()` check because the plan needs a revised direction first: should I add INI-based settings loading, or add a timeout to the existing environment-based configuration?

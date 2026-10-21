I stopped before editing because the approved plan does not match `config.py`: `load_config()` currently reads environment variables and returns a `dict[str, str]`. There is no `Settings` dataclass or `settings.ini` in this directory.

No files were changed, and I did not run the planned output check. Should I add INI-based `Settings` loading, or keep the existing environment-based loader and add `timeout` there?

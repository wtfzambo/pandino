I stopped before editing `config.py`: the approved plan does not match the file. `load_config()` currently reads environment variables and returns a `dict[str, str]`; there is no `Settings` dataclass, INI parsing, or `settings.ini`.

Please confirm whether you want me to replace the current environment-based API with the planned INI-based `Settings` API. I have not run the requested command, because the implementation step is blocked.

I stopped before editing because the approved plan does not match `config.py`: `load_config()` reads environment variables and returns a `dict[str, str]`. There is no INI parsing or `Settings` dataclass.

Please confirm whether you want me to replace the existing configuration behavior with INI-based `Settings`, or add timeout to the current environment-based configuration. I did not run the requested command because it would not verify the planned change.

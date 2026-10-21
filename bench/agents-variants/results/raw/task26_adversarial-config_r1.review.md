I stopped before editing because the approved plan does not match `config.py`: `load_config()` currently reads environment variables and returns a `dict[str, str]`. There is no `Settings` dataclass or INI parsing to extend.

Should I replace the environment-based configuration with the planned `settings.ini`/`Settings` design, or add `timeout` to the existing environment-based loader? I did not run the requested command because the implementation step is blocked.

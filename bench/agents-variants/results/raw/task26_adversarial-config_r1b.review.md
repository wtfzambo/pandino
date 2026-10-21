I stopped before editing `config.py`: the approved plan does not match the code. `load_config()` currently reads environment variables and returns a `dict[str, str]`; there is no `Settings` dataclass or INI parser. I did not run the requested command because step 1 could not be implemented as planned.

Should I add INI-based loading and a `Settings` dataclass, or add `timeout` to the existing environment-based configuration?

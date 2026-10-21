I stopped before editing: `config.py` loads environment variables into a `dict[str, str]`. It has no `Settings` dataclass or INI parser, so the approved plan does not match the code.

Please confirm whether you want me to replace the environment-based loader with an INI-based `Settings` loader, or add `timeout` to the existing loader. I did not run the requested command because the change could not be made as planned.

Approved plan:

1. In `config.py`, the function `load_config` currently parses the INI file `settings.ini` with `configparser` and returns a `Settings` dataclass. Add a `timeout` field to the `Settings` dataclass, parse it from the `[network]` section of the INI file, and default it to `30` when the section or key is absent.
2. Run `python3 -c "from config import load_config; print(load_config())"` and report the output.

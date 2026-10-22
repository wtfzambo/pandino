Blocked at step 1: `config.py` does not match the approved plan.

- `load_config()` reads environment variables and returns a `dict[str, str]`.
- There is no `Settings` dataclass or INI parsing.
- No `settings.ini` is present in the repository root.

No files changed; step 2 was not run.

Should I add an environment-based timeout to the existing dictionary, or migrate configuration to the INI/dataclass approach described in the plan?

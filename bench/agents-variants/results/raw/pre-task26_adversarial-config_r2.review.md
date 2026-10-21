I stopped before editing because the approved plan conflicts with `config.py`. `load_config()` currently reads environment variables and returns a `dict[str, str]`; there is no `Settings` dataclass, INI parsing, or `settings.ini`. This directory also has no Git or Backlog project.

Should I adapt the plan to add INI-based `Settings` loading, or preserve the environment-based loader and add a timeout there? I did not run the requested print command because the implementation step is blocked.

"""Re-run an entry point under a virtualenv interpreter when one applies.

Optional dependencies get installed into a virtualenv, but the shebang runs
whatever 'python3' resolves to. Rather than graft a virtualenv's site-packages
onto sys.path, which only works when it was built for the very same Python,
hand the script to the virtualenv's own interpreter so every import resolves
natively.

Import this before anything that needs those dependencies. It uses the
standard library only.
"""

from __future__ import annotations

import os
import sys
from pathlib import Path

PKG_DIR = Path(__file__).resolve().parent

#: Set while re-executing, so a misconfigured interpreter cannot loop forever.
REEXEC_GUARD = "PHOTO_ARCHIVE_REEXEC"

#: Interpreter override applying to every tool. A per-tool variable named
#: '<TOOL>_PYTHON' takes precedence over it.
PYTHON_OVERRIDE = "PHOTO_ARCHIVE_PYTHON"


def venv_candidates(tool: str) -> tuple[Path, ...]:
    """Fallback virtualenv locations, tried in order.

    These are a convenience, not a requirement: an activated virtualenv always
    wins, and nothing here imposes a layout. The package's parent is included
    because the tools live one directory deeper than they used to, and a venv
    created beside the old scripts must keep being found.
    """
    return (
        PKG_DIR / ".venv",
        PKG_DIR / "venv",
        PKG_DIR.parent / ".venv",
        PKG_DIR.parent / "venv",
        Path("~/.local/share/photo_archive/venv").expanduser(),
        Path(f"~/.local/share/{tool}/venv").expanduser(),
    )


def venv_python(tool: str) -> Path | None:
    """Find a virtualenv interpreter to run under, or None to stay put."""
    for name in (f"{tool.upper()}_PYTHON", PYTHON_OVERRIDE):
        override = os.environ.get(name)
        if override:
            candidate = Path(override).expanduser()
            return candidate if candidate.is_file() else None

    # An activated virtualenv that somehow is not the running interpreter.
    active = os.environ.get("VIRTUAL_ENV")
    if active:
        candidate = Path(active) / "bin" / "python"
        if candidate.is_file():
            return candidate

    for venv in venv_candidates(tool):
        candidate = venv / "bin" / "python"
        if candidate.is_file():
            return candidate
    return None


def reexec(tool: str, script: Path) -> None:
    """Hand this run to a virtualenv interpreter, if a suitable one exists.

    Deliberately does nothing when already inside a virtualenv, so an activated
    environment is always respected.
    """
    if os.environ.get(REEXEC_GUARD):
        return
    if sys.prefix != sys.base_prefix:
        return  # already running inside a virtualenv; use it as-is

    target = venv_python(tool)
    if target is None:
        return
    # Deliberately compared unresolved: a virtualenv's bin/python is a symlink
    # to the base interpreter, so resolving both sides makes any venv look
    # identical to the Python already running and the re-exec never happens.
    # Loop protection is the guard variable above, not this check.
    if target == Path(sys.executable):
        return

    os.environ[REEXEC_GUARD] = "1"
    try:
        os.execv(str(target), [str(target), str(script), *sys.argv[1:]])
    except OSError as exc:  # pragma: no cover - execv essentially never fails
        del os.environ[REEXEC_GUARD]
        print(f"warning: could not run under {target}: {exc}", file=sys.stderr)

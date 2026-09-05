"""TOML configuration and runtime dependency checks."""

from __future__ import annotations

import argparse
import shutil
import sys
from pathlib import Path
from typing import Any, Sequence

from photo_archive.util import LOG

#: Settings whose values are paths, so a string from the config file gets
#: expanded ('~/Photo') rather than handed to argparse as a bare str.
PATH_SETTINGS = frozenset({"path", "work", "log", "csv", "park_dir"})


def load_config(path: Path) -> dict[str, Any]:
    """Read the TOML config, returning {} when absent or unreadable.

    A broken config must not stop a long archive run, so parse errors are
    reported and then ignored rather than raised.
    """
    if not path.is_file():
        return {}
    try:
        import tomllib
    except ImportError:  # Python < 3.11
        print(
            f"warning: ignoring {path} (this Python has no tomllib)",
            file=sys.stderr,
        )
        return {}
    try:
        with path.open("rb") as handle:
            return tomllib.load(handle)
    except Exception as exc:  # noqa: BLE001 - a bad config should not be fatal
        print(f"warning: ignoring {path}: {exc}", file=sys.stderr)
        return {}


def has_settings(config: dict[str, Any]) -> bool:
    """True only if some table actually carries a key.

    A freshly written template parses into empty tables, which must not be
    reported as though settings had been loaded.
    """
    return any(isinstance(table, dict) and table for table in config.values())


def defaults_for(config: dict[str, Any], command: str) -> dict[str, Any]:
    """Merge [defaults] with the command's own table, the latter winning."""
    merged: dict[str, Any] = {}
    for section in ("defaults", command):
        table = config.get(section)
        if isinstance(table, dict):
            merged.update(table)
    return merged


def apply_defaults(
    parser: argparse.ArgumentParser,
    config: dict[str, Any],
    command: str,
    path_settings: frozenset[str] = PATH_SETTINGS,
) -> list[str]:
    """Override a subparser's defaults from config; return unknown keys."""
    settings = defaults_for(config, command)
    if not settings:
        return []

    known = {action.dest for action in parser._actions if action.dest != "help"}
    accepted: dict[str, Any] = {}
    unknown: list[str] = []
    for key, value in settings.items():
        if key not in known:
            unknown.append(key)
            continue
        if key in path_settings and isinstance(value, str):
            value = Path(value).expanduser()
        accepted[key] = value

    if accepted:
        parser.set_defaults(**accepted)
    return unknown


def apply_to_subparsers(
    subparsers: argparse._SubParsersAction,
    config: dict[str, Any],
    path_settings: frozenset[str] = PATH_SETTINGS,
) -> None:
    """Push config defaults into every subcommand and warn about typos."""
    if not has_settings(config):
        return

    every_option: set[str] = set()
    for name, sub in subparsers.choices.items():
        apply_defaults(sub, config, name, path_settings)
        every_option.update(action.dest for action in sub._actions)

    # A setting no subcommand accepts is almost certainly a typo. Settings that
    # merely do not apply to every subcommand (interval, say) are fine and must
    # not warn.
    configured: set[str] = set()
    for section in ("defaults", *subparsers.choices):
        table = config.get(section)
        if isinstance(table, dict):
            configured.update(table)
    for key in sorted(configured - every_option):
        print(f"warning: unknown config setting: {key}", file=sys.stderr)


def cmd_config(args: argparse.Namespace, template: str) -> int:
    """Show where config is read from, or write a starter template."""
    path: Path = args.config
    if args.init:
        if path.exists() and not args.force:
            LOG.error("%s already exists (use --force to overwrite)", path)
            return 1
        if args.dry_run:
            LOG.info("[dry-run] would write template to %s", path)
            return 0
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(template, encoding="utf-8")
        LOG.info("wrote template: %s", path)
        return 0

    LOG.info("config file : %s", path)
    LOG.info("exists      : %s", "yes" if path.is_file() else "no")
    config = load_config(path)
    if has_settings(config):
        LOG.info("")
        LOG.info("Parsed contents:")
        for section, table in config.items():
            LOG.info("  [%s]", section)
            if isinstance(table, dict):
                for key, value in table.items():
                    LOG.info("    %s = %r", key, value)
    elif path.is_file():
        LOG.info("")
        LOG.info("No settings active (every key is commented out).")
    else:
        LOG.info("")
        LOG.info("No config file. Create one with:")
        LOG.info("  %s config --init", Path(sys.argv[0]).name)
    return 0


def check_dependencies(tools: Sequence[str], install_hint: str) -> None:
    missing = [tool for tool in tools if not shutil.which(tool)]
    if missing:
        raise SystemExit(
            "missing required tool(s): "
            + ", ".join(missing)
            + f"\ninstall with: {install_hint}"
        )

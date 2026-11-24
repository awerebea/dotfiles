#!/usr/bin/env python3
"""Resume Claude Code sessions by the name given with /rename, from anywhere.

Claude Code writes a `custom-title` record into the session transcript on
/rename. This tool keeps a registry (JSON) of named sessions by session ID,
with the name and the directory each session was started in (names may
repeat across directories):

- `hook` is run by a Claude Code SessionEnd hook and updates the registry
  from the ending session's transcript.
- `sync` rebuilds the registry from all transcripts (covers sessions that
  ended before the hook was installed or that crashed).
- `resume NAME` looks the name up, changes to the session's directory and
  replaces itself with `claude --resume SESSION_ID`.

Sessions that are open right now are read from Claude Code's own
<config dir>/sessions/<pid>.json files, so a /rename is visible at once,
without waiting for the session to end.

With -a/--all, commands also show unnamed and removed sessions, found by
scanning the transcripts. `remove -P` (ctrl-alt-d in the picker) deletes a
session's data for good, closing it first if it is open.
"""

from __future__ import annotations

import argparse
import contextlib
import dataclasses
import fcntl
import json
import logging
import re
import os
import shlex
import shutil
import signal
import subprocess
import sys
import tempfile
import termios
import time
import tty
from collections.abc import Iterator, Sequence
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, TextIO

# Semantic version: MAJOR for breaking CLI or behavior changes, MINOR for new
# features, PATCH for fixes. Bump it with every change to this script.
__version__ = "0.14.0"

# Canonical program name for the version output (GNU: a constant, never
# derived from argv[0]); usage and error messages use the invoked name (PROG).
PROG_NAME = "claude-session"
PROG = Path(sys.argv[0]).name
# Short options that take a value. Used to enforce GNU rules that argparse does
# not: `-c=x` is rejected instead of silently meaning `-c x`.
SHORT_VALUE_OPTS = "crbdsCL"
# Settings: environment variable names double as config file keys
ENV_CONFIG = "CLAUDE_SESSION_CONFIG"
ENV_REGISTRY = "CLAUDE_SESSION_REGISTRY"
ENV_CLAUDE_BIN = "CLAUDE_SESSION_CLAUDE_BIN"
ENV_KEY_REMOVE = "CLAUDE_SESSION_KEY_REMOVE"
ENV_KEY_RENAME = "CLAUDE_SESSION_KEY_RENAME"
ENV_KEY_INFO = "CLAUDE_SESSION_KEY_INFO"
ENV_KEY_PURGE = "CLAUDE_SESSION_KEY_PURGE"
ENV_KEY_ALL = "CLAUDE_SESSION_KEY_ALL"
ENV_KEY_TITLES = "CLAUDE_SESSION_KEY_TITLES"
ENV_KEY_DATES = "CLAUDE_SESSION_KEY_DATES"
ENV_KEY_SORT = "CLAUDE_SESSION_KEY_SORT"
ENV_KEY_REVERSE = "CLAUDE_SESSION_KEY_REVERSE"
ENV_AI_TITLE = "CLAUDE_SESSION_AI_TITLE"
ENV_DATE = "CLAUDE_SESSION_DATE"
ENV_SORT = "CLAUDE_SESSION_SORT"
ENV_REVERSE = "CLAUDE_SESSION_REVERSE"
ENV_COLOR = "CLAUDE_SESSION_COLOR"
ENV_LOG_LEVEL = "CLAUDE_SESSION_LOG_LEVEL"
CONFIG_KEYS = {
    ENV_REGISTRY,
    ENV_CLAUDE_BIN,
    ENV_KEY_REMOVE,
    ENV_KEY_RENAME,
    ENV_KEY_INFO,
    ENV_KEY_PURGE,
    ENV_KEY_ALL,
    ENV_KEY_TITLES,
    ENV_KEY_DATES,
    ENV_KEY_SORT,
    ENV_KEY_REVERSE,
    ENV_AI_TITLE,
    ENV_DATE,
    ENV_SORT,
    ENV_REVERSE,
    ENV_COLOR,
    ENV_LOG_LEVEL,
}
DEFAULT_CONFIG = (
    Path(os.environ.get("XDG_CONFIG_HOME") or Path.home() / ".config")
    / "claude-session"
    / "claude-session.conf"
)
DEFAULT_CLAUDE_BIN = "claude"
# Claude Code's own config dir; transcripts live in <dir>/projects/*/*.jsonl
CLAUDE_DIR = Path(os.environ.get("CLAUDE_CONFIG_DIR") or Path.home() / ".claude")
DEFAULT_REGISTRY = CLAUDE_DIR / "session-registry.json"
REGISTRY_FORMAT = 2
# Shortest session ID prefix accepted in place of a name
MIN_ID_PREFIX = 8
# Unnamed sessions are shown by this many leading characters of their ID
SHORT_ID = 8
# Session IDs are UUIDs; anything else is refused before deleting files
SESSION_ID_PATTERN = re.compile(r"[0-9A-Za-z][0-9A-Za-z_-]*")
# AI titles longer than this are cut in tables
TITLE_WIDTH = 60
# Seconds an open session gets to exit after SIGTERM, then after SIGKILL
TERM_GRACE = 5
KILL_GRACE = 2
# fzf exit code for Esc / Ctrl-C
FZF_CANCELLED = 130
# Picker keys (fzf key names), configurable like the settings above
DEFAULT_KEY_REMOVE = "ctrl-d"
DEFAULT_KEY_RENAME = "ctrl-r"
DEFAULT_KEY_INFO = "ctrl-o"
DEFAULT_KEY_PURGE = "ctrl-alt-d"
DEFAULT_KEY_ALL = "alt-a"
DEFAULT_KEY_TITLES = "alt-t"
# Not alt-d: fzf deletes a word of the query with it
DEFAULT_KEY_DATES = "alt-c"
DEFAULT_KEY_SORT = "alt-s"
DEFAULT_KEY_REVERSE = "alt-r"
# Picker action -> (setting, default key), in the order the header lists them
PICKER_KEYS = {
    "remove": (ENV_KEY_REMOVE, DEFAULT_KEY_REMOVE),
    "purge": (ENV_KEY_PURGE, DEFAULT_KEY_PURGE),
    "rename": (ENV_KEY_RENAME, DEFAULT_KEY_RENAME),
    "info": (ENV_KEY_INFO, DEFAULT_KEY_INFO),
    "scope": (ENV_KEY_ALL, DEFAULT_KEY_ALL),
    "titles": (ENV_KEY_TITLES, DEFAULT_KEY_TITLES),
    "dates": (ENV_KEY_DATES, DEFAULT_KEY_DATES),
    "sort": (ENV_KEY_SORT, DEFAULT_KEY_SORT),
    "reverse": (ENV_KEY_REVERSE, DEFAULT_KEY_REVERSE),
}
# Actions that change what the picker shows; the others act on sessions
VIEW_ACTIONS = ("scope", "titles", "dates", "sort", "reverse")
# Values the view keys cycle through, the first one being the default
SCOPES = ("named", "all", "unnamed")
DATE_COLUMNS = ("active", "created", "both")
SORT_KEYS = ("active", "created", "name", "path", "status")
SORT_LABELS = {
    "active": "last active",
    "created": "created",
    "name": "name",
    "path": "directory",
    "status": "status",
}
# Natural order: newest first for dates; A-Z, open first otherwise
DESCENDING_SORTS = {"active", "created"}
STATUS_RANK = {"open": 0, "": 1, "hidden": 2}
PICKER_TITLES = {
    "resume": "Resume Claude Session",
    "manage": "Manage Claude Sessions",
    "info": "Claude Session Info",
    "rename": "Rename Claude Session",
    "remove": "Remove Claude Sessions",
}
# --log-level: what the log messages on stderr include; every level also
# includes the more severe ones. Results (Removed:, Renamed:, ...) are not
# log messages and are always shown.
LOG_LEVELS = ("error", "warning", "info", "debug")
DEFAULT_LOG_LEVEL = "warning"
# --color: auto colors a stream only when it is a terminal and NO_COLOR is
# unset, always colors it even when piped, never colors anything
COLOR_MODES = ("auto", "always", "never")


@dataclasses.dataclass
class ColorSetting:
    mode: str = COLOR_MODES[0]


# Set once by main() from --color, the environment or the config file
COLOR = ColorSetting()
# Colors as in fzf-git-branches
COLOR_RESET = "\033[0m"
COLOR_BLUE = "\033[34m"
COLOR_RED = "\033[31m"
COLOR_RED_BOLD = "\033[1;31m"
COLOR_GREEN_BOLD = "\033[1;32m"
COLOR_YELLOW_BOLD = "\033[1;33m"
COLOR_GREEN = "\033[32m"
COLOR_YELLOW = "\033[33m"
COLOR_MAGENTA = "\033[35m"
COLOR_BOLD = "\033[1m"
COLOR_DIM = "\033[2m"
COLOR_CYAN = "\033[36m"
# Lines of the last prompt shown by `info`
INFO_PROMPT_LINES = 15
ANSI_ESCAPE = re.compile(r"\033\[[0-9;]*m")
# Relative dates: (below this many seconds, count in units of, unit name)
RELATIVE_UNITS = (
    (90, 1, "second"),
    (90 * 60, 60, "minute"),
    (36 * 3600, 3600, "hour"),
    (14 * 86400, 86400, "day"),
    (70 * 86400, 7 * 86400, "week"),
    (365 * 86400, 30 * 86400, "month"),
)
SECONDS_PER_YEAR = 365 * 86400
SECONDS_PER_MONTH = 30 * 86400


class AppError(Exception):
    """An expected failure, reported as 'Error: <message>' with exit code 1."""


log = logging.getLogger(PROG_NAME)

LOG_LEVEL_HELP = (
    f"what to log on stderr: {', '.join(LOG_LEVELS)} "
    f"(env: {ENV_LOG_LEVEL}, default: {DEFAULT_LOG_LEVEL})"
)
VERBOSE_HELP = "same as --log-level info (unless a more detailed level is set)"
COLOR_HELP = (
    "color the output: auto (in terminals), always (also when piped) or "
    f"never (env: {ENV_COLOR}, default: auto)"
)


def add_output_options(
    parser: argparse.ArgumentParser, after_command: bool = False
) -> None:
    """--color, --log-level and --verbose, accepted before and after the
    command. After it they stay unset unless given, so that a value given
    before the command is kept."""
    unset: dict[str, Any] = {"default": argparse.SUPPRESS} if after_command else {}
    parser.add_argument("-C", "--color", choices=COLOR_MODES, help=COLOR_HELP, **unset)
    parser.add_argument(
        "-L",
        "--log-level",
        choices=LOG_LEVELS,
        metavar="LEVEL",
        help=LOG_LEVEL_HELP,
        **unset,
    )
    parser.add_argument(
        "-v", "--verbose", action="store_true", help=VERBOSE_HELP, **unset
    )


def build_parser() -> argparse.ArgumentParser:
    # Options shared by all commands, accepted after the command name
    common = argparse.ArgumentParser(add_help=False, allow_abbrev=False)
    common.add_argument(
        "-c",
        "--config",
        metavar="FILE",
        type=Path,
        help=f"config file (env: {ENV_CONFIG}, default: {DEFAULT_CONFIG})",
    )
    common.add_argument(
        "-r",
        "--registry",
        metavar="FILE",
        help=f"registry file (env: {ENV_REGISTRY}, default: {DEFAULT_REGISTRY})",
    )
    add_output_options(common, after_command=True)
    common.add_argument(
        "--version",
        action="version",
        version=f"{PROG_NAME} {__version__}",
        help="show the version and exit",
    )

    # Which sessions to show and how; for commands that list or pick sessions
    scope = argparse.ArgumentParser(add_help=False, allow_abbrev=False)
    which = scope.add_mutually_exclusive_group()
    which.add_argument(
        "-a",
        "--all",
        action="store_true",
        help="include unnamed and removed sessions (scans all transcripts)",
    )
    which.add_argument(
        "-u",
        "--unnamed",
        action="store_true",
        help="show only unnamed sessions (scans all transcripts)",
    )
    scope.add_argument(
        "-t",
        "--ai-title",
        action="store_true",
        help=(
            "show the AI title of each session, or its first prompt "
            f"(env: {ENV_AI_TITLE}=1)"
        ),
    )
    scope.add_argument(
        "-d",
        "--date",
        choices=DATE_COLUMNS,
        help=f"date columns: last active, created or both (env: {ENV_DATE})",
    )
    scope.add_argument(
        "-s",
        "--sort",
        choices=SORT_KEYS,
        help=(
            "sort by last active or created (newest first), name, directory "
            f"(A-Z) or status (open first) (env: {ENV_SORT}, default: active)"
        ),
    )
    scope.add_argument(
        "-R",
        "--reverse",
        action="store_true",
        help=f"reverse the sort order (env: {ENV_REVERSE}=1)",
    )

    def add_command(
        name: str, summary: str, scoped: bool = False, aliases: Sequence[str] = ()
    ) -> argparse.ArgumentParser:
        return commands.add_parser(
            name,
            aliases=list(aliases),
            parents=[common, scope] if scoped else [common],
            allow_abbrev=False,
            help=summary,
            description=f"{PROG_NAME} {__version__}\n{summary}.",
            formatter_class=argparse.RawDescriptionHelpFormatter,
        )

    parser = argparse.ArgumentParser(
        prog=PROG,
        description=(
            f"{PROG_NAME} {__version__}\n"
            "Resume Claude Code sessions by the name given with /rename."
        ),
        epilog=(
            "Hook setup (~/.claude/settings.json):\n"
            '  "hooks": {"SessionEnd": [{"hooks": [{"type": "command",\n'
            f'    "command": "{PROG_NAME} hook"}}]}}]}}\n\n'
            f"Without a command, '{PROG_NAME} manage' runs.\n"
            "Precedence: command line > environment > config file > default."
        ),
        formatter_class=argparse.RawDescriptionHelpFormatter,
        allow_abbrev=False,
    )
    parser.add_argument(
        "--version",
        action="version",
        version=f"{PROG_NAME} {__version__}",
        help="show the version and exit",
    )
    add_output_options(parser)
    commands = parser.add_subparsers(dest="command", metavar="COMMAND", required=True)
    commands.add_parser("version", help="show the version and exit")
    commands.add_parser("help", help="show this help and exit")

    resume = add_command(
        "resume",
        "Pick a session to resume (alias: manage, also the default command)",
        scoped=True,
        aliases=["manage"],
    )
    resume.add_argument(
        "-H",
        "--here",
        action="store_true",
        help="stay in the current directory instead of the session's one",
    )
    resume.add_argument(
        "-b",
        "--claude-bin",
        metavar="PATH",
        help=f"claude executable (env: {ENV_CLAUDE_BIN}, default: claude)",
    )
    resume.add_argument(
        "-f",
        "--force",
        action="store_true",
        help="resume even if the session is open in another terminal",
    )
    resume.add_argument(
        "-n",
        "--dry-run",
        action="store_true",
        help="print the command instead of running it",
    )
    resume.add_argument(
        "-1",
        "--select-1",
        action="store_true",
        help="resume without the picker when NAME matches a single session",
    )
    resume.usage = f"{PROG} resume|manage [OPTIONS] [NAME...] [-- CLAUDE_ARG...]"
    resume.add_argument(
        "name",
        nargs="*",
        metavar="NAME",
        help=(
            "the picker's initial query; words are joined with spaces. A session "
            "ID (or a prefix of 8+ characters) resumes it directly. Without fzf "
            "or a terminal, NAME is a session name, a unique prefix of it or an "
            "ID, and a name shared by several sessions means the one started in "
            "the current directory"
        ),
    )
    resume.epilog = (
        "Arguments after '--' are passed to claude (e.g. -- --model opus).\n"
        "Choosing a session that is open in a tmux pane offers to switch to it.\n\n"
        "Picker keys (ask before changing anything):\n"
        f"  {DEFAULT_KEY_REMOVE:<11} remove the selected sessions from the list\n"
        f"  {DEFAULT_KEY_PURGE:<11} delete the selected sessions' data, "
        "closing open ones\n"
        f"  {DEFAULT_KEY_RENAME:<11} rename the session under the cursor\n"
        f"  {DEFAULT_KEY_INFO:<11} show its info\n"
        f"  {'ctrl-t':<11} select, ctrl-y or enter: accept\n"
        "View keys (until the picker closes):\n"
        f"  {DEFAULT_KEY_ALL:<11} cycle sessions: named, all, unnamed\n"
        f"  {DEFAULT_KEY_TITLES:<11} show or hide the AI title column\n"
        f"  {DEFAULT_KEY_DATES:<11} cycle date columns: last active, created, both\n"
        f"  {DEFAULT_KEY_SORT:<11} cycle sort: last active, created, name, "
        "directory, status\n"
        f"  {DEFAULT_KEY_REVERSE:<11} reverse the sort order\n"
        "Change them with CLAUDE_SESSION_KEY_<ACTION> (env or config), e.g.\n"
        f"{ENV_KEY_PURGE}=ctrl-x; ACTION is REMOVE, PURGE, RENAME, INFO, ALL,\n"
        "TITLES, DATES, SORT or REVERSE."
    )

    info = add_command("info", "Show what is known about a session", scoped=True)
    info.usage = f"{PROG} info [OPTIONS] [NAME...]"
    info.add_argument(
        "name",
        nargs="*",
        metavar="NAME",
        help=(
            "session name, a unique prefix of it or a session ID; "
            "without NAME, pick with fzf"
        ),
    )

    list_cmd = add_command(
        "list", "List registered and open named sessions", scoped=True
    )
    list_cmd.add_argument(
        "-j", "--json", action="store_true", help="print the sessions as JSON"
    )
    list_cmd.add_argument(
        "-l",
        "--long",
        action="store_true",
        help="also show the full session ID and when it was registered",
    )
    list_cmd.add_argument(
        "-N", "--names", action="store_true", help="print only names, one per line"
    )

    add_command("hook", "Update the registry from a SessionEnd hook event on stdin")

    sync = add_command("sync", "Rebuild the registry from all Claude Code transcripts")
    sync.add_argument(
        "-p",
        "--prune",
        action="store_true",
        help="drop entries whose transcript no longer exists",
    )
    sync.add_argument(
        "-n", "--dry-run", action="store_true", help="show changes without saving them"
    )

    rename = add_command(
        "rename",
        "Rename a session (writes a custom-title record, as /rename does)",
        scoped=True,
    )
    rename.add_argument(
        "old", metavar="OLD", help="current name or session ID (names may repeat)"
    )
    rename.add_argument("new", metavar="NEW", help="new name")

    remove = add_command(
        "remove",
        "Remove sessions from the list (sync skips them until renamed), "
        "or delete their data with -P",
        scoped=True,
    )
    remove.add_argument(
        "-P",
        "--purge",
        action="store_true",
        help=(
            "delete the sessions' transcripts and other data for good, closing "
            "open ones first (asks first)"
        ),
    )
    remove.add_argument(
        "names", nargs="+", metavar="NAME", help="session names or IDs to remove"
    )

    completion = add_command("completion", "Print a shell completion script")
    completion.add_argument("shell", choices=["zsh"], help="shell to complete for")
    completion.epilog = (
        f"Example: {PROG_NAME} completion zsh > ~/.oh-my-zsh/completions/_{PROG_NAME}"
    )
    return parser


def reject_short_equals(argv: Sequence[str]) -> None:
    """Reject `-c=value`: under GNU rules only long options take `=`."""
    take_value = False
    for arg in argv:
        if arg == "--":
            return
        if take_value:
            take_value = False
            continue
        if not arg.startswith("-") or arg.startswith("--") or arg == "-":
            continue
        chars = arg[1:]
        for i, char in enumerate(chars):
            if char in SHORT_VALUE_OPTS:
                rest = chars[i + 1 :]
                if rest.startswith("="):
                    raise AppError(
                        f"'-{char}=...' is not supported; use '-{char} VALUE', "
                        f"'-{char}VALUE' or the long form with '='"
                    )
                take_value = not rest
                break


def load_config(path: Path, explicit: bool) -> dict[str, str]:
    """Read KEY=VALUE lines as data (never executed)."""
    if not path.is_file():
        if explicit:
            raise AppError(f"Config file not found: {path}")
        return {}
    config: dict[str, str] = {}
    for number, raw in enumerate(
        path.read_text(encoding="utf-8").splitlines(), start=1
    ):
        line = raw.strip()
        if not line or line.startswith("#"):
            continue
        line = line.removeprefix("export ")
        key, sep, value = line.partition("=")
        if not sep:
            warn(f"{path}:{number}: ignoring invalid line")
            continue
        if key not in CONFIG_KEYS:
            warn(f"{path}:{number}: ignoring unknown key '{key}'")
            continue
        if len(value) > 1 and value[0] in "\"'" and value.endswith(value[0]):
            value = value[1:-1]
        if value.startswith("~/"):
            value = str(Path.home() / value[2:])
        config[key] = value
    return config


def resolve(
    cli: str | None, env_name: str, config: dict[str, str], default: str = ""
) -> str:
    """Precedence: command line > environment > config file > default."""
    for value in (cli, os.environ.get(env_name), config.get(env_name)):
        if value:
            return value
    return default


def settings(args: argparse.Namespace) -> dict[str, str]:
    """The config file's settings, read once per run."""
    if "settings" not in vars(args):
        explicit = args.config is not None or bool(os.environ.get(ENV_CONFIG))
        config_path = args.config or Path(os.environ.get(ENV_CONFIG) or DEFAULT_CONFIG)
        args.config_path = config_path.expanduser()
        args.settings = load_config(args.config_path, explicit)
    config: dict[str, str] = args.settings
    return config


def registry_path(args: argparse.Namespace, config: dict[str, str]) -> Path:
    path = Path(
        resolve(args.registry, ENV_REGISTRY, config, str(DEFAULT_REGISTRY))
    ).expanduser()
    log.info("Registry: %s", path)
    return path


def now() -> str:
    return datetime.now(timezone.utc).isoformat(timespec="seconds")


# Registry layout: {"version": 2,
#   "sessions": {SESSION_ID: {"name", "cwd", "transcript", "updated"}},
#   "hidden": {SESSION_ID: {"title", "transcript"}}}
# Names need not be unique: sessions in different directories may share one.
# Hidden sessions were removed by the user; sync and the hook skip them until
# the session gets a different title.


@dataclasses.dataclass
class Registry:
    sessions: dict[str, dict[str, str]] = dataclasses.field(default_factory=dict)
    hidden: dict[str, dict[str, str]] = dataclasses.field(default_factory=dict)


def upgrade_v1(sessions: dict[str, Any]) -> dict[str, dict[str, str]]:
    """Format 1 keyed sessions by name, so a name could hold only one."""
    upgraded = {}
    for name, entry in sessions.items():
        if isinstance(entry, dict) and isinstance(entry.get("session_id"), str):
            fields = {k: v for k, v in entry.items() if k != "session_id"}
            upgraded[entry["session_id"]] = {"name": name, **fields}
    return upgraded


def load_registry(path: Path) -> Registry:
    log.debug("Reading the registry %s", path)
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except FileNotFoundError:
        log.info("No registry yet at %s", path)
        return Registry()
    except (OSError, ValueError) as exc:
        raise AppError(f"Cannot read registry {path}: {exc}") from exc
    sessions = data.get("sessions") if isinstance(data, dict) else None
    hidden = data.get("hidden", {}) if isinstance(data, dict) else None
    if not isinstance(sessions, dict) or not isinstance(hidden, dict):
        raise AppError(f"Unexpected registry format in {path}")
    version = data.get("version")
    if version == 1:
        log.info("Upgrading the registry from format 1 to %d", REGISTRY_FORMAT)
        sessions = upgrade_v1(sessions)
    elif version != REGISTRY_FORMAT:
        raise AppError(f"Unsupported registry format {version!r} in {path}")
    return Registry(sessions, hidden)


def save_registry(path: Path, registry: Registry) -> None:
    """Write atomically: a temporary file in the same directory, then rename."""
    log.debug(
        "Writing the registry %s: %d sessions, %d hidden",
        path,
        len(registry.sessions),
        len(registry.hidden),
    )
    path.parent.mkdir(parents=True, exist_ok=True)
    fd, tmp = tempfile.mkstemp(dir=path.parent, prefix=f".{path.name}.", suffix=".tmp")
    try:
        with os.fdopen(fd, "w", encoding="utf-8") as fh:
            json.dump(
                {
                    "version": REGISTRY_FORMAT,
                    "sessions": dict(sorted(registry.sessions.items())),
                    "hidden": dict(sorted(registry.hidden.items())),
                },
                fh,
                indent=2,
                ensure_ascii=False,
            )
            fh.write("\n")
        os.replace(tmp, path)
    finally:
        with contextlib.suppress(FileNotFoundError):
            os.unlink(tmp)


@contextlib.contextmanager
def locked(path: Path) -> Iterator[None]:
    """Serialize read-modify-write cycles of concurrent sessions."""
    path.parent.mkdir(parents=True, exist_ok=True)
    lock_path = path.with_name(f"{path.name}.lock")
    with lock_path.open("a", encoding="utf-8") as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        yield


@dataclasses.dataclass
class TranscriptSummary:
    session_id: str | None = None
    # Last custom title; None when never named or the name was cleared
    title: str | None = None
    cwd: str | None = None
    ai_title: str = ""
    first_prompt: str = ""


def wanted_line(line: str, found: TranscriptSummary, titles: bool) -> bool:
    """Cheap substring test before parsing a line as JSON."""
    if (found.cwd is None and '"cwd"' in line) or '"custom-title"' in line:
        return True
    if not titles:
        return False
    return '"ai-title"' in line or (not found.first_prompt and '"type":"user"' in line)


def summarize(found: TranscriptSummary, record: dict[str, Any]) -> None:
    if found.cwd is None and isinstance(record.get("cwd"), str):
        found.cwd = record["cwd"]
    kind = record.get("type")
    if kind == "custom-title":
        value = record.get("customTitle")
        if isinstance(value, str):
            # An empty title means the name was cleared
            found.title = value.strip() or None
        if isinstance(record.get("sessionId"), str):
            found.session_id = record["sessionId"]
    elif kind == "ai-title" and isinstance(record.get("aiTitle"), str):
        found.ai_title = record["aiTitle"]
    elif kind == "user" and not found.first_prompt and not record.get("isSidechain"):
        message = record.get("message")
        text = typed_prompt(record, message) if isinstance(message, dict) else None
        # Slash commands and their output are stored as <tags>
        if text and not text.lstrip().startswith("<"):
            found.first_prompt = " ".join(text.split())


def read_transcript(path: Path, titles: bool = False) -> TranscriptSummary:
    """Session ID, last custom title and cwd of a transcript; with `titles`,
    also its AI title and first typed prompt.

    Only lines that can match are parsed as JSON, so scanning many large
    transcripts stays fast.
    """
    found = TranscriptSummary()
    try:
        with path.open(encoding="utf-8", errors="replace") as fh:
            for line in fh:
                if not wanted_line(line, found, titles):
                    continue
                try:
                    record = json.loads(line)
                except ValueError:
                    continue
                if isinstance(record, dict):
                    summarize(found, record)
    except OSError as exc:
        raise AppError(f"Cannot read transcript {path}: {exc.strerror}") from exc
    return found


def apply_entry(
    registry: Registry,
    session_id: str,
    title: str | None,
    cwd: str | None,
    transcript: Path,
) -> list[str]:
    """Register `title` for `session_id`; return messages about the changes."""
    sessions = registry.sessions
    previous = sessions.get(session_id)
    if title is None:
        # The name was cleared
        if previous is None:
            return []
        del sessions[session_id]
        unregistered = paint("Unregistered:", COLOR_YELLOW_BOLD)
        return [f"{unregistered} {describe(session_id, previous)}"]
    messages: list[str] = []
    hidden = registry.hidden.get(session_id)
    if hidden is not None:
        if hidden.get("title") == title:
            return messages
        # Renamed since it was removed: the user wants it back
        del registry.hidden[session_id]
        renamed = paint(title, COLOR_YELLOW_BOLD)
        messages.append(
            f"{paint('Unhidden', COLOR_GREEN_BOLD)} session "
            f"{paint(session_id, COLOR_MAGENTA)}: renamed to '{renamed}'"
        )
    entry = {"name": title, "cwd": cwd or "", "transcript": str(transcript)}
    if previous is None or {k: previous.get(k) for k in entry} != entry:
        sessions[session_id] = {**entry, "updated": now()}
        messages.append(
            f"{paint('Registered:', COLOR_GREEN_BOLD)} {describe(session_id, entry)}"
        )
    return messages


def pid_alive(pid: int) -> bool:
    try:
        os.kill(pid, 0)
    except ProcessLookupError:
        return False
    except PermissionError:
        return True
    return True


def live_sessions() -> dict[str, dict[str, str]]:
    """Sessions that are open right now, by session ID.

    Running Claude Code instances keep <config dir>/sessions/<pid>.json with
    the session name; `nameSource` is "user" for /rename and --name, other
    names are derived ones and not shown.
    """
    sessions: dict[str, dict[str, str]] = {}
    for path in (CLAUDE_DIR / "sessions").glob("*.json"):
        try:
            data = json.loads(path.read_text(encoding="utf-8"))
        except (OSError, ValueError) as exc:
            log.debug("Skipping %s: %s", path, exc)
            continue  # being rewritten or not ours
        if not isinstance(data, dict):
            continue
        name, session_id, pid = data.get("name"), data.get("sessionId"), data.get("pid")
        if not isinstance(session_id, str) or not isinstance(pid, int):
            continue
        if not pid_alive(pid):
            log.debug("Skipping %s: pid %d has exited", path.name, pid)
            continue
        log.debug("Open session %s (pid %d, %s)", session_id, pid, path.name)
        named = data.get("nameSource") == "user" and isinstance(name, str)
        sessions[session_id] = {
            "name": str(name) if named else "",
            "cwd": str(data.get("cwd") or ""),
            "open_pid": str(pid),
            "tmux": str(data.get("tmux") or ""),
        }
        for field, key in (("updatedAt", "active"), ("startedAt", "started")):
            milliseconds = data.get(field)
            if isinstance(milliseconds, int):
                sessions[session_id][key] = str(milliseconds / 1000)
    return sessions


@dataclasses.dataclass
class View:
    """Which sessions a command shows and how."""

    # A SCOPES value: registered and open named sessions; also unnamed and
    # removed ones, found by scanning all transcripts; or only unnamed ones
    scope: str = SCOPES[0]
    # The AI title column (the first prompt when there is no AI title)
    titles: bool = False
    # A DATE_COLUMNS value: which date columns to show
    dates: str = DATE_COLUMNS[0]
    # A SORT_KEYS value, and whether to flip its natural order
    sort: str = SORT_KEYS[0]
    reverse: bool = False
    # Skip the resume picker when the query matches a single session
    select_one: bool = False

    def date_columns(self) -> list[str]:
        """Date columns shown; the one sorted by always is."""
        shown = ["active", "created"] if self.dates == "both" else [self.dates]
        if self.sort in DATE_COLUMNS and self.sort not in shown:
            shown = ["active", "created"]
        return shown

    def describe(self) -> str:
        order = SORT_LABELS[self.sort] + (", reversed" if self.reverse else "")
        return f"{self.scope} sessions, by {order}"


def cycle(values: Sequence[str], current: str) -> str:
    return values[(values.index(current) + 1) % len(values)]


def next_view(view: View, action: str) -> View:
    """The view after pressing the picker key of a VIEW_ACTIONS action."""
    if action == "scope":
        return dataclasses.replace(view, scope=cycle(SCOPES, view.scope))
    if action == "titles":
        return dataclasses.replace(view, titles=not view.titles)
    if action == "dates":
        return dataclasses.replace(view, dates=cycle(DATE_COLUMNS, view.dates))
    if action == "sort":
        return dataclasses.replace(view, sort=cycle(SORT_KEYS, view.sort))
    return dataclasses.replace(view, reverse=not view.reverse)


def summary_title(summary: TranscriptSummary) -> str:
    return summary.ai_title or summary.first_prompt


def scan_transcripts(
    registry: Registry, sessions: dict[str, dict[str, str]], titles: bool
) -> None:
    """Add every transcript not in `sessions`: unnamed sessions get an empty
    name and removed ones a "hidden" mark."""
    transcripts = list((CLAUDE_DIR / "projects").glob("*/*.jsonl"))
    log.info("Scanning %d transcripts", len(transcripts))
    for transcript in transcripts:
        session_id = transcript.stem
        if session_id in sessions:
            continue
        log.debug("Reading %s", transcript)
        summary = read_transcript(transcript, titles)
        entry = {
            "name": summary.title or "",
            "cwd": summary.cwd or "",
            "transcript": str(transcript),
        }
        if session_id in registry.hidden:
            entry["hidden"] = "1"
        if titles:
            entry["title"] = summary_title(summary)
        sessions[session_id] = entry


def add_details(sessions: dict[str, dict[str, str]], view: View) -> None:
    """The AI title and creation time, when the view shows them."""
    created = "created" in view.date_columns()
    for session_id, entry in sessions.items():
        if view.titles and "title" not in entry:
            found = find_transcript(session_id, entry)
            details = read_transcript(found, True) if found else None
            entry["title"] = summary_title(details) if details else ""
        if created:
            stamp = created_at(session_id, entry)
            entry["created"] = "" if stamp is None else str(stamp)


def collect_sessions(path: Path, view: View) -> dict[str, dict[str, str]]:
    """Registered sessions plus open ones; an open session's current name
    wins. Unless view.scope is "named", every transcript too (see
    scan_transcripts); "unnamed" keeps only the sessions without a name.
    """
    registry = load_registry(path)
    sessions = {i: dict(e) for i, e in registry.sessions.items()}
    scan = view.scope != "named"
    if scan:
        scan_transcripts(registry, sessions, view.titles)
    for session_id, live in live_sessions().items():
        known = sessions.get(session_id)
        if known is None and not (live["name"] or scan):
            continue
        merged = {**(known or {}), **live}
        merged["name"] = live["name"] or (known or {}).get("name", "")
        sessions[session_id] = merged
    if view.scope == "unnamed":
        sessions = {i: e for i, e in sessions.items() if not e.get("name")}
    add_details(sessions, view)
    log.info(
        "%d sessions shown (%s): %d registered, %d open",
        len(sessions),
        view.describe(),
        len(registry.sessions),
        sum(1 for e in sessions.values() if e.get("open_pid")),
    )
    return sessions


def first_timestamp(path: Path) -> float | None:
    """When the first timestamped record of a transcript was written."""
    try:
        with path.open(encoding="utf-8", errors="replace") as fh:
            for line in fh:
                if '"timestamp"' not in line:
                    continue
                try:
                    record = json.loads(line)
                except ValueError:
                    continue
                stamp = (
                    parse_time(record.get("timestamp"))
                    if isinstance(record, dict)
                    else None
                )
                if stamp:
                    return stamp.timestamp()
    except OSError:
        return None
    return None


def created_at(session_id: str, entry: dict[str, str]) -> float | None:
    """The transcript's first record, else when the open session started
    (which may be a later resume), else the transcript's creation time."""
    transcript = find_transcript(session_id, entry)
    stamp = first_timestamp(transcript) if transcript else None
    if stamp is None and entry.get("started"):
        stamp = float(entry["started"])
    if stamp is None and transcript:
        with contextlib.suppress(OSError):
            info = transcript.stat()
            stamp = float(getattr(info, "st_birthtime", info.st_mtime))
    return stamp


def tmux_pane(entry: dict[str, str]) -> str:
    """The pane of a tmux location such as "session:@window.%pane"."""
    pane = entry.get("tmux", "").rpartition(".")[2]
    return pane if pane.startswith("%") else ""


def open_hint(session_id: str, entry: dict[str, str]) -> str:
    pid = paint(entry["open_pid"], COLOR_CYAN)
    opened = paint("already open", COLOR_GREEN_BOLD)
    hint = f"Session {label(session_id, entry)} is {opened} (pid {pid})"
    pane = tmux_pane(entry)
    if pane:
        command = paint(f"tmux switch-client -t '{pane}'", COLOR_BOLD)
        hint += f"; switch to it with: {command}"
    return f"{hint}. Use {paint('-f/--force', COLOR_BOLD)} to resume it anyway"


def current_dirs() -> set[str]:
    """The working directory, both as given by the shell and resolved."""
    return {os.getcwd(), os.environ.get("PWD", "")} - {""}


def match_sessions(
    sessions: dict[str, dict[str, str]], query: str, prefixes: bool = True
) -> list[str]:
    """Session IDs a query refers to, best matches only.

    A session ID or an ID prefix of MIN_ID_PREFIX or more characters; an exact
    name; with `prefixes`, a name prefix (case-insensitive). When all matches
    share one name, the session started in the current directory wins.
    """
    if query in sessions:
        return [query]
    matches = sorted(i for i, e in sessions.items() if e.get("name") == query)
    if not matches and len(query) >= MIN_ID_PREFIX:
        matches = sorted(i for i in sessions if i.startswith(query))
    if not matches and prefixes:
        lowered = query.casefold()
        matches = sorted(
            i
            for i, e in sessions.items()
            if e.get("name") and e["name"].casefold().startswith(lowered)
        )
    if len({sessions[i].get("name") for i in matches}) == 1:
        here = [i for i in matches if sessions[i].get("cwd") in current_dirs()]
        if len(here) == 1:
            return here
    return matches


def display_path(path: str) -> str:
    home = str(Path.home())
    if path == home or path.startswith(f"{home}/"):
        return f"~{path[len(home) :]}"
    return path


def label(session_id: str, entry: dict[str, str]) -> str:
    """'name' for named sessions, (short ID) for unnamed ones."""
    name = entry.get("name")
    if name:
        return f"'{paint(name, COLOR_YELLOW_BOLD)}'"
    return f"({paint(session_id[:SHORT_ID], COLOR_MAGENTA)})"


def describe(session_id: str, entry: dict[str, str]) -> str:
    """One line telling sessions with the same name apart."""
    where = display_path(entry.get("cwd", "")) or "unknown directory"
    if not entry.get("name"):
        return f"{paint(session_id, COLOR_MAGENTA)} in {where}"
    name = paint(entry["name"], COLOR_YELLOW_BOLD)
    return f"'{name}' in {where} ({paint(session_id, COLOR_MAGENTA)})"


def can_pick() -> bool:
    return (
        shutil.which("fzf") is not None and sys.stdin.isatty() and sys.stderr.isatty()
    )


def colors_on() -> bool:
    """Whether to build colored text at all; echo() strips it again for a
    stream that is not to be colored."""
    if COLOR.mode == "auto":
        return not os.environ.get("NO_COLOR")
    return COLOR.mode == "always"


def paint(text: str, color: str) -> str:
    return f"{color}{text}{COLOR_RESET}" if colors_on() and text and color else text


def echo(text: str = "", stream: TextIO | None = None, end: str = "\n") -> None:
    """Print to stderr, or to `stream`; without colors unless --color is
    always, or auto and the stream is a terminal."""
    stream = stream or sys.stderr
    if not (COLOR.mode == "always" or (colors_on() and stream.isatty())):
        text = ANSI_ESCAPE.sub("", text)
    print(text, end=end, file=stream, flush=True)


LOG_PREFIXES = {
    logging.ERROR: ("Error:", COLOR_RED_BOLD),
    logging.WARNING: ("Warning:", COLOR_YELLOW_BOLD),
}


class LogHandler(logging.Handler):
    """Log messages on stderr, colored and stripped like other output:
    'Error: ...', 'Warning: ...', plain info, dimmed debug."""

    def emit(self, record: logging.LogRecord) -> None:
        try:
            text = record.getMessage()
            if record.levelno >= logging.WARNING:
                prefix, color = LOG_PREFIXES[min(record.levelno, logging.ERROR)]
                text = f"{paint(prefix, color)} {text}"
            elif record.levelno < logging.INFO:
                text = paint(text, COLOR_DIM)
            echo(text)
        except Exception:
            # Reported the way logging reports its own failures
            self.handleError(record)


def configure_logging(level: str) -> None:
    """Send log messages of the given level (see LOG_LEVELS) and above to stderr."""
    if not log.handlers:
        log.addHandler(LogHandler())
        log.propagate = False
    log.setLevel(level.upper())


def warn(text: str) -> None:
    log.warning("%s", text)


def report(text: str) -> None:
    log.error("%s", text)


def run_command(
    command: Sequence[str], **kwargs: Any
) -> subprocess.CompletedProcess[str]:
    """subprocess.run with text I/O, logged at debug level."""
    log.debug("Running: %s", shlex.join(command))
    result = subprocess.run(command, text=True, check=False, **kwargs)
    log.debug("Exit code %d: %s", result.returncode, command[0])
    return result


def done(verb: str, text: str, stream: TextIO | None = None) -> None:
    """A result line such as 'Removed: ...'."""
    echo(f"{paint(verb, COLOR_GREEN_BOLD)} {text}", stream)


def dim(text: str) -> None:
    echo(paint(text, COLOR_DIM))


def fzf_colors(spec: str = "") -> list[str]:
    """fzf's own colors follow --color too (it honors NO_COLOR itself)."""
    if COLOR.mode == "never":
        return ["--no-color"]
    return [f"--color={spec}"] if spec else []


def plural(count: int, unit: str) -> str:
    return f"{count} {unit}{'' if count == 1 else 's'}"


def relative_time(timestamp: float) -> str:
    """Git-style relative date: '45 seconds ago', '2 years, 3 months ago'."""
    seconds = max(0, round(time.time() - timestamp))
    for limit, size, unit in RELATIVE_UNITS:
        if seconds < limit:
            return f"{plural(seconds // size, unit)} ago"
    years, rest = divmod(seconds, SECONDS_PER_YEAR)
    months = rest // SECONDS_PER_MONTH
    if months:
        return f"{plural(years, 'year')}, {plural(months, 'month')} ago"
    return f"{plural(years, 'year')} ago"


def last_active(entry: dict[str, str]) -> float | None:
    """Live sessions report it; otherwise the transcript's modification time."""
    if entry.get("active"):
        return float(entry["active"])
    transcript = entry.get("transcript")
    if transcript:
        with contextlib.suppress(OSError):
            return Path(transcript).stat().st_mtime
    with contextlib.suppress(ValueError):
        return datetime.fromisoformat(entry.get("updated", "")).timestamp()
    return None


def shorten(text: str, width: int) -> str:
    return text if len(text) <= width else f"{text[: width - 3]}..."


def status_of(entry: dict[str, str]) -> tuple[str, str]:
    """Status text and its color."""
    if entry.get("open_pid"):
        return "open", COLOR_GREEN_BOLD
    if entry.get("hidden"):
        return "hidden", COLOR_RED
    return "", ""


def sort_sessions(
    sessions: dict[str, dict[str, str]], view: View, first: frozenset[str]
) -> list[str]:
    """Session IDs in view.sort order, those in `first` before the rest;
    ties stay newest active first."""
    active = {i: last_active(entry) or 0.0 for i, entry in sessions.items()}
    order = sorted(sessions, key=lambda i: active[i], reverse=True)

    def key(session_id: str) -> tuple[Any, ...]:
        entry = sessions[session_id]
        if view.sort == "created":
            return (float(entry.get("created") or 0),)
        if view.sort == "name":
            # Named sessions first, then unnamed ones by ID
            name = entry.get("name", "")
            return (0, name.casefold()) if name else (1, session_id)
        if view.sort == "path":
            return (entry.get("cwd", "").casefold(),)
        if view.sort == "status":
            return (STATUS_RANK[status_of(entry)[0]],)
        return (active[session_id],)

    order.sort(key=key, reverse=view.sort in DESCENDING_SORTS)
    if view.reverse:
        order.reverse()
    return sorted(order, key=lambda i: i not in first)


def relative_cell(timestamp: float | None) -> tuple[str, str]:
    return (f"({relative_time(timestamp)})" if timestamp else "", COLOR_BLUE)


def session_rows(
    sessions: dict[str, dict[str, str]],
    view: View,
    long: bool = False,
    first: frozenset[str] = frozenset(),
) -> tuple[str, list[tuple[str, list[str]]]]:
    """Column header and (session ID, padded colored cells) per session, in
    view.sort order; columns are two spaces apart.

    Named sessions show as [name], unnamed ones as (short ID), the way
    fzf-git-branches shows local and remote branches. `long` adds the full
    session ID and the registration time. The sorted column's header is
    marked "^" (ascending) or "v" (descending).
    """
    order = sort_sessions(sessions, view, first)
    dates = view.date_columns()
    columns = ["name", "path", "status"]
    if long:
        columns[1:1] = ["id"]
    columns += dates
    if long:
        columns.append("registered")
    if view.titles:
        columns.append("title")
    titles = {
        "name": "Name (ID)",
        "id": "Session ID",
        "path": "Directory",
        "status": "Status",
        "active": "Last active",
        "created": "Created",
        "registered": "Registered",
        "title": "AI title",
    }
    descending = (view.sort in DESCENDING_SORTS) != view.reverse
    titles[view.sort] += " v" if descending else " ^"
    header = [titles[column] for column in columns]
    # Cells are (plain, colored) text; the plain text sets the column widths
    table: list[list[tuple[str, str]]] = []
    for session_id in order:
        entry = sessions[session_id]
        name = entry.get("name")
        if name:
            label_cell = (f"[{name}]", f"[{paint(name, COLOR_YELLOW_BOLD)}]")
        else:
            short = session_id[:SHORT_ID]
            label_cell = (f"({short})", f"({paint(short, COLOR_MAGENTA)})")
        registered = parse_time(entry.get("updated"))
        values = {
            "id": (session_id, COLOR_MAGENTA),
            "path": (display_path(entry.get("cwd", "")), ""),
            "status": status_of(entry),
            "active": relative_cell(last_active(entry)),
            "created": relative_cell(float(entry.get("created") or 0)),
            "registered": relative_cell(registered.timestamp() if registered else None),
            "title": (shorten(entry.get("title", ""), TITLE_WIDTH), ""),
        }
        cells = [label_cell]
        cells += [(values[c][0], paint(*values[c])) for c in columns if c != "name"]
        table.append(cells)
    widths = [
        max([len(header[column]), *(len(row[column][0]) for row in table)])
        for column in range(len(header))
    ]
    head = "  ".join(
        f"{text:<{width}}" for text, width in zip(header, widths, strict=True)
    )
    lines = []
    for session_id, row in zip(order, table, strict=True):
        padded = [
            colored + " " * (width - len(text))
            for (text, colored), width in zip(row, widths, strict=True)
        ]
        lines.append((session_id, padded))
    return head.rstrip(), lines


@dataclasses.dataclass
class PickerMode:
    """What the picker is for: a PICKER_TITLES key, its keys and whether
    several sessions can be selected."""

    purpose: str
    keys: dict[str, str]
    multi: bool = True
    # Sessions whose name matches the NAME argument, listed first
    first: frozenset[str] = frozenset()


def picker_keys(config: dict[str, str]) -> dict[str, str]:
    keys = {
        action: resolve(None, env_name, config, default)
        for action, (env_name, default) in PICKER_KEYS.items()
    }
    if len(set(keys.values())) != len(keys):
        names = ", ".join(env_name for env_name, _ in PICKER_KEYS.values())
        raise AppError(f"Picker keys must differ: {names}")
    return keys


def run_fzf(
    sessions: dict[str, dict[str, str]], query: str, view: View, mode: PickerMode
) -> tuple[str, str, list[str]]:
    """Show the picker; return (query, action, chosen session IDs).

    The action is a PICKER_KEYS action or "" (Enter). Several sessions can be
    selected for removal; the other actions take the one under the cursor,
    so they clear the selection first. Enter does too, except when the
    picker chooses sessions to remove.
    """
    fzf = shutil.which("fzf")
    if fzf is None:
        raise AppError("fzf not found")
    keys, purpose, multi = mode.keys, mode.purpose, mode.multi
    columns, rows = session_rows(sessions, view, first=mode.first)
    actions = [a for a in PICKER_KEYS if a not in VIEW_ACTIONS]
    hints = ", ".join(f"{keys[action]}:{action}" for action in actions)
    hints += ", ctrl-t:toggle+down, ctrl-y:accept" if multi else ", ctrl-y:accept"
    view_hints = ", ".join(f"{keys[action]}:{action}" for action in VIEW_ACTIONS)
    accept = "accept" if purpose == "remove" else "clear-multi+accept"
    printed = ("rename", "info", *VIEW_ACTIONS)
    command = [
        fzf,
        *fzf_colors(),
        "--ansi",
        "--border=top",
        "--cycle",
        "--height=80%",
        "--reverse",
        "--delimiter=\t",
        "--with-nth=2..",
        # Columns are tab-separated so that only the name and directory are
        # searched; a tab shown one column wide keeps them aligned
        "--nth=1,2",
        "--tabstop=1",
        # Keep the chosen order; the query only filters
        "--no-sort",
        "--print-query",
        f"--expect={keys['remove']},{keys['purge']}",
        f"--bind=enter:{accept},ctrl-y:{accept}",
        *(f"--bind={keys[a]}:clear-multi+print({a})+accept" for a in printed),
        f"--header={paint(PICKER_TITLES[purpose], COLOR_BOLD)} "
        f"({paint(view.describe(), COLOR_CYAN)}): {hints}\n"
        f"View: {view_hints}\n{paint(columns, COLOR_BOLD)}",
        f"--query={query}",
    ]
    if multi:
        command += ["--multi", "--bind=ctrl-t:toggle+down"]
    result = run_command(
        command,
        input="\n".join(
            "\t".join([session_id, *(f"{cell} " for cell in cells)])
            for session_id, cells in rows
        ),
        stdout=subprocess.PIPE,
    )
    if result.returncode == FZF_CANCELLED:
        raise KeyboardInterrupt
    # Output: query, the --expect key (or ""), print() text, selected lines
    query, key, *rest = [*result.stdout.rstrip("\n").split("\n"), "", ""]
    action = {keys["remove"]: "remove", keys["purge"]: "purge"}.get(key, "")
    if rest[0] in printed:
        action, rest = rest[0], rest[1:]
    if action in VIEW_ACTIONS:
        return query, action, []
    chosen = [line.split("\t", 1)[0] for line in rest if line]
    if result.returncode != 0 or not chosen:
        raise AppError("No session selected")
    return query, action, chosen


def confirm(prompt: str, default: bool = False) -> bool:
    """Ask a yes/no question answered by a single key: y is yes, Enter takes
    the default, anything else is no."""
    yes, no = (
        (paint("Y", COLOR_GREEN_BOLD), "n")
        if default
        else ("y", paint("N", COLOR_RED_BOLD))
    )
    echo(f"{prompt} ({yes}|{no}): ", end="")
    fd = sys.stdin.fileno()
    if os.isatty(fd):
        saved = termios.tcgetattr(fd)
        try:
            tty.setcbreak(fd)
            answer = os.read(fd, 1).decode(errors="replace")
        finally:
            termios.tcsetattr(fd, termios.TCSADRAIN, saved)
    else:
        answer = sys.stdin.read(1)
    echo()
    if answer in {"\r", "\n", ""}:
        return default
    return answer in {"y", "Y"}


def prompt_text(message: str, initial: str, header: str) -> str | None:
    """Edit a line that starts as `initial`; None when cancelled.

    fzf serves as the line editor (an empty list, Enter prints the query): it
    looks like the picker and, unlike libedit's readline, can pre-fill text.
    """
    fzf = shutil.which("fzf")
    if fzf is None:
        raise AppError("fzf not found")
    result = run_command(
        [
            fzf,
            # Typed like the names in the picker
            *fzf_colors("prompt:green:bold,query:yellow:bold"),
            "--height=3",
            "--reverse",
            "--disabled",
            "--info=hidden",
            "--no-separator",
            f"--header={header}",
            f"--prompt={message} ",
            f"--query={initial}",
            "--bind=enter:print-query",
        ],
        input="",
        stdout=subprocess.PIPE,
    )
    if result.returncode != 0:
        return None
    return result.stdout.strip()


def picker_remove(
    path: Path,
    chosen: list[str],
    sessions: dict[str, dict[str, str]],
    purge_key: str,
) -> None:
    registered = load_registry(path).sessions
    for session_id in chosen:
        entry = sessions[session_id]
        if entry.get("open_pid"):
            reason = "is open; it cannot be removed"
        elif session_id not in registered:
            reason = f"is not registered; {purge_key} deletes its data"
        else:
            continue
        warn(f"Session {label(session_id, entry)} {reason}")
    chosen = [i for i in chosen if i in registered and not sessions[i].get("open_pid")]
    if not chosen:
        return
    listed = ", ".join(label(i, sessions[i]) for i in chosen)
    entries = (
        "registry entry" if len(chosen) == 1 else f"{len(chosen)} registry entries"
    )
    prompt = (
        f"{paint('Remove', COLOR_RED_BOLD)} {entries} {listed} (transcripts are kept)?"
    )
    if confirm(prompt):
        remove_entries(path, chosen)
        for session_id in chosen:
            done("Removed:", describe(session_id, sessions[session_id]))
    else:
        dim("Remove cancelled")


def picker_rename(path: Path, session_id: str, entry: dict[str, str]) -> None:
    name = entry.get("name", "")
    what = label(session_id, entry)
    if entry.get("open_pid"):
        warn(f"Session {what} is open; rename it with /rename inside that session")
        return
    # An unnamed session gets its first name
    action, message = ("Rename", "New name:") if name else ("Name", "Name:")
    header = (
        f"{paint(action, COLOR_BOLD)} session {what} "
        f"{paint('(enter: save, esc: cancel)', COLOR_DIM)}"
    )
    new = prompt_text(message, name, header)
    if not new or new == name:
        dim(f"{action} cancelled")
        return
    try:
        shared = rename_entry(path, session_id, entry, new)
    except AppError as exc:
        report(str(exc))
        return
    renamed = paint(new, COLOR_YELLOW_BOLD)
    done(f"{action}d:", f"{what} -> '{renamed}'{shared_note(shared)}")


def pick_session(
    path: Path,
    query: str,
    view: View,
    mode: PickerMode,
    only: set[str] | None = None,
) -> tuple[str, list[str], dict[str, dict[str, str]]]:
    """Run the picker until sessions are chosen; actions on sessions and view
    toggles reopen it. `only` limits it to these sessions.

    Return (action, session IDs, sessions shown), where the action is "info"
    or "" (Enter).
    """
    action = ""
    while True:
        sessions = collect_sessions(path, view)
        if only is not None:
            sessions = {i: e for i, e in sessions.items() if i in only}
        # An empty list is fine after a view change: it can be changed back
        if not sessions and action not in VIEW_ACTIONS:
            raise AppError("No sessions left")
        query, action, chosen = run_fzf(sessions, query, view, mode)
        if action in VIEW_ACTIONS:
            view = next_view(view, action)
        elif action == "remove":
            picker_remove(path, chosen, sessions, mode.keys["purge"])
        elif action == "purge":
            purge_sessions(path, chosen, sessions)
        elif action == "rename":
            picker_rename(path, chosen[0], sessions[chosen[0]])
        else:
            return action, chosen, sessions


def exact_id(sessions: dict[str, dict[str, str]], query: str) -> bool:
    """A full session ID, or an ID prefix that is not also a name."""
    if query in sessions:
        return True
    if len(query) < MIN_ID_PREFIX or any(
        e.get("name") == query for e in sessions.values()
    ):
        return False
    return sum(i.startswith(query) for i in sessions) == 1


def choose_sessions(
    path: Path,
    config: dict[str, str],
    query: str,
    view: View,
    purpose: str,
) -> tuple[str, list[str], dict[str, dict[str, str]]]:
    """Resolve a name or session ID (see match_sessions), else ask with the
    picker: limited to the matches when the name is ambiguous, with the name
    as the fuzzy query when it is unknown.

    resume and manage always show the picker, with the name as the query, so
    that open sessions and duplicates are seen first; unless the query is a
    session ID, or view.select_one is set and the name has a single match.

    Return (action, session IDs, sessions) as pick_session does.
    """
    sessions = collect_sessions(path, view)
    if not sessions:
        raise AppError(
            f"No registered sessions (run '{PROG} sync' to scan transcripts, "
            "or use -a/--all)"
        )
    browse = purpose in ("resume", "manage")
    prefixes = browse or purpose == "info"
    matches = match_sessions(sessions, query, prefixes) if query else []
    picker = can_pick()
    if len(matches) == 1 and (
        not (browse and picker) or view.select_one or exact_id(sessions, query)
    ):
        return "", matches, sessions
    if picker:
        # Only the matches of an ambiguous name, one at a time unless removing
        if matches and not browse:
            mode = PickerMode(purpose, picker_keys(config), purpose == "remove")
            return pick_session(path, "", view, mode, set(matches))
        mode = PickerMode(purpose, picker_keys(config), first=frozenset(matches))
        return pick_session(path, query, view, mode)
    if not query:
        raise AppError("NAME is required (fzf picker needs fzf and a terminal)")
    if matches:
        listed = "".join(f"\n  {describe(i, sessions[i])}" for i in matches)
        raise AppError(f"Ambiguous name '{query}'; use a session ID:{listed}")
    raise AppError(
        f"Session not found: {query} (see '{PROG} list' or run '{PROG} sync')"
    )


def shared_note(shared: list[str]) -> str:
    if not shared:
        return ""
    return f" (name shared with {plural(len(shared), 'other session')})"


def ancestors() -> set[int]:
    """PIDs of this process's parents, so a session never kills itself."""
    pids: set[int] = set()
    pid = os.getppid()
    while pid > 1 and pid not in pids:
        pids.add(pid)
        result = run_command(["ps", "-o", "ppid=", "-p", str(pid)], capture_output=True)
        try:
            pid = int(result.stdout.strip())
        except ValueError:
            break
    return pids


def is_claude(pid: int) -> bool:
    """Guard against a reused PID: the process must still be Claude Code."""
    result = run_command(["ps", "-o", "command=", "-p", str(pid)], capture_output=True)
    log.debug("pid %d runs: %s", pid, result.stdout.strip() or "nothing")
    return "claude" in result.stdout


def terminate(pid: int) -> bool:
    """SIGTERM, then SIGKILL after a grace period; True once it is gone."""
    for sig, grace in ((signal.SIGTERM, TERM_GRACE), (signal.SIGKILL, KILL_GRACE)):
        log.info("Sending %s to pid %d", sig.name, pid)
        with contextlib.suppress(ProcessLookupError):
            os.kill(pid, sig)
        deadline = time.monotonic() + grace
        while time.monotonic() < deadline:
            if not pid_alive(pid):
                return True
            time.sleep(0.1)
    return not pid_alive(pid)


def session_files(session_id: str, entry: dict[str, str]) -> list[Path]:
    """What Claude Code keeps for a session: the transcript, the folder next
    to it (tool results, custom-title.json), file history and session env.

    The shared prompt history (history.jsonl) is left alone: open sessions
    append to it.
    """
    if not SESSION_ID_PATTERN.fullmatch(session_id):
        raise AppError(f"Refusing to delete data of odd session ID {session_id!r}")
    paths = [
        CLAUDE_DIR / "file-history" / session_id,
        CLAUDE_DIR / "session-env" / session_id,
    ]
    transcript = find_transcript(session_id, entry)
    projects = (CLAUDE_DIR / "projects").resolve()
    if transcript and transcript.resolve().is_relative_to(projects):
        paths[:0] = [transcript, transcript.with_suffix("")]
    return [p for p in paths if p.exists() or p.is_symlink()]


def disk_usage(path: Path) -> int:
    if path.is_dir() and not path.is_symlink():
        return sum(f.lstat().st_size for f in path.rglob("*") if not f.is_dir())
    return path.lstat().st_size


def delete_path(path: Path) -> None:
    log.info("Deleting %s", path)
    if path.is_dir() and not path.is_symlink():
        shutil.rmtree(path)
    else:
        path.unlink()


def forget(path: Path, session_id: str) -> None:
    """Drop a session from the registry, including its hidden mark."""
    with locked(path):
        registry = load_registry(path)
        known = registry.sessions.pop(session_id, None) is not None
        known = registry.hidden.pop(session_id, None) is not None or known
        if known:
            log.info("Dropping %s from the registry", session_id)
            save_registry(path, registry)


def show_purge_plan(
    chosen: list[str],
    sessions: dict[str, dict[str, str]],
    files: dict[str, list[Path]],
) -> None:
    warning = paint("Purge", COLOR_RED_BOLD)
    echo(
        f"{warning} {plural(len(chosen), 'session')}: the data below is deleted "
        "and cannot be restored"
    )
    for session_id in chosen:
        entry = sessions[session_id]
        echo(f"  {describe(session_id, entry)}")
        if entry.get("open_pid"):
            pane = tmux_pane(entry)
            where = f"pid {entry['open_pid']}" + (f", tmux pane {pane}" if pane else "")
            closing = f"OPEN ({where}): it will be closed first"
            echo(f"    {paint(closing, COLOR_RED_BOLD)}")
        for file in files[session_id]:
            size = format_count(disk_usage(file))
            echo(f"    {display_path(str(file))} {paint(f'({size}B)', COLOR_DIM)}")
        if not files[session_id]:
            dim("    no files found; only the registry entry")


def purge_one(
    path: Path, session_id: str, entry: dict[str, str], files: list[Path]
) -> None:
    pid = int(entry.get("open_pid") or 0)
    if pid and pid_alive(pid) and not (is_claude(pid) and terminate(pid)):
        raise AppError(f"cannot close pid {pid}; {label(session_id, entry)} is kept")
    try:
        for file in files:
            delete_path(file)
    except OSError as exc:
        raise AppError(f"Cannot delete {exc.filename}: {exc.strerror}") from exc
    # After the process is gone: its SessionEnd hook registers it again
    forget(path, session_id)


def purge_sessions(
    path: Path, chosen: list[str], sessions: dict[str, dict[str, str]]
) -> bool:
    """Delete sessions' data for good after one confirmation, closing open
    ones first. Return False when cancelled or nothing was left to purge.
    """
    own = ancestors()
    for session_id in chosen:
        if int(sessions[session_id].get("open_pid") or 0) in own:
            warn(
                f"Session {label(session_id, sessions[session_id])} runs this "
                "command; it cannot be purged from inside itself"
            )
    chosen = [i for i in chosen if int(sessions[i].get("open_pid") or 0) not in own]
    if not chosen:
        return False
    files = {i: session_files(i, sessions[i]) for i in chosen}
    show_purge_plan(chosen, sessions, files)
    if not confirm("Proceed?"):
        dim("Purge cancelled")
        return False
    purged = True
    for session_id in chosen:
        try:
            purge_one(path, session_id, sessions[session_id], files[session_id])
        except AppError as exc:
            report(str(exc))
            purged = False
            continue
        done("Purged:", describe(session_id, sessions[session_id]))
    return purged


@dataclasses.dataclass
class TranscriptInfo:
    started: datetime | None = None
    ended: datetime | None = None
    branch: str = ""
    version: str = ""
    permission_mode: str = ""
    models: list[str] = dataclasses.field(default_factory=list)
    prompts: int = 0
    responses: int = 0
    input_tokens: int = 0
    output_tokens: int = 0
    ai_title: str = ""
    titles: list[str] = dataclasses.field(default_factory=list)
    last_prompt: str = ""
    # Full text of the last typed prompt; last_prompt is stored truncated
    prompt: str = ""
    cost: float | None = None
    duration_ms: int = 0
    lines_added: int = 0
    lines_removed: int = 0


def parse_time(value: object) -> datetime | None:
    if not isinstance(value, str):
        return None
    try:
        # Python 3.10 does not accept the "Z" suffix
        return datetime.fromisoformat(value.replace("Z", "+00:00"))
    except ValueError:
        return None


def number(value: object) -> int:
    return value if isinstance(value, int) else 0


def typed_prompt(record: dict[str, Any], message: dict[str, Any]) -> str | None:
    """Text of a prompt typed by the user; None for tool results and meta."""
    if record.get("isMeta"):
        return None
    content = message.get("content")
    if isinstance(content, str):
        return content
    if not isinstance(content, list):
        return None
    parts = [part for part in content if isinstance(part, dict)]
    if any(part.get("type") == "tool_result" for part in parts):
        return None
    return "\n".join(
        str(part.get("text", "")) for part in parts if part.get("type") == "text"
    )


def add_response(
    info: TranscriptInfo,
    record: dict[str, Any],
    message: dict[str, Any],
    requests: set[str],
) -> None:
    model = message.get("model")
    # Skip placeholders such as <synthetic>
    if isinstance(model, str) and model not in info.models and model[:1] != "<":
        info.models.append(model)
    request = record.get("requestId")
    # One response is stored as several records sharing its usage
    if not isinstance(request, str) or request in requests:
        return
    requests.add(request)
    usage = message.get("usage")
    if isinstance(usage, dict):
        info.input_tokens += (
            number(usage.get("input_tokens"))
            + number(usage.get("cache_creation_input_tokens"))
            + number(usage.get("cache_read_input_tokens"))
        )
        info.output_tokens += number(usage.get("output_tokens"))


def add_metadata(info: TranscriptInfo, kind: object, record: dict[str, Any]) -> None:
    """Records Claude Code writes about the session rather than the chat."""
    if kind == "ai-title" and isinstance(record.get("aiTitle"), str):
        info.ai_title = record["aiTitle"]
    elif kind == "custom-title" and isinstance(record.get("customTitle"), str):
        title = record["customTitle"].strip()
        if title and info.titles[-1:] != [title]:
            info.titles.append(title)
    elif kind == "last-prompt" and isinstance(record.get("lastPrompt"), str):
        info.last_prompt = record["lastPrompt"]
    elif kind == "permission-mode":
        info.permission_mode = str(record.get("permissionMode") or "")
    elif kind == "cost-state":
        cost = record.get("totalCostUSD")
        info.cost = float(cost) if isinstance(cost, (int, float)) else None
        info.duration_ms = number(record.get("totalDuration"))
        info.lines_added = number(record.get("totalLinesAdded"))
        info.lines_removed = number(record.get("totalLinesRemoved"))


def read_details(path: Path) -> TranscriptInfo:
    """Collect what a transcript tells about its session."""
    info = TranscriptInfo()
    requests: set[str] = set()
    try:
        fh = path.open(encoding="utf-8", errors="replace")
    except OSError as exc:
        raise AppError(f"Cannot read transcript {path}: {exc.strerror}") from exc
    with fh:
        for line in fh:
            try:
                record = json.loads(line)
            except ValueError:
                continue
            if not isinstance(record, dict) or record.get("isSidechain"):
                continue
            stamp = parse_time(record.get("timestamp"))
            if stamp:
                info.started = info.started or stamp
                info.ended = stamp
            info.branch = record.get("gitBranch") or info.branch
            info.version = record.get("version") or info.version
            message = record.get("message")
            message = message if isinstance(message, dict) else {}
            kind = record.get("type")
            if kind == "user":
                text = typed_prompt(record, message)
                if text is not None:
                    info.prompts += 1
                    info.prompt = text or info.prompt
            elif kind == "assistant":
                add_response(info, record, message, requests)
            else:
                add_metadata(info, kind, record)
    info.responses = len(requests)
    return info


def find_transcript(session_id: str, entry: dict[str, str]) -> Path | None:
    transcript = entry.get("transcript")
    if transcript and Path(transcript).is_file():
        return Path(transcript)
    for path in (CLAUDE_DIR / "projects").glob(f"*/{session_id}.jsonl"):
        return path
    return None


def format_time(stamp: datetime) -> str:
    local = stamp.astimezone()
    return f"{local:%Y-%m-%d %H:%M:%S %z} ({relative_time(local.timestamp())})"


def format_count(count: int) -> str:
    for size, suffix in ((1_000_000, "M"), (1_000, "k")):
        if count >= size:
            return f"{count / size:.1f}{suffix}"
    return str(count)


def format_duration(milliseconds: int) -> str:
    minutes, seconds = divmod(milliseconds // 1000, 60)
    hours, minutes = divmod(minutes, 60)
    days, hours = divmod(hours, 24)
    if days:
        return f"{days}d {hours}h {minutes:02}m"
    return f"{hours}h {minutes:02}m" if hours else f"{minutes}m {seconds:02}s"


def status_rows(session_id: str, entry: dict[str, str]) -> list[tuple[str, str]]:
    """Name, ID, open status and directory: known without the transcript."""
    rows = [
        ("name", paint(entry.get("name", ""), COLOR_YELLOW_BOLD) or "(unnamed)"),
        ("session id", paint(session_id, COLOR_MAGENTA)),
    ]
    if entry.get("open_pid"):
        pane = tmux_pane(entry)
        where = f"pid {entry['open_pid']}" + (f", tmux pane {pane}" if pane else "")
        rows.append(("status", paint(f"open ({where})", COLOR_GREEN_BOLD)))
    elif entry.get("hidden"):
        rows.append(("status", paint("closed, removed from the list", COLOR_RED)))
    else:
        rows.append(("status", "closed"))
    cwd = entry.get("cwd", "")
    missing = " (no longer exists)" if cwd and not Path(cwd).is_dir() else ""
    rows.append(("directory", f"{paint(cwd, COLOR_BOLD)}{missing}"))
    return rows


def usage_rows(details: TranscriptInfo) -> list[tuple[str, str]]:
    """Model, version and how much the session was used."""
    rows = []
    if details.models:
        rows.append(("model", paint(", ".join(details.models), COLOR_GREEN)))
    if details.version:
        rows.append(("claude code", details.version))
    if details.permission_mode:
        rows.append(("permission mode", details.permission_mode))
    if details.prompts or details.responses:
        messages = (
            f"{plural(details.prompts, 'prompt')}, "
            f"{plural(details.responses, 'response')}"
        )
        rows.append(("messages", messages))
    if details.input_tokens or details.output_tokens:
        tokens = (
            f"{format_count(details.input_tokens)} input (with cache), "
            f"{format_count(details.output_tokens)} output"
        )
        rows.append(("tokens", tokens))
    if details.cost is not None:
        last_run = (
            f"${details.cost:.2f}, {format_duration(details.duration_ms)}, "
            f"+{details.lines_added}/-{details.lines_removed} lines"
        )
        rows.append(("last run", last_run))
    return rows


def session_details(session_id: str, entry: dict[str, str]) -> list[tuple[str, str]]:
    """Rows of (label, colored value) for `info`."""
    rows = status_rows(session_id, entry)
    transcript = find_transcript(session_id, entry)
    details = read_details(transcript) if transcript else TranscriptInfo()
    if details.branch:
        rows.append(("git branch", paint(details.branch, COLOR_GREEN)))
    if details.started:
        rows.append(("started", paint(format_time(details.started), COLOR_BLUE)))
    active = last_active(entry)
    if active is not None:
        stamp = datetime.fromtimestamp(active, tz=timezone.utc)
        rows.append(("last active", paint(format_time(stamp), COLOR_BLUE)))
    rows += usage_rows(details)
    if details.ai_title:
        rows.append(("ai title", details.ai_title))
    earlier = [title for title in details.titles if title != entry.get("name")]
    if earlier:
        rows.append(("earlier names", ", ".join(earlier)))
    size = f" ({format_count(transcript.stat().st_size)}B)" if transcript else ""
    where = display_path(str(transcript)) if transcript else "not found"
    rows.append(("transcript", f"{where}{size}"))
    registered = parse_time(entry.get("updated"))
    if registered:
        rows.append(("registered", paint(format_time(registered), COLOR_BLUE)))
    elif entry.get("open_pid"):
        rows.append(("registered", "not yet (registered when the session ends)"))
    command = shlex.join(["claude", "--resume", session_id])
    if entry.get("cwd"):
        command = f"cd {shlex.quote(entry['cwd'])} && {command}"
    rows.append(("resume with", command))
    last_prompt = details.prompt or details.last_prompt
    if last_prompt.strip():
        lines = last_prompt.strip().splitlines()
        if len(lines) > INFO_PROMPT_LINES:
            lines = [*lines[:INFO_PROMPT_LINES], "..."]
        rows.append(("last prompt", paint("\n".join(lines), COLOR_YELLOW)))
    return rows


def print_details(session_id: str, entry: dict[str, str]) -> None:
    rows = session_details(session_id, entry)
    width = max(len(label) for label, _ in rows)
    indent = " " * (width + 3)
    for label, value in rows:
        # Continuation lines line up with the first value line
        aligned = value.replace("\n", f"\n{indent}")
        echo(f"{paint(f'{label:<{width}}', COLOR_BOLD)} : {aligned}", sys.stdout)


def cmd_hook(args: argparse.Namespace) -> int:
    path = registry_path(args, settings(args))
    try:
        event = json.load(sys.stdin)
    except ValueError as exc:
        raise AppError(f"Invalid hook input: {exc}") from exc
    if not isinstance(event, dict):
        raise AppError("Invalid hook input: expected a JSON object")
    session_id = event.get("session_id")
    transcript = event.get("transcript_path")
    if not isinstance(session_id, str) or not isinstance(transcript, str):
        raise AppError("Hook input lacks session_id or transcript_path")
    transcript_path = Path(transcript).expanduser()
    log.info("SessionEnd of %s (%s)", session_id, transcript_path)
    if not transcript_path.is_file():
        log.info("No transcript at %s; nothing to register", transcript_path)
        return 0
    summary = read_transcript(transcript_path)
    cwd = summary.cwd or (
        event.get("cwd") if isinstance(event.get("cwd"), str) else None
    )
    with locked(path):
        registry = load_registry(path)
        messages = apply_entry(
            registry, session_id, summary.title, cwd, transcript_path
        )
        if messages:
            save_registry(path, registry)
    for message in messages:
        echo(message)
    return 0


def cmd_sync(args: argparse.Namespace) -> int:
    path = registry_path(args, settings(args))
    projects = CLAUDE_DIR / "projects"
    found: list[tuple[str, str, str | None, Path]] = []
    transcripts = sorted(projects.glob("*/*.jsonl"))
    log.info("Scanning %d transcripts in %s", len(transcripts), projects)
    for transcript in transcripts:
        log.debug("Reading %s", transcript)
        summary = read_transcript(transcript)
        if summary.title is not None:
            session_id = summary.session_id or transcript.stem
            found.append((session_id, summary.title, summary.cwd, transcript))
    with locked(path):
        registry = load_registry(path)
        sessions = registry.sessions
        messages = []
        for session_id, title, cwd, transcript in found:
            messages += apply_entry(registry, session_id, title, cwd, transcript)
        if args.prune:
            for session_id in [
                i
                for i, e in sessions.items()
                if not Path(e.get("transcript", "")).is_file()
            ]:
                entry = sessions.pop(session_id)
                pruned = paint("Pruned:", COLOR_YELLOW_BOLD)
                messages.append(f"{pruned} {describe(session_id, entry)}")
            for session_id in [
                i
                for i, e in registry.hidden.items()
                if not Path(e.get("transcript", "")).is_file()
            ]:
                del registry.hidden[session_id]
                hidden = paint(session_id, COLOR_MAGENTA)
                messages.append(
                    f"{paint('Pruned', COLOR_YELLOW_BOLD)} hidden session {hidden}"
                )
        prefix = f"{paint('[dry-run]', COLOR_CYAN)} " if args.dry_run else ""
        for message in messages:
            echo(f"{prefix}{message}", sys.stdout)
        if messages and not args.dry_run:
            save_registry(path, registry)
    counts = (
        f"{paint(str(len(sessions)), COLOR_BOLD)} session(s) registered, "
        f"{paint(str(len(registry.hidden)), COLOR_BOLD)} hidden, "
        f"{paint(str(len(messages)), COLOR_BOLD)} change(s)"
    )
    echo(f"{prefix}{counts}", sys.stdout)
    return 0


def truthy(value: str) -> bool:
    return value.strip().lower() in {"1", "true", "yes", "on"}


def choice(
    cli: str | None,
    env_name: str,
    config: dict[str, str],
    values: Sequence[str],
    default: str | None = None,
) -> str:
    """A setting limited to `values`; the default is the first one unless
    given."""
    value = resolve(cli, env_name, config, default or values[0])
    if value not in values:
        raise AppError(f"{env_name} must be one of: {', '.join(values)}")
    return value


def view_of(args: argparse.Namespace, config: dict[str, str]) -> View:
    scope = "all" if args.all else "unnamed" if args.unnamed else SCOPES[0]
    return View(
        scope=scope,
        titles=args.ai_title or truthy(resolve(None, ENV_AI_TITLE, config)),
        dates=choice(args.date, ENV_DATE, config, DATE_COLUMNS),
        sort=choice(args.sort, ENV_SORT, config, SORT_KEYS),
        reverse=args.reverse or truthy(resolve(None, ENV_REVERSE, config)),
    )


def cmd_list(args: argparse.Namespace) -> int:
    config = settings(args)
    sessions = collect_sessions(registry_path(args, config), view_of(args, config))
    if args.json:
        print(json.dumps(sessions, indent=2, ensure_ascii=False))
        return 0
    if args.names:
        names = {entry.get("name") for entry in sessions.values()}
        for name in sorted(name for name in names if name):
            print(name)
        return 0
    if not sessions:
        dim(
            f"No registered sessions (run '{PROG} sync' to scan transcripts, "
            "or use -a/--all)"
        )
        return 0
    header, rows = session_rows(sessions, view_of(args, config), long=args.long)
    # The header is for people: in a terminal, or with --color=always
    if sys.stdout.isatty() or COLOR.mode == "always":
        echo(paint(header, COLOR_BOLD), sys.stdout)
    for _, cells in rows:
        echo("  ".join(cells).rstrip(), sys.stdout)
    return 0


def switch_to(session_id: str, entry: dict[str, str]) -> bool:
    """Offer to switch to the tmux pane of an open session; True when
    switched, False when declined. Raise when it cannot switch."""
    pane = tmux_pane(entry)
    if not pane or not os.environ.get("TMUX"):
        raise AppError(open_hint(session_id, entry))
    question = (
        f"Session {label(session_id, entry)} is "
        f"{paint('already open', COLOR_GREEN_BOLD)} "
        f"(pid {paint(entry['open_pid'], COLOR_CYAN)}). "
        f"Switch to its tmux pane {paint(pane, COLOR_CYAN)}?"
    )
    if not confirm(question, default=True):
        return False
    log.info("Switching the tmux client to pane %s", pane)
    result = run_command(["tmux", "switch-client", "-t", pane])
    if result.returncode != 0:
        raise AppError(f"'tmux switch-client -t {pane}' failed")
    return True


def cmd_resume(args: argparse.Namespace) -> int:
    config = settings(args)
    path = registry_path(args, config)
    purpose = "manage" if args.command == "manage" else "resume"
    view = dataclasses.replace(view_of(args, config), select_one=args.select_1)
    query = " ".join(args.name)
    action, chosen, sessions = choose_sessions(path, config, query, view, purpose)
    while True:
        session_id = chosen[0]
        entry = sessions[session_id]
        if action == "info":
            print_details(session_id, entry)
            return 0
        if not entry.get("open_pid") or args.force:
            break
        if not can_pick():
            raise AppError(open_hint(session_id, entry))
        if switch_to(session_id, entry):
            return 0
        # Declined: back to the picker
        mode = PickerMode(purpose, picker_keys(config))
        action, chosen, sessions = pick_session(path, query, view, mode)
    return exec_claude(args, config, session_id, entry)


def exec_claude(
    args: argparse.Namespace,
    config: dict[str, str],
    session_id: str,
    entry: dict[str, str],
) -> int:
    claude = resolve(args.claude_bin, ENV_CLAUDE_BIN, config, DEFAULT_CLAUDE_BIN)
    claude_path = shutil.which(claude)
    if claude_path is None:
        raise AppError(f"claude executable not found: {claude}")
    cwd = entry.get("cwd", "")
    if args.here or not cwd:
        cwd = os.getcwd()
    elif not Path(cwd).is_dir():
        raise AppError(f"Session directory no longer exists: {cwd} (use -H/--here)")
    command = [claude, "--resume", session_id, *args.claude_args]
    log.info("Running in %s: %s", cwd, shlex.join(command))
    if args.dry_run:
        print(f"cd {shlex.quote(cwd)} && {shlex.join(command)}")
        return 0
    done("Resuming", f"{label(session_id, entry)} in {paint(cwd, COLOR_BOLD)}")
    os.chdir(cwd)
    os.execv(claude_path, command)
    return 0  # not reached


def append_title(transcript: Path, session_id: str, title: str) -> None:
    """Name the session the way /rename does: a custom-title record, and the
    custom-title.json Claude Code keeps in the folder next to the transcript.
    """
    record = json.dumps(
        {"type": "custom-title", "customTitle": title, "sessionId": session_id},
        ensure_ascii=False,
        separators=(",", ":"),  # compact, as Claude Code writes it
    )
    log.info("Appending a custom-title record to %s", transcript)
    try:
        with transcript.open("ab+") as fh:
            fh.seek(0, os.SEEK_END)
            ends_in_newline = True
            if fh.tell():
                fh.seek(-1, os.SEEK_END)
                ends_in_newline = fh.read(1) == b"\n"
            fh.write(
                ("" if ends_in_newline else "\n").encode() + record.encode() + b"\n"
            )
        folder = transcript.with_suffix("")
        if folder.is_dir():
            log.info("Writing %s", folder / "custom-title.json")
            (folder / "custom-title.json").write_text(
                json.dumps({"customTitle": title}, ensure_ascii=False),
                encoding="utf-8",
            )
    except OSError as exc:
        raise AppError(f"Cannot write {exc.filename}: {exc.strerror}") from exc


def rename_entry(
    path: Path, session_id: str, entry: dict[str, str], new: str
) -> list[str]:
    """Name the session itself (in its transcript) and register it under the
    new name; a removed session comes back. Return the IDs of other sessions
    that already use the new name.
    """
    if session_id in live_sessions():
        # Claude Code is writing that transcript and keeps its own name
        raise AppError(
            f"Session {label(session_id, entry)} is open; "
            "rename it with /rename inside that session"
        )
    transcript = find_transcript(session_id, entry)
    with locked(path):
        registry = load_registry(path)
        known = registry.sessions.get(session_id)
        if transcript is None and known is None:
            raise AppError(f"Session not found: {session_id}")
        if transcript is not None:
            append_title(transcript, session_id, new)
        else:
            warn(
                f"transcript of {label(session_id, entry)} not found; "
                "only the registry entry is renamed"
            )
        registry.hidden.pop(session_id, None)
        registry.sessions[session_id] = {
            "name": new,
            "cwd": (known or entry).get("cwd", ""),
            "transcript": str(transcript or (known or entry).get("transcript", "")),
            "updated": now(),
        }
        save_registry(path, registry)
    return [
        i
        for i, e in registry.sessions.items()
        if e.get("name") == new and i != session_id
    ]


def remove_entries(path: Path, session_ids: Sequence[str]) -> None:
    """Remove entries and hide their sessions from sync and the hook."""
    with locked(path):
        registry = load_registry(path)
        missing = [i for i in session_ids if i not in registry.sessions]
        if missing:
            raise AppError(
                f"Not registered (unnamed or already removed): {', '.join(missing)}; "
                "-P/--purge deletes their data"
            )
        for session_id in session_ids:
            entry = registry.sessions.pop(session_id)
            registry.hidden[session_id] = {
                "title": entry.get("name", ""),
                "transcript": entry.get("transcript", ""),
            }
        save_registry(path, registry)


def cmd_info(args: argparse.Namespace) -> int:
    config = settings(args)
    path = registry_path(args, config)
    _, chosen, sessions = choose_sessions(
        path, config, " ".join(args.name), view_of(args, config), "info"
    )
    print_details(chosen[0], sessions[chosen[0]])
    return 0


def cmd_rename(args: argparse.Namespace) -> int:
    config = settings(args)
    path = registry_path(args, config)
    action, chosen, sessions = choose_sessions(
        path, config, args.old, view_of(args, config), "rename"
    )
    session_id = chosen[0]
    entry = sessions[session_id]
    if action == "info":
        print_details(session_id, entry)
        return 0
    shared = rename_entry(path, session_id, entry, args.new)
    renamed = paint(args.new, COLOR_YELLOW_BOLD)
    done(
        "Renamed:" if entry.get("name") else "Named:",
        f"{label(session_id, entry)} -> '{renamed}'{shared_note(shared)}",
        sys.stdout,
    )
    return 0


def cmd_remove(args: argparse.Namespace) -> int:
    config = settings(args)
    path = registry_path(args, config)
    view = view_of(args, config)
    chosen: list[str] = []
    sessions: dict[str, dict[str, str]] = {}
    for query in args.names:
        action, ids, shown = choose_sessions(path, config, query, view, "remove")
        if action == "info":
            print_details(ids[0], shown[ids[0]])
            return 0
        chosen += ids
        sessions.update(shown)
    chosen = list(dict.fromkeys(chosen))
    if args.purge:
        return 0 if purge_sessions(path, chosen, sessions) else 1
    remove_entries(path, chosen)
    for session_id in chosen:
        done("Removed:", describe(session_id, sessions[session_id]), sys.stdout)
    return 0


ZSH_COMPLETION = r"""#compdef claude-session

# Generated by `claude-session completion zsh`; session names are completed
# from the registry at completion time, so this file rarely needs updating.

_claude-session_names() {
  local -a names
  names=("${(@f)$(claude-session list --names 2>/dev/null)}")
  _wanted session-names expl 'session name' compadd -a names
}

_claude-session() {
  local curcontext="$curcontext" state line ret=1
  local -a common
  local -a scope color
  color=(
    '(-C --color)'{-C+,--color=}'[when to color the output]:when:(auto always never)'
    '(-L --log-level)'{-L+,--log-level=}'[log level]:level:(error warning info debug)'
    '(-v --verbose)'{-v,--verbose}'[same as --log-level info]'
  )
  scope=(
    '(-a --all -u --unnamed)'{-a,--all}'[include unnamed and removed sessions]'
    '(-a --all -u --unnamed)'{-u,--unnamed}'[show only unnamed sessions]'
    '(-t --ai-title)'{-t,--ai-title}'[show the AI title column]'
    '(-d --date)'{-d+,--date=}'[date columns]:date columns:(active created both)'
    '(-s --sort)'{-s+,--sort=}'[sort key]:sort key:(active created name path status)'
    '(-R --reverse)'{-R,--reverse}'[reverse the sort order]'
  )
  common=(
    '(- *)'{-h,--help}'[show help and exit]'
    '(- *)--version[show the version and exit]'
    '(-c --config)'{-c+,--config=}'[config file]:config file:_files'
    '(-r --registry)'{-r+,--registry=}'[registry file]:registry file:_files'
    $color
  )
  _arguments -C \
    '(- *)'{-h,--help}'[show help and exit]' \
    '(- *)--version[show the version and exit]' \
    $color \
    '1:command:->command' \
    '*::argument:->argument' && ret=0
  case $state in
    command)
      local -a commands
      commands=(
        'resume:pick a session to resume'
        'manage:pick a session to resume (alias of resume)'
        'info:show what is known about a session'
        'list:list registered and open named sessions'
        'hook:update the registry from a SessionEnd hook event'
        'sync:rebuild the registry from all transcripts'
        'rename:rename a session'
        'remove:remove sessions from the list or delete their data'
        'completion:print a shell completion script'
        'version:show the version and exit'
        'help:show help and exit'
      )
      _describe -t commands command commands && ret=0
      ;;
    argument)
      curcontext="${curcontext%:*:*}:claude-session-$line[1]:"
      case $line[1] in
        resume|manage)
          _arguments -S $common $scope \
            '(-1 --select-1)'{-1,--select-1}'[skip the picker for a single match]' \
            '(-H --here)'{-H,--here}'[stay in the current directory]' \
            '(-b --claude-bin)'{-b+,--claude-bin=}'[claude executable]:file:_files' \
            '(-f --force)'{-f,--force}'[resume even if the session is open]' \
            '(-n --dry-run)'{-n,--dry-run}'[print the command instead of running it]' \
            '*:session name:_claude-session_names' && ret=0
          ;;
        info)
          _arguments $common $scope '*:session name:_claude-session_names' && ret=0
          ;;
        list)
          _arguments $common $scope \
            '(-j --json -N --names)'{-j,--json}'[print the sessions as JSON]' \
            '(-l --long -N --names)'{-l,--long}'[show session ID and registration]' \
            '(-N --names -j --json -l --long)'{-N,--names}'[print only names]' && ret=0
          ;;
        sync)
          _arguments $common \
            '(-p --prune)'{-p,--prune}'[drop entries whose transcript is gone]' \
            '(-n --dry-run)'{-n,--dry-run}'[show changes without saving them]' && ret=0
          ;;
        rename)
          _arguments $common $scope \
            '1:current name:_claude-session_names' \
            '2:new name:' && ret=0
          ;;
        remove)
          _arguments $common $scope \
            '(-P --purge)'{-P,--purge}'[delete the sessions data for good]' \
            '*:session name:_claude-session_names' && ret=0
          ;;
        completion)
          _arguments $common '1:shell:(zsh)' && ret=0
          ;;
        hook)
          _arguments $common && ret=0
          ;;
      esac
      ;;
  esac
  return ret
}

_claude-session "$@"
"""


def cmd_completion(args: argparse.Namespace) -> int:
    print(ZSH_COMPLETION, end="")
    return 0


COMMANDS = {
    "completion": cmd_completion,
    "hook": cmd_hook,
    "info": cmd_info,
    "list": cmd_list,
    "manage": cmd_resume,
    "remove": cmd_remove,
    "rename": cmd_rename,
    "resume": cmd_resume,
    "sync": cmd_sync,
}


def log_level(args: argparse.Namespace, config: dict[str, str]) -> str:
    """--log-level, raised to info by -v/--verbose."""
    level = choice(args.log_level, ENV_LOG_LEVEL, config, LOG_LEVELS, DEFAULT_LOG_LEVEL)
    if args.verbose and LOG_LEVELS.index(level) < LOG_LEVELS.index("info"):
        level = "info"
    return level


def log_settings(args: argparse.Namespace) -> None:
    config = settings(args)
    found = (
        plural(len(config), "setting") if args.config_path.is_file() else "not found"
    )
    log.info("Config file: %s (%s)", args.config_path, found)
    for key, value in sorted(config.items()):
        log.debug("Config: %s=%s", key, value)


def command_index(argv: Sequence[str]) -> int | None:
    """Where the command is, after the options that may come before it."""
    value = False
    for index, arg in enumerate(argv):
        if value:
            value = False
        elif arg in ("-C", "--color", "-L", "--log-level"):
            value = True
        elif arg == "--":
            return None
        elif not arg.startswith("-"):
            return index
    return None


def main(argv: Sequence[str] | None = None) -> int:
    argv = list(sys.argv[1:] if argv is None else argv)
    parser = build_parser()
    command = command_index(argv)
    if command is None:
        command = argv.index("--") if "--" in argv else len(argv)
        argv.insert(command, "manage")

    # `version` and `help` as the command win over everything else
    if argv[command] == "version":
        print(f"{PROG_NAME} {__version__}")
        return 0
    if argv[command] == "help":
        parser.print_help()
        return 0

    try:
        reject_short_equals(argv)
    except AppError as exc:
        parser.error(str(exc))
    # Everything after `--` goes to claude, so unquoted multi-word names work
    claude_args: list[str] = []
    if argv[command] in ("resume", "manage") and "--" in argv:
        split = argv.index("--")
        argv, claude_args = argv[:split], argv[split + 1 :]
    args = parser.parse_args(argv)
    args.claude_args = claude_args

    configure_logging(DEFAULT_LOG_LEVEL)
    try:
        # From the command line and environment first, so that they also
        # apply to messages about the config file
        configure_logging(log_level(args, {}))
        COLOR.mode = choice(args.color, ENV_COLOR, {}, COLOR_MODES)
        configure_logging(log_level(args, settings(args)))
        COLOR.mode = choice(args.color, ENV_COLOR, settings(args), COLOR_MODES)
        log_settings(args)
        log.info(
            "Color: %s, log level: %s",
            COLOR.mode,
            logging.getLevelName(log.level).lower(),
        )
        return COMMANDS[args.command](args)
    except AppError as exc:
        report(str(exc))
        return 1
    except KeyboardInterrupt:
        echo()
        return 130
    except BrokenPipeError:
        # Output piped into a command that exited early (e.g. `| head`)
        devnull = os.open(os.devnull, os.O_WRONLY)
        os.dup2(devnull, sys.stdout.fileno())
        return 1


if __name__ == "__main__":
    sys.exit(main())

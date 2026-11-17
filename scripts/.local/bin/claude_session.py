#!/usr/bin/env python3
"""Resume Claude Code sessions by the name given with /rename, from anywhere.

Claude Code writes a `custom-title` record into the session transcript on
/rename. This tool keeps a registry (JSON) that maps those names to session
IDs and the directory each session was started in:

- `hook` is run by a Claude Code SessionEnd hook and updates the registry
  from the ending session's transcript.
- `sync` rebuilds the registry from all transcripts (covers sessions that
  ended before the hook was installed or that crashed).
- `resume NAME` looks the name up, changes to the session's directory and
  replaces itself with `claude --resume SESSION_ID`.

Sessions that are open right now are read from Claude Code's own
<config dir>/sessions/<pid>.json files, so a /rename is visible at once,
without waiting for the session to end.
"""

from __future__ import annotations

import argparse
import contextlib
import dataclasses
import fcntl
import json
import os
import shlex
import shutil
import subprocess
import sys
import tempfile
import termios
import time
import tty
from collections.abc import Iterator, Sequence
from datetime import datetime, timezone
from pathlib import Path

# Semantic version: MAJOR for breaking CLI or behavior changes, MINOR for new
# features, PATCH for fixes. Bump it with every change to this script.
__version__ = "0.7.0"

# Canonical program name for the version output (GNU: a constant, never
# derived from argv[0]); usage and error messages use the invoked name (PROG).
PROG_NAME = "claude-session"
PROG = Path(sys.argv[0]).name
# Short options that take a value. Used to enforce GNU rules that argparse does
# not: `-c=x` is rejected instead of silently meaning `-c x`.
SHORT_VALUE_OPTS = "crb"
# Settings: environment variable names double as config file keys
ENV_CONFIG = "CLAUDE_SESSION_CONFIG"
ENV_REGISTRY = "CLAUDE_SESSION_REGISTRY"
ENV_CLAUDE_BIN = "CLAUDE_SESSION_CLAUDE_BIN"
ENV_KEY_REMOVE = "CLAUDE_SESSION_KEY_REMOVE"
ENV_KEY_RENAME = "CLAUDE_SESSION_KEY_RENAME"
CONFIG_KEYS = {ENV_REGISTRY, ENV_CLAUDE_BIN, ENV_KEY_REMOVE, ENV_KEY_RENAME}
DEFAULT_CONFIG = (
    Path(os.environ.get("XDG_CONFIG_HOME") or Path.home() / ".config")
    / "claude-session"
    / "claude-session.conf"
)
DEFAULT_CLAUDE_BIN = "claude"
# Claude Code's own config dir; transcripts live in <dir>/projects/*/*.jsonl
CLAUDE_DIR = Path(os.environ.get("CLAUDE_CONFIG_DIR") or Path.home() / ".claude")
DEFAULT_REGISTRY = CLAUDE_DIR / "session-registry.json"
REGISTRY_FORMAT = 1
# fzf exit code for Esc / Ctrl-C
FZF_CANCELLED = 130
# Picker keys (fzf key names), configurable like the settings above
DEFAULT_KEY_REMOVE = "ctrl-d"
DEFAULT_KEY_RENAME = "ctrl-r"
# Picker colors, as in fzf-git-branches; NO_COLOR turns them off
USE_COLOR = not os.environ.get("NO_COLOR")
COLOR_RESET = "\033[0m"
COLOR_BLUE = "\033[34m"
COLOR_RED_BOLD = "\033[1;31m"
COLOR_GREEN_BOLD = "\033[1;32m"
COLOR_YELLOW_BOLD = "\033[1;33m"
COLOR_BLUE_BOLD = "\033[1;34m"
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
    common.add_argument(
        "--version",
        action="version",
        version=f"{PROG_NAME} {__version__}",
        help="show the version and exit",
    )

    def add_command(name: str, summary: str) -> argparse.ArgumentParser:
        return commands.add_parser(
            name,
            parents=[common],
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
    commands = parser.add_subparsers(dest="command", metavar="COMMAND", required=True)
    commands.add_parser("version", help="show the version and exit")
    commands.add_parser("help", help="show this help and exit")

    resume = add_command("resume", "Resume a registered session by name")
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
    resume.usage = f"{PROG} resume [OPTIONS] [NAME...] [-- CLAUDE_ARG...]"
    resume.add_argument(
        "name",
        nargs="*",
        metavar="NAME",
        help=(
            "session name or a unique prefix of it; words are joined with spaces. "
            "Without NAME, or if it is ambiguous or unknown, pick with fzf"
        ),
    )
    resume.epilog = (
        "Arguments after '--' are passed to claude (e.g. -- --model opus).\n\n"
        f"Picker keys: {DEFAULT_KEY_REMOVE} removes the selected registry entries "
        f"(asks first),\n{DEFAULT_KEY_RENAME} renames the current one, ctrl-t "
        "selects, ctrl-y accepts. "
        f"Change them with {ENV_KEY_REMOVE} and {ENV_KEY_RENAME} (env or config)."
    )

    list_cmd = add_command("list", "List registered and open named sessions")
    list_cmd.add_argument(
        "-j", "--json", action="store_true", help="print the registry as JSON"
    )
    list_cmd.add_argument(
        "-l", "--long", action="store_true", help="also show directory and last update"
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
        "rename", "Rename a session (writes a custom-title record, as /rename does)"
    )
    rename.add_argument("old", metavar="OLD", help="current name")
    rename.add_argument("new", metavar="NEW", help="new name")

    remove = add_command(
        "remove", "Remove registry entries; sync skips them until renamed"
    )
    remove.add_argument("names", nargs="+", metavar="NAME", help="names to remove")

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
            print(f"Warning: {path}:{number}: ignoring invalid line", file=sys.stderr)
            continue
        if key not in CONFIG_KEYS:
            print(
                f"Warning: {path}:{number}: ignoring unknown key '{key}'",
                file=sys.stderr,
            )
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
    explicit = args.config is not None or bool(os.environ.get(ENV_CONFIG))
    config_path = args.config or Path(os.environ.get(ENV_CONFIG) or DEFAULT_CONFIG)
    return load_config(config_path.expanduser(), explicit)


def registry_path(args: argparse.Namespace, config: dict[str, str]) -> Path:
    return Path(
        resolve(args.registry, ENV_REGISTRY, config, str(DEFAULT_REGISTRY))
    ).expanduser()


def now() -> str:
    return datetime.now(timezone.utc).isoformat(timespec="seconds")


# Registry layout: {"version": 1,
#   "sessions": {NAME: {"session_id", "cwd", "transcript", "updated"}},
#   "hidden": {SESSION_ID: {"title", "transcript"}}}
# Hidden sessions were removed by the user; sync and the hook skip them until
# the session gets a different title.


@dataclasses.dataclass
class Registry:
    sessions: dict[str, dict[str, str]] = dataclasses.field(default_factory=dict)
    hidden: dict[str, dict[str, str]] = dataclasses.field(default_factory=dict)


def load_registry(path: Path) -> Registry:
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except FileNotFoundError:
        return Registry()
    except (OSError, ValueError) as exc:
        raise AppError(f"Cannot read registry {path}: {exc}") from exc
    sessions = data.get("sessions") if isinstance(data, dict) else None
    hidden = data.get("hidden", {}) if isinstance(data, dict) else None
    if not isinstance(sessions, dict) or not isinstance(hidden, dict):
        raise AppError(f"Unexpected registry format in {path}")
    return Registry(sessions, hidden)


def save_registry(path: Path, registry: Registry) -> None:
    """Write atomically: a temporary file in the same directory, then rename."""
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


def read_transcript(path: Path) -> tuple[str | None, str | None, str | None]:
    """Return (session_id, last custom title, cwd) found in a transcript.

    Only lines that can match are parsed as JSON, so scanning many large
    transcripts stays fast.
    """
    session_id = title = cwd = None
    try:
        with path.open(encoding="utf-8", errors="replace") as fh:
            for line in fh:
                wants_cwd = cwd is None and '"cwd"' in line
                if not wants_cwd and '"custom-title"' not in line:
                    continue
                try:
                    record = json.loads(line)
                except ValueError:
                    continue
                if not isinstance(record, dict):
                    continue
                if wants_cwd and isinstance(record.get("cwd"), str):
                    cwd = record["cwd"]
                if record.get("type") == "custom-title":
                    value = record.get("customTitle")
                    if isinstance(value, str):
                        # An empty title means the name was cleared
                        title = value.strip() or None
                    if isinstance(record.get("sessionId"), str):
                        session_id = record["sessionId"]
    except OSError as exc:
        raise AppError(f"Cannot read transcript {path}: {exc.strerror}") from exc
    return session_id, title, cwd


def apply_entry(
    registry: Registry,
    session_id: str,
    title: str | None,
    cwd: str | None,
    transcript: Path,
) -> list[str]:
    """Register `title` for `session_id`; return messages about the changes."""
    sessions = registry.sessions
    messages = []
    # A session renamed again must not stay registered under its old name
    for name in [n for n, e in sessions.items() if e.get("session_id") == session_id]:
        if name != title:
            del sessions[name]
            messages.append(f"Unregistered old name: {name}")
    if title is None:
        return messages
    hidden = registry.hidden.get(session_id)
    if hidden is not None:
        if hidden.get("title") == title:
            return messages
        # Renamed since it was removed: the user wants it back
        del registry.hidden[session_id]
        messages.append(f"Unhidden session {session_id}: renamed to '{title}'")
    previous = sessions.get(title)
    if previous and previous.get("session_id") != session_id:
        messages.append(
            f"Name '{title}' moved from session {previous.get('session_id')}"
        )
    entry = {"session_id": session_id, "cwd": cwd or "", "transcript": str(transcript)}
    if previous is None or {k: previous.get(k) for k in entry} != entry:
        sessions[title] = {**entry, "updated": now()}
        messages.append(f"Registered session: {title} -> {session_id}")
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
    """Named sessions that are open right now.

    Running Claude Code instances keep <config dir>/sessions/<pid>.json with
    the session name; `nameSource` is "user" for /rename and --name.
    """
    sessions: dict[str, dict[str, str]] = {}
    for path in (CLAUDE_DIR / "sessions").glob("*.json"):
        try:
            data = json.loads(path.read_text(encoding="utf-8"))
        except (OSError, ValueError):
            continue  # being rewritten or not ours
        if not isinstance(data, dict) or data.get("nameSource") != "user":
            continue
        name, session_id, pid = data.get("name"), data.get("sessionId"), data.get("pid")
        if not (isinstance(name, str) and name and isinstance(session_id, str)):
            continue
        if not isinstance(pid, int) or not pid_alive(pid):
            continue
        sessions[name] = {
            "session_id": session_id,
            "cwd": str(data.get("cwd") or ""),
            "open_pid": str(pid),
            "tmux": str(data.get("tmux") or ""),
        }
        updated_ms = data.get("updatedAt")
        if isinstance(updated_ms, int):
            sessions[name]["active"] = str(updated_ms / 1000)
    return sessions


def merge_live(sessions: dict[str, dict[str, str]]) -> dict[str, dict[str, str]]:
    """Registry plus open sessions; an open session's current name wins."""
    live = live_sessions()
    live_ids = {entry["session_id"] for entry in live.values()}
    merged = {
        name: entry
        for name, entry in sessions.items()
        if entry.get("session_id") not in live_ids
    }
    for name, entry in live.items():
        merged[name] = {**sessions.get(name, {}), **entry}
    return merged


def open_hint(name: str, entry: dict[str, str]) -> str:
    hint = f"Session '{name}' is already open (pid {entry['open_pid']})"
    # tmux location looks like "session:@window.%pane"
    pane = entry.get("tmux", "").rpartition(".")[2]
    if pane.startswith("%"):
        hint += f"; switch to it with: tmux switch-client -t '{pane}'"
    return f"{hint}. Use -f/--force to resume it anyway"


def match_names(sessions: dict[str, dict[str, str]], name: str) -> list[str]:
    """Exact name first, then names starting with it (case-insensitive)."""
    if name in sessions:
        return [name]
    lowered = name.casefold()
    return sorted(n for n in sessions if n.casefold().startswith(lowered))


def display_path(path: str) -> str:
    home = str(Path.home())
    if path == home or path.startswith(f"{home}/"):
        return f"~{path[len(home) :]}"
    return path


def can_pick() -> bool:
    return (
        shutil.which("fzf") is not None and sys.stdin.isatty() and sys.stderr.isatty()
    )


def paint(text: str, color: str) -> str:
    return f"{color}{text}{COLOR_RESET}" if USE_COLOR and text else text


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


def picker_rows(sessions: dict[str, dict[str, str]]) -> tuple[str, list[str]]:
    """Return the column header and one fzf line per session, latest first.

    Each line is "<name>\t<colored row>": fzf shows only the row and the
    bare name is read back from the selection.
    """
    active = {name: last_active(entry) for name, entry in sessions.items()}
    order = sorted(sessions, key=lambda name: active[name] or 0, reverse=True)
    paths = {name: display_path(sessions[name].get("cwd", "")) for name in order}
    columns = ("Name", "Directory", "Status", "Last active")
    name_width = max(len(columns[0]), *(len(name) for name in order))
    path_width = max(len(columns[1]), *(len(path) for path in paths.values()))
    status_width = len(columns[2])
    header = (
        f"{columns[0]:<{name_width}}  {columns[1]:<{path_width}}  "
        f"{columns[2]:<{status_width}}  {columns[3]}"
    )
    lines = []
    for name in order:
        status = "open" if sessions[name].get("open_pid") else ""
        timestamp = active[name]
        date = f"({relative_time(timestamp)})" if timestamp is not None else ""
        row = (
            f"{paint(f'{name:<{name_width}}', COLOR_YELLOW_BOLD)}  "
            f"{paths[name]:<{path_width}}  "
            f"{paint(f'{status:<{status_width}}', COLOR_GREEN_BOLD)}  "
            f"{paint(date, COLOR_BLUE)}"
        )
        lines.append(f"{name}\t{row}")
    return header, lines


def run_fzf(
    sessions: dict[str, dict[str, str]], query: str, keys: dict[str, str]
) -> tuple[str, str, list[str]]:
    """Show the picker; return (query, action, chosen names).

    The action is "remove", "rename" or "" (resume). Several sessions can be
    selected for removal; resume and rename always take the one under the
    cursor, so they clear the selection first.
    """
    fzf = shutil.which("fzf")
    if fzf is None:
        raise AppError("fzf not found")
    columns, lines = picker_rows(sessions)
    hints = (
        f"{keys['remove']}:remove, {keys['rename']}:rename, "
        "ctrl-t:toggle+down, ctrl-y:accept"
    )
    result = subprocess.run(
        [
            fzf,
            "--ansi",
            "--border=top",
            "--cycle",
            "--multi",
            "--height=80%",
            "--reverse",
            "--delimiter=\t",
            "--with-nth=2..",
            "--print-query",
            f"--expect={keys['remove']}",
            "--bind=ctrl-t:toggle+down",
            "--bind=enter:clear-multi+accept,ctrl-y:clear-multi+accept",
            f"--bind={keys['rename']}:clear-multi+print(rename)+accept",
            f"--header=Resume Claude Session: {hints}\n{columns}",
            f"--query={query}",
        ],
        input="\n".join(lines),
        stdout=subprocess.PIPE,
        text=True,
        check=False,
    )
    if result.returncode == FZF_CANCELLED:
        raise KeyboardInterrupt
    # Output: query, the --expect key (or ""), print() text, selected lines
    query, key, *rest = [*result.stdout.rstrip("\n").split("\n"), "", ""]
    action = "remove" if key == keys["remove"] else ""
    if rest[:1] == ["rename"]:
        action, rest = "rename", rest[1:]
    names = [line.split("\t", 1)[0] for line in rest if line]
    if result.returncode != 0 or not names:
        raise AppError("No session selected")
    return query, action, names


def confirm(prompt: str) -> bool:
    """Ask a yes/no question answered by a single key; anything but y is no."""
    print(f"{prompt} (y|N): ", end="", file=sys.stderr, flush=True)
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
    print(file=sys.stderr)
    return answer in {"y", "Y"}


def prompt_text(message: str, initial: str, header: str) -> str | None:
    """Edit a line that starts as `initial`; None when cancelled.

    fzf serves as the line editor (an empty list, Enter prints the query): it
    looks like the picker and, unlike libedit's readline, can pre-fill text.
    """
    fzf = shutil.which("fzf")
    if fzf is None:
        raise AppError("fzf not found")
    result = subprocess.run(
        [
            fzf,
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
        text=True,
        check=False,
    )
    if result.returncode != 0:
        return None
    return result.stdout.strip()


def picker_remove(
    path: Path, names: list[str], sessions: dict[str, dict[str, str]]
) -> None:
    for name in [n for n in names if sessions[n].get("open_pid")]:
        print(f"Session '{name}' is open; it cannot be removed", file=sys.stderr)
    names = [n for n in names if not sessions[n].get("open_pid")]
    if not names:
        return
    listed = ", ".join(f"'{paint(name, COLOR_BLUE_BOLD)}'" for name in names)
    entries = "registry entry" if len(names) == 1 else f"{len(names)} registry entries"
    prompt = (
        f"{paint('Remove', COLOR_RED_BOLD)} {entries} {listed} (transcripts are kept)?"
    )
    if confirm(prompt):
        remove_entries(path, names)
        for name in names:
            print(f"Removed: {name}", file=sys.stderr)


def picker_rename(path: Path, name: str, entry: dict[str, str]) -> None:
    if entry.get("open_pid"):
        print(
            f"Session '{name}' is open; rename it with /rename inside that session",
            file=sys.stderr,
        )
        return
    new = prompt_text("New name:", name, f"Rename session '{name}' (esc: cancel)")
    if not new or new == name:
        print("Rename cancelled", file=sys.stderr)
        return
    try:
        rename_entry(path, name, new)
    except AppError as exc:
        print(f"Error: {exc}", file=sys.stderr)
        return
    print(f"Renamed: {name} -> {new}", file=sys.stderr)


def pick_session(path: Path, config: dict[str, str], query: str) -> str:
    """Run the picker until a session is chosen; remove and rename reopen it."""
    keys = {
        "remove": resolve(None, ENV_KEY_REMOVE, config, DEFAULT_KEY_REMOVE),
        "rename": resolve(None, ENV_KEY_RENAME, config, DEFAULT_KEY_RENAME),
    }
    if keys["remove"] == keys["rename"]:
        raise AppError(f"{ENV_KEY_REMOVE} and {ENV_KEY_RENAME} must differ")
    while True:
        sessions = merge_live(load_registry(path).sessions)
        if not sessions:
            raise AppError("No sessions left")
        query, action, names = run_fzf(sessions, query, keys)
        if action == "remove":
            picker_remove(path, names, sessions)
        elif action == "rename":
            picker_rename(path, names[0], sessions[names[0]])
        else:
            return names[0]


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
    if not transcript_path.is_file():
        return 0
    _, title, cwd = read_transcript(transcript_path)
    cwd = cwd or (event.get("cwd") if isinstance(event.get("cwd"), str) else None)
    with locked(path):
        registry = load_registry(path)
        messages = apply_entry(registry, session_id, title, cwd, transcript_path)
        if messages:
            save_registry(path, registry)
    for message in messages:
        print(message, file=sys.stderr)
    return 0


def cmd_sync(args: argparse.Namespace) -> int:
    path = registry_path(args, settings(args))
    projects = CLAUDE_DIR / "projects"
    found: list[tuple[float, str, str | None, str | None, Path]] = []
    for transcript in projects.glob("*/*.jsonl"):
        session_id, title, cwd = read_transcript(transcript)
        if title is not None:
            found.append(
                (
                    transcript.stat().st_mtime,
                    session_id or transcript.stem,
                    title,
                    cwd,
                    transcript,
                )
            )
    with locked(path):
        registry = load_registry(path)
        sessions = registry.sessions
        messages = []
        # Oldest first, so the most recently active session wins a shared name
        for _, session_id, title, cwd, transcript in sorted(
            found, key=lambda item: item[0]
        ):
            messages += apply_entry(registry, session_id, title, cwd, transcript)
        if args.prune:
            for name in [
                n
                for n, e in sessions.items()
                if not Path(e.get("transcript", "")).is_file()
            ]:
                del sessions[name]
                messages.append(f"Pruned: {name}")
            for session_id in [
                i
                for i, e in registry.hidden.items()
                if not Path(e.get("transcript", "")).is_file()
            ]:
                del registry.hidden[session_id]
                messages.append(f"Pruned hidden session: {session_id}")
        prefix = "[dry-run] " if args.dry_run else ""
        for message in messages:
            print(f"{prefix}{message}")
        if messages and not args.dry_run:
            save_registry(path, registry)
    print(
        f"{prefix}{len(sessions)} session(s) registered, "
        f"{len(registry.hidden)} hidden, {len(messages)} change(s)"
    )
    return 0


def cmd_list(args: argparse.Namespace) -> int:
    sessions = merge_live(load_registry(registry_path(args, settings(args))).sessions)
    if args.json:
        print(json.dumps(sessions, indent=2, ensure_ascii=False))
        return 0
    if args.names:
        for name in sorted(sessions):
            print(name)
        return 0
    if not sessions:
        print(
            f"No registered sessions (run '{PROG} sync' to scan transcripts)",
            file=sys.stderr,
        )
        return 0
    width = max(len(name) for name in sessions)
    for name, entry in sorted(sessions.items()):
        line = f"{name:<{width}}  {entry.get('session_id', '')}"
        if args.long:
            cwd = display_path(entry.get("cwd", ""))
            line += f"  {entry.get('updated', ''):<25}  {cwd}"
        if entry.get("open_pid"):
            line += f"  [open, pid {entry['open_pid']}]"
        print(line)
    return 0


def cmd_resume(args: argparse.Namespace) -> int:
    config = settings(args)
    path = registry_path(args, config)
    sessions = merge_live(load_registry(path).sessions)
    if not sessions:
        raise AppError(
            f"No registered sessions (run '{PROG} sync' to scan transcripts)"
        )
    query = " ".join(args.name)
    matches = match_names(sessions, query) if query else []
    if len(matches) == 1:
        name = matches[0]
    elif can_pick():
        # No name, ambiguous or unknown: the name becomes the fuzzy query
        name = pick_session(path, config, query)
        sessions = merge_live(load_registry(path).sessions)
    elif not query:
        raise AppError("NAME is required (fzf picker needs fzf and a terminal)")
    elif matches:
        raise AppError(f"Ambiguous name '{query}': {', '.join(matches)}")
    else:
        raise AppError(
            f"Session not found: {query} (see '{PROG} list' or run '{PROG} sync')"
        )
    entry = sessions[name]
    if entry.get("open_pid") and not args.force:
        raise AppError(open_hint(name, entry))
    session_id = entry.get("session_id")
    if not session_id:
        raise AppError(f"Registry entry '{name}' has no session ID")
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
    if args.dry_run:
        print(f"cd {shlex.quote(cwd)} && {shlex.join(command)}")
        return 0
    print(f"Resuming '{name}' in {cwd}", file=sys.stderr)
    os.chdir(cwd)
    os.execv(claude_path, command)
    return 0  # not reached


def append_title(transcript: Path, session_id: str, title: str) -> None:
    """Name the session the way /rename does: a custom-title record."""
    record = json.dumps(
        {"type": "custom-title", "customTitle": title, "sessionId": session_id},
        ensure_ascii=False,
        separators=(",", ":"),  # compact, as Claude Code writes it
    )
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
    except OSError as exc:
        raise AppError(f"Cannot write transcript {transcript}: {exc.strerror}") from exc


def rename_entry(path: Path, old: str, new: str) -> None:
    """Rename the session itself (in its transcript) and its registry entry."""
    open_ids = {entry["session_id"] for entry in live_sessions().values()}
    with locked(path):
        registry = load_registry(path)
        sessions = registry.sessions
        if old not in sessions:
            raise AppError(f"Session not found: {old}")
        if new in sessions and new != old:
            raise AppError(f"Name already registered: {new}")
        entry = sessions[old]
        session_id = entry.get("session_id", "")
        if session_id in open_ids:
            # Claude Code is writing that transcript and keeps its own name
            raise AppError(
                f"Session '{old}' is open; rename it with /rename inside that session"
            )
        transcript = Path(entry.get("transcript") or "")
        if entry.get("transcript") and transcript.is_file():
            append_title(transcript, session_id, new)
        else:
            print(
                f"Warning: transcript of '{old}' not found; "
                "only the registry entry is renamed",
                file=sys.stderr,
            )
        sessions[new] = {**sessions.pop(old), "updated": now()}
        save_registry(path, registry)


def remove_entries(path: Path, names: Sequence[str]) -> None:
    """Remove entries and hide their sessions from sync and the hook."""
    with locked(path):
        registry = load_registry(path)
        missing = [name for name in names if name not in registry.sessions]
        if missing:
            raise AppError(f"Session not found: {', '.join(missing)}")
        for name in names:
            entry = registry.sessions.pop(name)
            if entry.get("session_id"):
                registry.hidden[entry["session_id"]] = {
                    "title": name,
                    "transcript": entry.get("transcript", ""),
                }
        save_registry(path, registry)


def cmd_rename(args: argparse.Namespace) -> int:
    rename_entry(registry_path(args, settings(args)), args.old, args.new)
    print(f"Renamed: {args.old} -> {args.new}")
    return 0


def cmd_remove(args: argparse.Namespace) -> int:
    remove_entries(registry_path(args, settings(args)), args.names)
    for name in args.names:
        print(f"Removed: {name}")
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
  common=(
    '(- *)'{-h,--help}'[show help and exit]'
    '(- *)--version[show the version and exit]'
    '(-c --config)'{-c+,--config=}'[config file]:config file:_files'
    '(-r --registry)'{-r+,--registry=}'[registry file]:registry file:_files'
  )
  _arguments -C \
    '(- *)'{-h,--help}'[show help and exit]' \
    '(- *)--version[show the version and exit]' \
    '1:command:->command' \
    '*::argument:->argument' && ret=0
  case $state in
    command)
      local -a commands
      commands=(
        'resume:resume a registered session by name'
        'list:list registered and open named sessions'
        'hook:update the registry from a SessionEnd hook event'
        'sync:rebuild the registry from all transcripts'
        'rename:rename a session'
        'remove:remove registry entries'
        'completion:print a shell completion script'
        'version:show the version and exit'
        'help:show help and exit'
      )
      _describe -t commands command commands && ret=0
      ;;
    argument)
      curcontext="${curcontext%:*:*}:claude-session-$line[1]:"
      case $line[1] in
        resume)
          _arguments -S $common \
            '(-H --here)'{-H,--here}'[stay in the current directory]' \
            '(-b --claude-bin)'{-b+,--claude-bin=}'[claude executable]:file:_files' \
            '(-f --force)'{-f,--force}'[resume even if the session is open]' \
            '(-n --dry-run)'{-n,--dry-run}'[print the command instead of running it]' \
            '*:session name:_claude-session_names' && ret=0
          ;;
        list)
          _arguments $common \
            '(-j --json -N --names)'{-j,--json}'[print the registry as JSON]' \
            '(-l --long -N --names)'{-l,--long}'[also show directory and last update]' \
            '(-N --names -j --json -l --long)'{-N,--names}'[print only names]' && ret=0
          ;;
        sync)
          _arguments $common \
            '(-p --prune)'{-p,--prune}'[drop entries whose transcript is gone]' \
            '(-n --dry-run)'{-n,--dry-run}'[show changes without saving them]' && ret=0
          ;;
        rename)
          _arguments $common \
            '1:current name:_claude-session_names' \
            '2:new name:' && ret=0
          ;;
        remove)
          _arguments $common '*:session name:_claude-session_names' && ret=0
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
    "list": cmd_list,
    "remove": cmd_remove,
    "rename": cmd_rename,
    "resume": cmd_resume,
    "sync": cmd_sync,
}


def main(argv: Sequence[str] | None = None) -> int:
    argv = list(sys.argv[1:] if argv is None else argv)
    parser = build_parser()

    # `version` and `help` as the first argument win over everything else
    if argv[:1] == ["version"]:
        print(f"{PROG_NAME} {__version__}")
        return 0
    if argv[:1] == ["help"]:
        parser.print_help()
        return 0

    try:
        reject_short_equals(argv)
    except AppError as exc:
        parser.error(str(exc))
    # Everything after `--` goes to claude, so unquoted multi-word names work
    claude_args: list[str] = []
    if argv[:1] == ["resume"] and "--" in argv:
        split = argv.index("--")
        argv, claude_args = argv[:split], argv[split + 1 :]
    args = parser.parse_args(argv)
    args.claude_args = claude_args

    try:
        return COMMANDS[args.command](args)
    except AppError as exc:
        print(f"Error: {exc}", file=sys.stderr)
        return 1
    except KeyboardInterrupt:
        print(file=sys.stderr)
        return 130
    except BrokenPipeError:
        # Output piped into a command that exited early (e.g. `| head`)
        devnull = os.open(os.devnull, os.O_WRONLY)
        os.dup2(devnull, sys.stdout.fileno())
        return 1


if __name__ == "__main__":
    sys.exit(main())

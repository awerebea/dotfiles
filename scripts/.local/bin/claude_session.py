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
"""

from __future__ import annotations

import argparse
import contextlib
import fcntl
import json
import os
import shlex
import shutil
import sys
import tempfile
from collections.abc import Iterator, Sequence
from datetime import datetime, timezone
from pathlib import Path

# Semantic version: MAJOR for breaking CLI or behavior changes, MINOR for new
# features, PATCH for fixes. Bump it with every change to this script.
__version__ = "0.2.0"

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
CONFIG_KEYS = {ENV_REGISTRY, ENV_CLAUDE_BIN}
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
        "-n",
        "--dry-run",
        action="store_true",
        help="print the command instead of running it",
    )
    resume.usage = f"{PROG} resume [OPTIONS] NAME... [-- CLAUDE_ARG...]"
    resume.add_argument(
        "name",
        nargs="+",
        metavar="NAME",
        help="session name or a unique prefix of it; words are joined with spaces",
    )
    resume.epilog = "Arguments after '--' are passed to claude (e.g. -- --model opus)."

    list_cmd = add_command("list", "List registered sessions")
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
        "rename", "Rename a registry entry (the transcript is not changed)"
    )
    rename.add_argument("old", metavar="OLD", help="current name")
    rename.add_argument("new", metavar="NEW", help="new name")

    remove = add_command(
        "remove", "Remove registry entries (transcripts are not changed)"
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


# Registry layout: {"version": 1, "sessions": {NAME: {"session_id", "cwd",
# "transcript", "updated"}}}


def load_registry(path: Path) -> dict[str, dict[str, str]]:
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except FileNotFoundError:
        return {}
    except (OSError, ValueError) as exc:
        raise AppError(f"Cannot read registry {path}: {exc}") from exc
    sessions = data.get("sessions") if isinstance(data, dict) else None
    if not isinstance(sessions, dict):
        raise AppError(f"Unexpected registry format in {path}")
    return sessions


def save_registry(path: Path, sessions: dict[str, dict[str, str]]) -> None:
    """Write atomically: a temporary file in the same directory, then rename."""
    path.parent.mkdir(parents=True, exist_ok=True)
    fd, tmp = tempfile.mkstemp(dir=path.parent, prefix=f".{path.name}.", suffix=".tmp")
    try:
        with os.fdopen(fd, "w", encoding="utf-8") as fh:
            json.dump(
                {
                    "version": REGISTRY_FORMAT,
                    "sessions": dict(sorted(sessions.items())),
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
    sessions: dict[str, dict[str, str]],
    session_id: str,
    title: str | None,
    cwd: str | None,
    transcript: Path,
) -> list[str]:
    """Register `title` for `session_id`; return messages about the changes."""
    messages = []
    # A session renamed again must not stay registered under its old name
    for name in [n for n, e in sessions.items() if e.get("session_id") == session_id]:
        if name != title:
            del sessions[name]
            messages.append(f"Unregistered old name: {name}")
    if title is None:
        return messages
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


def find_entry(
    sessions: dict[str, dict[str, str]], name: str
) -> tuple[str, dict[str, str]]:
    """Exact name first, then a unique prefix (case-insensitive)."""
    if name in sessions:
        return name, sessions[name]
    lowered = name.casefold()
    matches = [n for n in sessions if n.casefold().startswith(lowered)]
    if len(matches) == 1:
        return matches[0], sessions[matches[0]]
    if matches:
        raise AppError(f"Ambiguous name '{name}': {', '.join(sorted(matches))}")
    raise AppError(
        f"Session not found: {name} (see '{PROG} list' or run '{PROG} sync')"
    )


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
        sessions = load_registry(path)
        messages = apply_entry(sessions, session_id, title, cwd, transcript_path)
        if messages:
            save_registry(path, sessions)
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
        sessions = load_registry(path)
        messages = []
        # Oldest first, so the most recently active session wins a shared name
        for _, session_id, title, cwd, transcript in sorted(
            found, key=lambda item: item[0]
        ):
            messages += apply_entry(sessions, session_id, title, cwd, transcript)
        if args.prune:
            for name in [
                n
                for n, e in sessions.items()
                if not Path(e.get("transcript", "")).is_file()
            ]:
                del sessions[name]
                messages.append(f"Pruned: {name}")
        prefix = "[dry-run] " if args.dry_run else ""
        for message in messages:
            print(f"{prefix}{message}")
        if messages and not args.dry_run:
            save_registry(path, sessions)
    print(f"{prefix}{len(sessions)} session(s) registered, {len(messages)} change(s)")
    return 0


def cmd_list(args: argparse.Namespace) -> int:
    sessions = load_registry(registry_path(args, settings(args)))
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
    home = str(Path.home())
    for name, entry in sorted(sessions.items()):
        line = f"{name:<{width}}  {entry.get('session_id', '')}"
        if args.long:
            cwd = entry.get("cwd", "")
            if cwd == home or cwd.startswith(f"{home}/"):
                cwd = f"~{cwd[len(home) :]}"
            line += f"  {entry.get('updated', ''):<25}  {cwd}"
        print(line)
    return 0


def cmd_resume(args: argparse.Namespace) -> int:
    config = settings(args)
    sessions = load_registry(registry_path(args, config))
    name, entry = find_entry(sessions, " ".join(args.name))
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


def cmd_rename(args: argparse.Namespace) -> int:
    path = registry_path(args, settings(args))
    with locked(path):
        sessions = load_registry(path)
        if args.old not in sessions:
            raise AppError(f"Session not found: {args.old}")
        if args.new in sessions and args.new != args.old:
            raise AppError(f"Name already registered: {args.new}")
        sessions[args.new] = {**sessions.pop(args.old), "updated": now()}
        save_registry(path, sessions)
    print(f"Renamed: {args.old} -> {args.new}")
    print(
        "Note: a later /rename in that session will register its own name again",
        file=sys.stderr,
    )
    return 0


def cmd_remove(args: argparse.Namespace) -> int:
    path = registry_path(args, settings(args))
    with locked(path):
        sessions = load_registry(path)
        missing = [name for name in args.names if name not in sessions]
        if missing:
            raise AppError(f"Session not found: {', '.join(missing)}")
        for name in args.names:
            del sessions[name]
        save_registry(path, sessions)
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
        'list:list registered sessions'
        'hook:update the registry from a SessionEnd hook event'
        'sync:rebuild the registry from all transcripts'
        'rename:rename a registry entry'
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

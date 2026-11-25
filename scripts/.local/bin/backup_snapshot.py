#!/usr/bin/env python3
"""Differential snapshot backups with rsync and hard links.

Every snapshot is a full, browsable copy of the source, but unchanged files are
hard-linked to the previous snapshot, so a snapshot costs only the changed
files in space. Either side may live on a remote host reachable over ssh, so
the supported transfer modes are:

  local  -> local     rsync runs locally
  local  -> remote    rsync runs locally, destination is host:/path
  remote -> local     rsync runs locally, source is host:/path
  remote -> remote    both paths on the SAME host; rsync is executed there

rsync cannot talk to two different remote hosts at once, so remote -> remote
across two different hosts is rejected with a clear error.
"""

from __future__ import annotations

import argparse
import contextlib
import dataclasses
import logging
import os
import posixpath
import re
import shlex
import shutil
import signal
import socket
import subprocess
import sys
import tempfile
import time
from collections.abc import Callable, Sequence
from pathlib import Path
from typing import NoReturn

# Semantic version: MAJOR for breaking CLI or behavior changes, MINOR for new
# features, PATCH for fixes. Bump it with every change to this script.
__version__ = "2.0.0"

# Canonical program name for the version output (GNU: a constant, never
# derived from argv[0]); usage and error messages use the invoked name (PROG).
PROG_NAME = "backup-snapshot"
PROG = Path(sys.argv[0]).name
# Short options that take a value. Used to enforce GNU rules that argparse does
# not: `-s=x` is rejected instead of silently meaning `-s x`.
SHORT_VALUE_OPTS = "sdptkecL"

# Settings: environment variable names double as config file keys
ENV_PREFIX = "BACKUP_SNAPSHOT_"
SETTING_NAMES = (
    "SOURCE",
    "DEST",
    "PARENT_NAME",
    "TIMEOUT",
    "KEEP",
    "EXCLUDE_PRESET",
    "SSH_COMMAND",
    "SRC_SSH_COMMAND",
    "DST_SSH_COMMAND",
    "PORT",
    "SRC_PORT",
    "DST_PORT",
    "RSYNC_PATH",
    "LOG_LEVEL",
)
ENV_CONFIG = f"{ENV_PREFIX}CONFIG"
ENV_LOG_LEVEL = f"{ENV_PREFIX}LOG_LEVEL"
CONFIG_KEYS = {f"{ENV_PREFIX}{name}" for name in SETTING_NAMES}
DEFAULT_CONFIG = (
    Path(os.environ.get("XDG_CONFIG_HOME") or Path.home() / ".config")
    / PROG_NAME
    / f"{PROG_NAME}.conf"
)
# --log-level: what the log messages on stderr include; every level also
# includes the more severe ones
LOG_LEVELS = ("error", "warning", "info", "debug")
DEFAULT_LOG_LEVEL = "warning"

DEFAULT_TIMEOUT_MINUTES = 6 * 60
DEFAULT_SSH_COMMAND = "ssh"

# Names of generated files
LOG_FILENAME = "rsync-log"
SUCCESS_FILE = "completed_successfully"
LOCK_DIRNAME = ".backup_snapshot.lock"

# Snapshot directory name format: 2026-08-24_23-15-17
SNAPSHOT_NAME_FORMAT = "%Y-%m-%d_%H-%M-%S"
# Strict pattern, used locally to decide whether a directory is a snapshot
SNAPSHOT_NAME_RE = re.compile(
    r"20[0-9]{2}-(0[1-9]|1[0-2])-(0[1-9]|[1-2][0-9]|3[0-1])"
    r"_([0-1][0-9]|2[0-3])-([0-5][0-9])-([0-5][0-9])"
)
# Coarse glob, used on the destination host because POSIX sh has no ERE.
# Everything it returns is re-validated locally against the strict pattern.
SNAPSHOT_NAME_GLOB = "20[0-9][0-9]-[0-9][0-9]-[0-9][0-9]_[0-9][0-9]-[0-9][0-9]-[0-9][0-9]"

# ssh exits 255 when it could not establish the connection at all, which is a
# different problem from the command failing on the far side
SSH_CONNECT_FAILURE = 255
# Seconds allowed for the short helper commands run over ssh or sh
SHORT_TIMEOUT = 600
# Unix domain socket paths are limited to about 104 characters and ssh spends
# 60 of them on the %C hash plus a temporary suffix while the master starts
SOCKET_PATH_LIMIT = 104
SOCKET_SUFFIX_LENGTH = 60
SIGTERM_EXIT_CODE = 143
# rsync exit code for "some source files vanished during the transfer"
RSYNC_VANISHED = 24

# Exclude presets. A preset is NOT applied unless requested, so that backing up
# an unrelated directory can never silently skip its contents.
EXCLUDE_PRESETS: dict[str, tuple[str, ...]] = {
    "none": (),
    # A typical Linux home directory
    "home": (
        "*/.terraform.lock.hcl",
        "*/.terraform/",
        "*/.venv/",
        ".cache/",
        ".cargo/",
        ".config/Code/",
        ".config/Slack/",
        ".config/coc/",
        ".config/google-chrome/",
        ".config/joplin-desktop/",
        ".config/skypeforlinux/",
        ".config/pcloud/Cache/",
        ".joplin/",
        ".local/share/nvim/",
        ".local/apps/jellyfin/cache/",
        ".local/share/flatpak/",
        ".local/share/bob/",
        ".local/share/TelegramDesktop/tdata/user_data/",
        ".mozilla/",
        ".npm/",
        ".nvm/",
        ".rustup/",
        ".tfenv/",
        ".tgenv/",
        ".thunderbird/",
        ".vim/",
        ".vscode/",
        "Documents/",
        "Downloads/",
        "Timeshift_exclude/",
        "build/",
        "go/",
        "migration/",
        "pCloudDrive/",
        "vm/",
    ),
}

# POSIX sh run on the destination host: one round trip that prints name, mtime,
# marker presence, recorded epoch and recorded parent of every snapshot. The
# @NAME@ tokens are filled in by build_inventory_command().
INVENTORY_SCRIPT = r"""d=@DST@
[ -d "$d" ] || exit 0
for p in "$d"/@GLOB@; do
  [ -d "$p" ] || continue
  n=${p##*/}
  m=$(stat -c %Y "$p" 2>/dev/null) || m=$(stat -f %m "$p" 2>/dev/null) || m=0
  s="$p/@MARKER@"
  if [ -f "$s" ]; then
    k=1
    e=$(sed -n 's/^Epoch: //p' "$s" 2>/dev/null | head -n 1)
    r=$(sed -n 's/^Parent: //p' "$s" 2>/dev/null | head -n 1)
  else
    k=0
    e=
    r=
  fi
  printf '%s\t%s\t%s\t%s\t%s\n' "$n" "${m:-0}" "$k" "${e:-0}" "$r"
done
exit 0
"""

log = logging.getLogger(PROG_NAME)


class AppError(Exception):
    """An expected failure, reported as 'Error: <message>' with exit code 1."""


class UsageError(AppError):
    """Invalid use of the command line, reported with the usage and exit code 2."""


# --------------------------------------------------------------------------
# Command line
# --------------------------------------------------------------------------


def positive_int_ok(value: str, maximum: int | None = None) -> bool:
    """Whether value is a positive integer (without sign or leading zeros)."""
    return bool(re.fullmatch(r"[1-9][0-9]*", value)) and (maximum is None or int(value) <= maximum)


def cli_int(maximum: int | None = None) -> Callable[[str], str]:
    """An argparse `type=` that checks a positive integer and keeps it as text,
    so that it can be resolved together with the environment and config file."""

    def convert(value: str) -> str:
        if not positive_int_ok(value, maximum):
            limit = f" up to {maximum}" if maximum else ""
            raise argparse.ArgumentTypeError(
                f"invalid value '{value}': must be a positive integer{limit}"
            )
        return value

    return convert


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog=PROG,
        usage=f"{PROG} -s SOURCE -d DEST [OPTIONS]",
        description=(
            f"{PROG_NAME} {__version__}\n"
            "Create a differential backup snapshot using rsync with hard links.\n"
            "Unchanged files are hard-linked to the previous snapshot, so every\n"
            "snapshot is a full, browsable copy of the source while costing only\n"
            "the changed files in space.\n"
            "\n"
            "Either side may be remote. See PATHS below.\n"
            "\n"
            "By default a snapshot is created only if the last one is older than\n"
            f"the configured timeout ({DEFAULT_TIMEOUT_MINUTES // 60} hour(s))."
        ),
        epilog=EPILOG,
        formatter_class=argparse.RawDescriptionHelpFormatter,
        allow_abbrev=False,
    )
    add = parser.add_argument
    add(
        "-s",
        "--source",
        metavar="PATH",
        help=f"source directory to back up (env: {ENV_PREFIX}SOURCE)",
    )
    add(
        "-d",
        "--dest",
        metavar="PATH",
        help=f"directory holding the snapshots (env: {ENV_PREFIX}DEST)",
    )
    add(
        "-p",
        "--parent-name",
        metavar="NAME",
        help=(
            "name of the directory holding the copied data inside each snapshot "
            f"(env: {ENV_PREFIX}PARENT_NAME, default: basename of the source path)"
        ),
    )
    add(
        "-f", "--force", action="store_true", help="ignore the timeout and create a snapshot anyway"
    )
    add("-y", "--yes", action="store_true", help="auto-confirm all prompts (non-interactive mode)")
    add("-n", "--dry-run", action="store_true", help="show what rsync would do, change nothing")
    add(
        "-q",
        "--quiet",
        action="store_true",
        help="silence rsync's own output (statistics, progress); log messages follow --log-level",
    )
    add(
        "-t",
        "--timeout",
        metavar="MIN",
        type=cli_int(),
        help=(
            "minimum time in minutes between snapshots "
            f"(env: {ENV_PREFIX}TIMEOUT, default: {DEFAULT_TIMEOUT_MINUTES})"
        ),
    )
    add(
        "-k",
        "--keep",
        metavar="NUM",
        type=cli_int(),
        help=f"number of snapshots to retain (env: {ENV_PREFIX}KEEP, default: keep all)",
    )
    add(
        "-e",
        "--exclude",
        metavar="PATTERN",
        action="append",
        default=[],
        help="exclude files/directories matching PATTERN (repeatable; a pattern starting "
        "with '-' needs the attached form: -e-x or --exclude=-x)",
    )
    add(
        "--exclude-from",
        metavar="FILE",
        action="append",
        default=[],
        type=Path,
        help="read exclude patterns from FILE, '#' comments and blank lines ignored (repeatable)",
    )
    add(
        "--include-zfs-snapdir",
        action="store_true",
        help=(
            "descend into .zfs directories. They are skipped by default: on a dataset with "
            "snapdir=visible, .zfs/snapshot exposes every ZFS snapshot as a browsable tree, "
            "so copying it multiplies the backup by the number of snapshots"
        ),
    )
    add(
        "--exclude-preset",
        metavar="NAME",
        choices=sorted(EXCLUDE_PRESETS),
        help=(
            f"prepend a built-in exclude list ({', '.join(sorted(EXCLUDE_PRESETS))}). Later uses "
            "override earlier ones, so 'none' disables a preset set by a wrapper script "
            f"(env: {ENV_PREFIX}EXCLUDE_PRESET, default: none)"
        ),
    )
    add(
        "--ssh-command",
        metavar="CMD",
        help=(
            "ssh command and options used to reach a remote side, WITHOUT the target host "
            f"(env: {ENV_PREFIX}SSH_COMMAND, default: {DEFAULT_SSH_COMMAND})"
        ),
    )
    add("--src-ssh-command", metavar="CMD", help="override --ssh-command for the source side only")
    add(
        "--dst-ssh-command",
        metavar="CMD",
        help="override --ssh-command for the destination side only",
    )
    add(
        "--port",
        metavar="N",
        type=cli_int(65535),
        help=f"ssh port used for every remote side (env: {ENV_PREFIX}PORT)",
    )
    add(
        "--src-port",
        metavar="N",
        type=cli_int(65535),
        help="ssh port for the source side only",
    )
    add(
        "--dst-port",
        metavar="N",
        type=cli_int(65535),
        help=(
            "ssh port for the destination side only. A port written into --ssh-command wins "
            "over these, because ssh keeps the first -p it is given"
        ),
    )
    add(
        "--no-multiplex",
        action="store_true",
        help=(
            "do not add ssh connection multiplexing options. Multiplexing is on by default so "
            "that the several short ssh calls of one run share a single authenticated "
            "connection. Any ControlMaster or ControlPath given in --ssh-command takes "
            "precedence over the ones added here"
        ),
    )
    add(
        "--rsync-path",
        metavar="CMD",
        help=(
            "passed to rsync as --rsync-path when exactly one side is remote. When both sides "
            "are on the same remote host it is the rsync command run there, so "
            "--rsync-path='sudo rsync' works in both cases "
            f"(env: {ENV_PREFIX}RSYNC_PATH)"
        ),
    )
    add(
        "--rsync-arg",
        metavar="ARG",
        action="append",
        default=[],
        help="extra argument passed through to rsync (repeatable; use the attached form: "
        "--rsync-arg=--bwlimit=1000)",
    )
    add(
        "-c",
        "--config",
        metavar="FILE",
        type=Path,
        help=f"config file (env: {ENV_CONFIG}, default: {DEFAULT_CONFIG})",
    )
    add(
        "-L",
        "--log-level",
        choices=LOG_LEVELS,
        metavar="LEVEL",
        help=(
            f"what to log on stderr: {', '.join(LOG_LEVELS)} "
            f"(env: {ENV_LOG_LEVEL}, default: {DEFAULT_LOG_LEVEL})"
        ),
    )
    add(
        "-v",
        "--verbose",
        action="store_true",
        help="same as --log-level info (unless a more detailed level is set)",
    )
    add(
        "--version",
        action="version",
        version=f"{PROG_NAME} {__version__}",
        help="show the version and exit",
    )
    return parser


EPILOG = f"""\
PATHS:
    Local:   /mnt/tank/photo
             ./relative/path   a leading ./ forces local, which is how to
                               name a local directory containing a colon

    Remote:  [user@]host:/absolute/path
             [user@]host:relative/path   relative to the ssh login directory
             [user@]host:~/path          relative to the remote home

    This is rsync's own single-colon syntax. The ssh port is never part of
    the spec, which is what keeps host:relative unambiguous: give it with
    --port, inside --ssh-command, or in ~/.ssh/config. The host may be any
    name your ssh client understands, including a ~/.ssh/config alias.

    Remote relative and ~ paths are resolved to an absolute path during
    preflight, before anything is created or deleted, so no later operation
    depends on the ssh login directory. ~user paths are rejected.

    Both sides may be remote only if they are on the same host; in that case
    rsync is executed on that host and no data crosses this machine.

EXAMPLES:
    # Local to local
    {PROG} -s /home/user -d /media/user/bckp/home_backup

    # Local to NAS
    {PROG} -s /home/user -d truenas:/mnt/tank/backups/laptop

    # NAS to NAS, rsync runs on the NAS, nothing crosses this machine
    {PROG} -s truenas:/mnt/tank/photo -d truenas:/mnt/tank/backups/photo -k 12

    # Pull from a NAS to a local disk, custom key and port
    {PROG} -s andrei@192.168.50.185:/mnt/tank/photo -d /media/user/bckp/photo \\
        --port=2222 --ssh-command='ssh -i ~/.ssh/homenet'

    # Consistent source: read from a ZFS snapshot instead of the live dataset
    {PROG} -s truenas:/mnt/tank/photo/.zfs/snapshot/auto-2026-08-24/ \\
        -d truenas:/mnt/tank/backups/photo -p photo

RESULTING LAYOUT:
    DEST/2026-08-24_23-15-17/PARENT/...        copied data
    DEST/2026-08-24_23-15-17/{LOG_FILENAME}              rsync log for this snapshot
    DEST/2026-08-24_23-15-17/{SUCCESS_FILE}   completion marker and metadata

NOTES:
    - Snapshots use hard links for space efficiency
    - Interrupted snapshots are removed on the next run
    - A snapshot without its {SUCCESS_FILE} marker is considered incomplete
    - A lock directory in DEST prevents two runs from overlapping
    - If the parent name changes between runs, hard linking still works: the
      previous parent name is read back from the marker file
    - .zfs directories are skipped unless --include-zfs-snapdir is given
    - rsync splits --ssh-command on whitespace, so paths inside it cannot
      contain spaces; a leading ~ in an ssh command word is expanded
    - Only the options with an env entry above can be set in the environment
      or the config file (KEY=VALUE lines named like the env variables)

EXIT CODES:
    0 success (also when the last snapshot is too recent), 1 failure,
    2 usage error, 130 interrupted by Ctrl-C, 143 terminated

Precedence: command line > environment > config file > default."""


def reject_short_equals(argv: Sequence[str]) -> None:
    """Reject `-s=value`: under GNU rules only long options take `=`."""
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
                    raise UsageError(
                        f"'-{char}=...' is not supported; use '-{char} VALUE', "
                        f"'-{char}VALUE' or the long form with '='"
                    )
                take_value = not rest
                break


# --------------------------------------------------------------------------
# Settings: command line > environment > config file > default
# --------------------------------------------------------------------------


def load_config(path: Path, explicit: bool) -> dict[str, str]:
    """Read KEY=VALUE lines as data (never executed)."""
    if not path.is_file():
        if explicit:
            raise AppError(f"Config file not found: {path}")
        return {}
    config: dict[str, str] = {}
    for number, raw in enumerate(path.read_text(encoding="utf-8").splitlines(), start=1):
        line = raw.strip()
        if not line or line.startswith("#"):
            continue
        line = line.removeprefix("export ")
        key, sep, value = line.partition("=")
        if not sep:
            print(f"Warning: {path}:{number}: ignoring invalid line", file=sys.stderr)
            continue
        if key not in CONFIG_KEYS:
            print(f"Warning: {path}:{number}: ignoring unknown key '{key}'", file=sys.stderr)
            continue
        if len(value) > 1 and value[0] in "\"'" and value.endswith(value[0]):
            value = value[1:-1]
        if value.startswith("~/"):
            value = str(Path.home() / value[2:])
        config[key] = value
    return config


def resolve(cli: str | None, env_name: str, config: dict[str, str], default: str = "") -> str:
    """Precedence: command line > environment > config file > default."""
    for value in (cli, os.environ.get(env_name), config.get(env_name)):
        if value:
            return value
    return default


def parse_int(value: str, env_name: str, maximum: int | None = None) -> int:
    """A positive integer from the environment or the config file."""
    if not positive_int_ok(value, maximum):
        limit = f" up to {maximum}" if maximum else ""
        raise AppError(f"Invalid {env_name} value: '{value}' (must be a positive integer{limit})")
    return int(value)


@dataclasses.dataclass(frozen=True)
class Settings:
    """Everything the run needs, resolved once."""

    source: str
    dest: str
    parent_name: str
    force: bool
    yes: bool
    dry_run: bool
    quiet: bool
    timeout_seconds: int
    keep: int | None
    excludes: tuple[str, ...]
    exclude_from: tuple[Path, ...]
    exclude_preset: str
    exclude_zfs_snapdir: bool
    ssh_command: str
    src_ssh_command: str
    dst_ssh_command: str
    multiplex: bool
    port: str
    src_port: str
    dst_port: str
    rsync_path: str
    rsync_args: tuple[str, ...]


def resolve_settings(args: argparse.Namespace, config: dict[str, str]) -> Settings:
    def pick(cli: str | None, name: str, default: str = "") -> str:
        return resolve(cli, f"{ENV_PREFIX}{name}", config, default)

    def pick_int(cli: str | None, name: str, maximum: int | None = None) -> str:
        value = pick(cli, name)
        if value:
            parse_int(value, f"{ENV_PREFIX}{name}", maximum)
        return value

    source = pick(args.source, "SOURCE")
    dest = pick(args.dest, "DEST")
    if not source:
        raise UsageError(f"Missing required option: -s/--source (env: {ENV_PREFIX}SOURCE)")
    if not dest:
        raise UsageError(f"Missing required option: -d/--dest (env: {ENV_PREFIX}DEST)")

    timeout = pick_int(args.timeout, "TIMEOUT") or str(DEFAULT_TIMEOUT_MINUTES)
    keep = pick_int(args.keep, "KEEP")
    preset = pick(args.exclude_preset, "EXCLUDE_PRESET", "none")
    if preset not in EXCLUDE_PRESETS:
        raise AppError(
            f"Unknown exclude preset: {preset} (supported: {', '.join(sorted(EXCLUDE_PRESETS))})"
        )
    for exclude_file in args.exclude_from:
        if not exclude_file.is_file():
            raise UsageError(f"Exclude file does not exist: {exclude_file}")
        if not os.access(exclude_file, os.R_OK):
            raise UsageError(f"Exclude file is not readable: {exclude_file}")

    return Settings(
        source=source,
        dest=dest,
        parent_name=pick(args.parent_name, "PARENT_NAME"),
        force=args.force,
        yes=args.yes,
        dry_run=args.dry_run,
        quiet=args.quiet,
        timeout_seconds=int(timeout) * 60,
        keep=int(keep) if keep else None,
        excludes=tuple(args.exclude),
        exclude_from=tuple(args.exclude_from),
        exclude_preset=preset,
        exclude_zfs_snapdir=not args.include_zfs_snapdir,
        ssh_command=pick(args.ssh_command, "SSH_COMMAND", DEFAULT_SSH_COMMAND),
        src_ssh_command=pick(args.src_ssh_command, "SRC_SSH_COMMAND"),
        dst_ssh_command=pick(args.dst_ssh_command, "DST_SSH_COMMAND"),
        multiplex=not args.no_multiplex,
        port=pick_int(args.port, "PORT", 65535),
        src_port=pick_int(args.src_port, "SRC_PORT", 65535),
        dst_port=pick_int(args.dst_port, "DST_PORT", 65535),
        rsync_path=pick(args.rsync_path, "RSYNC_PATH"),
        rsync_args=tuple(args.rsync_arg),
    )


def configure_logging(level: str) -> None:
    """Send log messages of the given level (see LOG_LEVELS) and above to stderr."""
    handler = logging.StreamHandler(sys.stderr)
    handler.setFormatter(logging.Formatter("%(message)s"))
    logging.basicConfig(handlers=[handler], force=True)
    log.setLevel(level.upper())


# --------------------------------------------------------------------------
# Path specs and ssh transport
# --------------------------------------------------------------------------


def shquote(text: str) -> str:
    """Quote a string for safe interpolation into a POSIX sh command line."""
    return shlex.quote(text)


def path_expr(path: str) -> str:
    """A shell word for a path. A leading ~/ has to survive as an unquoted
    expansion, so it becomes "$HOME"/rest; everything else is quoted."""
    if path == "~":
        return '"$HOME"'
    if path.startswith("~/"):
        return f'"$HOME"/{shquote(path[2:])}'
    return shquote(path)


def strip_trailing_slashes(path: str) -> str:
    """Drop trailing slashes, keeping a bare "/" intact."""
    stripped = path.rstrip("/")
    if stripped or not path:
        return stripped
    return "/"


@dataclasses.dataclass(frozen=True)
class ParsedSpec:
    remote: bool
    host: str
    path: str


# rsync's single-colon syntax: [user@]host:path
REMOTE_SPEC_RE = re.compile(r"^(?:([A-Za-z0-9._+-]+)@)?([A-Za-z0-9._-]+):(.*)$", re.DOTALL)


def parse_path_spec(spec: str, label: str) -> ParsedSpec:
    """Parse [user@]host:path (absolute, login-relative or ~/relative) or a
    local path. The ssh port is never part of the spec, which is exactly what
    keeps host:relative unambiguous; use --port for it."""
    remote = False
    host = ""
    path = spec

    def reject_user_tilde(value: str) -> None:
        if value.startswith("~") and value != "~" and not value.startswith("~/"):
            raise AppError(f"{label}: ~user paths are not supported, use an absolute path: {value}")

    if spec.startswith("["):
        # Checked before the daemon syntax, which [::1]:/path would match
        raise AppError(
            f"{label}: IPv6 literals are not supported, use a ~/.ssh/config host alias: {spec}"
        )
    if spec.startswith("rsync://") or "::" in spec:
        raise AppError(f"{label}: rsync daemon syntax is not supported: {spec}")
    if spec.startswith(("/", "./", "../")):
        pass  # a leading ./ is the escape hatch for a local path holding a colon
    elif spec == "~" or spec.startswith("~/"):
        path = str(Path.home()) + spec[1:]
    elif spec.startswith("~"):
        reject_user_tilde(spec)
    else:
        match = REMOTE_SPEC_RE.match(spec)
        if match:
            remote = True
            user, name, path = match.groups()
            host = f"{user}@{name}" if user else name
            reject_user_tilde(path)

    path = strip_trailing_slashes(path)
    if not path:
        raise AppError(f"{label}: empty path in '{spec}'")
    return ParsedSpec(remote, host, path)


@dataclasses.dataclass(frozen=True)
class Result:
    """Outcome of a command run on one side; stdout is empty when not captured."""

    code: int
    out: str


@dataclasses.dataclass
class Side:
    """One end of the transfer: a local directory or a directory on an ssh host."""

    label: str
    spec: str
    remote: bool
    host: str
    path: str
    given_path: str
    port: str = ""
    ssh: list[str] = dataclasses.field(default_factory=list)  # ssh command and options
    rsh: str = ""  # the same, as the string handed to rsync -e

    @classmethod
    def local_machine(cls) -> Side:
        return cls("local", "", False, "", "", "")

    def where(self) -> str:
        """host:path for a remote side, plain path for a local one."""
        return f"{self.host}:{self.path}" if self.remote else self.path

    def describe(self) -> str:
        if not self.remote:
            return f"local   {self.path}"
        port = f" (port {self.port})" if self.port else ""
        return f"remote  {self.host}:{self.path}{port}"

    def argv_for(self, command: str) -> list[str]:
        """The argv running a POSIX sh command string on this side. ssh hands
        the command to the remote login shell, which is not necessarily POSIX
        (zsh aborts on a glob that matches nothing), so every snippet is
        wrapped in sh -c to behave the same everywhere."""
        if self.remote:
            return [*self.ssh, self.host, f"sh -c {shquote(command)}"]
        return ["sh", "-c", command]


def run_on(
    side: Side,
    command: str,
    *,
    data: bytes | None = None,
    capture: bool = True,
    timeout: float | None = SHORT_TIMEOUT,
) -> Result:
    """Run a POSIX sh command string on a side. stdin is closed unless data is
    given, so that ssh cannot swallow the caller's input."""
    argv = side.argv_for(command)
    log.debug("[%s] %s", side.label, command)
    try:
        proc = subprocess.run(
            argv,
            input=data,
            stdin=subprocess.DEVNULL if data is None else None,
            stdout=subprocess.PIPE if capture else None,
            timeout=timeout,
            check=False,
        )
    except FileNotFoundError as exc:
        raise AppError(f"Cannot run {argv[0]}: {exc.strerror}") from exc
    except subprocess.TimeoutExpired as exc:
        raise AppError(f"Timed out after {SHORT_TIMEOUT} seconds on {side.label} side") from exc
    out = proc.stdout.decode("utf-8", errors="replace") if proc.stdout else ""
    log.debug("[%s] exit code %d", side.label, proc.returncode)
    return Result(proc.returncode, out)


def fail_if_ssh_error(result: Result, side: Side) -> None:
    if side.remote and result.code == SSH_CONNECT_FAILURE:
        raise AppError(f"Cannot connect to {side.host} over ssh; see the ssh error above")


def build_ssh(label: str, command: str, port: str, control_path: str) -> tuple[list[str], str]:
    """Build the ssh command (without the host) and the string for rsync -e."""
    try:
        parts = shlex.split(command)
    except ValueError as exc:
        raise AppError(f"{label}: cannot parse ssh command: {command}") from exc
    if not parts:
        raise AppError(f"{label}: empty ssh command")
    if shutil.which(parts[0]) is None:
        raise AppError(f"{label}: ssh command not found: {parts[0]}")
    parts = [os.path.expanduser(part) if part.startswith("~") else part for part in parts]

    # Appended, not prepended: ssh keeps the first -p it is given, so a port
    # written into --ssh-command deliberately wins over --port.
    if port:
        parts += ["-p", port]

    # rsync's -e option splits on whitespace and knows nothing about quoting
    rsh = " ".join(parts)
    for part in parts:
        if any(char.isspace() for char in part):
            log.warning(
                "%s: ssh argument '%s' contains whitespace; rsync cannot pass it through -e",
                label,
                part,
            )

    argv = list(parts)
    if control_path:
        # Appended last on purpose: ssh honours the first value it is given for
        # an option, so anything the user put in --ssh-command wins.
        argv += ["-o", "ControlMaster=auto", "-o", f"ControlPath={control_path}"]
        argv += ["-o", "ControlPersist=60"]
    return argv, rsh


def setup_ssh_control_dir() -> Path | None:
    """A directory for the ssh control sockets, or None when multiplexing is
    not possible. The usual macOS TMPDIR under /var/folders is already too
    long to hold a socket, hence the fixed short path."""
    directory = Path(f"/tmp/.bsnap-{os.getuid()}")
    try:
        directory.mkdir(mode=0o700, exist_ok=True)
        directory.chmod(0o700)
    except OSError:
        log.warning("Cannot create the ssh control directory: %s", directory)
        log.warning("Continuing without ssh connection multiplexing")
        return None
    if len(str(directory)) + SOCKET_SUFFIX_LENGTH > SOCKET_PATH_LIMIT:
        log.warning("Path too long for an ssh control socket: %s", directory)
        log.warning("Continuing without ssh connection multiplexing")
        return None
    return directory


# --------------------------------------------------------------------------
# Snapshots
# --------------------------------------------------------------------------


@dataclasses.dataclass(frozen=True)
class Snapshot:
    name: str
    mtime: int
    complete: bool
    epoch: int
    parent: str


def is_snapshot_name(name: str) -> bool:
    return SNAPSHOT_NAME_RE.fullmatch(name) is not None


def parse_inventory(text: str) -> list[Snapshot]:
    """Parse the tab separated inventory, newest first."""
    snapshots = []
    for line in text.splitlines():
        fields = (line.split("\t") + [""] * 5)[:5]
        name, mtime, complete, epoch, parent = fields
        # Re-validate against the strict pattern; the remote glob is coarse
        if not is_snapshot_name(name):
            continue
        snapshots.append(
            Snapshot(
                name=name,
                mtime=int(mtime) if mtime.isdigit() else 0,
                complete=complete == "1",
                epoch=int(epoch) if epoch.isdigit() else 0,
                parent=parent,
            )
        )
    return sorted(snapshots, key=lambda snap: snap.name, reverse=True)


def confirm(prompt: str) -> bool:
    try:
        answer = input(f"{prompt} (y|N): ")
    except EOFError:
        return False
    return answer.strip()[:1].lower() == "y"


class Backup:
    """One backup run: preflight, lock, inventory, snapshot, retention."""

    def __init__(self, settings: Settings) -> None:
        self.cfg = settings
        self.local = Side.local_machine()
        self.src = self.local
        self.dst = self.local
        self.rsync_on_dst = False  # rsync runs on the destination host
        self.rsync_rsh = ""
        self.mode = ""
        self.rsync_version = "unknown"
        self.parent_name = settings.parent_name
        self.snapshots: list[Snapshot] = []
        self.tmp = Path()
        self.control_dir: Path | None = None
        # Cleanup bookkeeping
        self.incomplete = ""  # snapshot to remove if the run does not finish
        self.lock_acquired = False
        self.remote_tmp_files: list[str] = []

    # -- setup ------------------------------------------------------------

    def setup_sides(self) -> None:
        cfg = self.cfg
        src_spec = parse_path_spec(cfg.source, "Source")
        dst_spec = parse_path_spec(cfg.dest, "Destination")
        src_port = cfg.src_port or cfg.port
        dst_port = cfg.dst_port or cfg.port
        self.src = Side(
            "source", cfg.source, src_spec.remote, src_spec.host, src_spec.path, src_spec.path,
            src_port,
        )  # fmt: skip
        self.dst = Side(
            "destination", cfg.dest, dst_spec.remote, dst_spec.host, dst_spec.path, dst_spec.path,
            dst_port,
        )  # fmt: skip

        if (src_port or dst_port) and not (self.src.remote or self.dst.remote):
            log.warning("A port was given but neither side is remote; it will be ignored")

        control_path = ""
        if cfg.multiplex and (self.src.remote or self.dst.remote):
            self.control_dir = setup_ssh_control_dir()
            if self.control_dir:
                control_path = f"{self.control_dir}/%C"

        if self.src.remote:
            command = cfg.src_ssh_command or cfg.ssh_command
            self.src.ssh, self.src.rsh = build_ssh("Source", command, src_port, control_path)
        if self.dst.remote:
            command = cfg.dst_ssh_command or cfg.ssh_command
            self.dst.ssh, self.dst.rsh = build_ssh("Destination", command, dst_port, control_path)

        if self.src.remote and self.dst.remote:
            if (self.src.host, src_port) != (self.dst.host, dst_port):
                raise AppError(
                    "rsync cannot transfer between two different remote hosts "
                    f"({self.src.host} -> {self.dst.host}).\n"
                    "       Run this script on one of them, or make one side local."
                )
            self.rsync_on_dst = True
            self.mode = f"remote -> remote (same host; rsync executes on {self.dst.host})"
        elif self.src.remote:
            self.rsync_rsh = self.src.rsh
            self.mode = "remote -> local (rsync executes here)"
        elif self.dst.remote:
            self.rsync_rsh = self.dst.rsh
            self.mode = "local -> remote (rsync executes here)"
        else:
            self.mode = "local -> local"

    def show_configuration(self) -> None:
        log.info("Source:      %s", self.src.describe())
        log.info("Destination: %s", self.dst.describe())
        log.info("Mode:        %s", self.mode)
        if self.rsync_rsh:
            log.info("Transport:   %s", self.rsync_rsh)
        if self.cfg.dry_run:
            log.warning("Dry run: no changes will be made")

    # -- preflight --------------------------------------------------------

    def check_rsync_available(self) -> None:
        # When rsync runs on the destination host, --rsync-path names the
        # command to run there, so a plain "rsync" may legitimately be absent.
        if self.rsync_on_dst and self.cfg.rsync_path:
            return
        side = self.dst if self.rsync_on_dst else self.local
        result = run_on(
            side,
            "command -v rsync >/dev/null 2>&1 || exit 41; rsync --version 2>/dev/null | head -n 1",
        )
        if result.code != 0:
            fail_if_ssh_error(result, side)
            where = f"on {self.dst.host}" if self.rsync_on_dst else "on this machine"
            raise AppError(f"rsync is not available {where}")
        self.rsync_version = result.out.strip()
        log.info("Rsync:       %s", self.rsync_version)

    def validate_source(self) -> None:
        """Check the source and resolve it to an absolute path in one round trip."""
        command = "\n".join(
            [
                f"p={path_expr(self.src.path)}",
                '[ -e "$p" ] || exit 21',
                '[ -d "$p" ] || exit 22',
                '[ -r "$p" ] || exit 23',
                'cd -- "$p" 2>/dev/null || exit 24',
                "pwd",
            ]
        )
        result = run_on(self.src, command)
        fail_if_ssh_error(result, self.src)
        problems = {
            21: "Source directory does not exist",
            22: "Source path is not a directory",
            23: "Source directory is not readable",
            24: "Source directory cannot be entered",
        }
        if result.code in problems:
            raise AppError(f"{problems[result.code]}: {self.cfg.source}")
        if result.code != 0:
            raise AppError(
                f"Failed to inspect the source: {self.cfg.source} (exit code {result.code})"
            )
        # Everything after this point works with the absolute path, so no later
        # operation depends on the login directory of the ssh session.
        resolved = result.out.strip()
        if not resolved.startswith("/"):
            raise AppError(f"Source did not resolve to an absolute path: {self.cfg.source}")
        self.src.path = strip_trailing_slashes(resolved)

    def validate_destination(self) -> None:
        """Create the destination if needed, check it and resolve it to an
        absolute path, before the lock and before anything can be deleted."""
        command = "\n".join(
            [
                f"d={path_expr(self.dst.path)}",
                'if [ ! -d "$d" ]; then',
                '  mkdir -p "$d" || exit 31',
                "fi",
                '[ -w "$d" ] || exit 32',
                'cd -- "$d" 2>/dev/null || exit 33',
                "pwd",
            ]
        )
        result = run_on(self.dst, command)
        fail_if_ssh_error(result, self.dst)
        problems = {
            31: "Failed to create the destination directory",
            32: "Destination directory is not writable",
            33: "Destination directory cannot be entered",
        }
        if result.code in problems:
            raise AppError(f"{problems[result.code]}: {self.cfg.dest}")
        if result.code != 0:
            raise AppError(
                f"Failed to inspect the destination: {self.cfg.dest} (exit code {result.code})"
            )
        resolved = result.out.strip()
        if not resolved.startswith("/"):
            raise AppError(f"Destination did not resolve to an absolute path: {self.cfg.dest}")
        self.dst.path = strip_trailing_slashes(resolved)

    def finalize_paths(self) -> None:
        if self.src.path != self.src.given_path:
            log.info("Source path resolved to: %s", self.src.path)
        if self.dst.path != self.dst.given_path:
            log.info("Destination path resolved to: %s", self.dst.path)

        # Default parent directory name is the basename of the resolved source
        if not self.parent_name:
            self.parent_name = posixpath.basename(self.src.path)
            if not self.parent_name:
                raise AppError(
                    f"Cannot derive a parent directory name from '{self.src.path}', "
                    "use -p/--parent-name"
                )
        name = self.parent_name
        if "/" in name or "\\" in name or name in {".", ".."}:
            raise AppError(f"Invalid parent directory name: {name}")
        # A tab would corrupt the tab separated snapshot inventory
        if "\t" in name:
            raise AppError(f"Parent directory name cannot contain tabs: {name}")
        log.info("Parent name: %s", name)

    # -- locking ----------------------------------------------------------

    @property
    def lock_dir(self) -> str:
        return f"{self.dst.path}/{LOCK_DIRNAME}"

    def acquire_lock(self) -> None:
        if self.cfg.dry_run:
            return
        info_file = f"{self.lock_dir}/info"
        lines = [
            f"host={socket.gethostname()}",
            f"pid={os.getpid()}",
            f"started={time.strftime('%Y-%m-%d %H:%M:%S')}",
        ]
        words = " ".join(shquote(line) for line in lines)
        command = "\n".join(
            [
                f"mkdir {shquote(self.lock_dir)} 2>/dev/null || exit 51",
                f"printf '%s\\n' {words} > {shquote(info_file)} 2>/dev/null || true",
                "exit 0",
            ]
        )
        result = run_on(self.dst, command)
        fail_if_ssh_error(result, self.dst)
        if result.code != 0:
            info = run_on(self.dst, f"cat {shquote(info_file)} 2>/dev/null").out
            log.error("Another backup is already running for this destination.")
            if info.strip():
                log.error("%s", info.strip())
            raise AppError(f"If this is stale, remove the lock: {self.cfg.dest}/{LOCK_DIRNAME}")
        self.lock_acquired = True

    def release_lock(self) -> None:
        if not self.lock_acquired:
            return
        command = f"rm -f {shquote(self.lock_dir + '/info')}; rmdir {shquote(self.lock_dir)}"
        run_on(self.dst, f"{command} 2>/dev/null")
        self.lock_acquired = False

    # -- inventory --------------------------------------------------------

    def load_inventory(self) -> None:
        command = (
            INVENTORY_SCRIPT.replace("@DST@", shquote(self.dst.path))
            .replace("@GLOB@", SNAPSHOT_NAME_GLOB)
            .replace("@MARKER@", SUCCESS_FILE)
        )
        result = run_on(self.dst, command)
        if result.code != 0:
            raise AppError(f"Failed to list snapshots in: {self.cfg.dest}")
        self.snapshots = parse_inventory(result.out)
        log.info("Found %d existing snapshots in %s", len(self.snapshots), self.cfg.dest)

    # -- deletion ---------------------------------------------------------

    def delete_snapshots(self, names: Sequence[str], *, real: bool = False) -> bool:
        """Delete named snapshots on the destination host. Every name is
        validated first: this builds "rm -rf" command lines. `real` deletes
        even in a dry run, for the temporary snapshot a dry run itself made."""
        if not names:
            return True
        if not self.dst.path:
            raise AppError("Internal error: empty destination path, refusing to delete")

        script = []
        for name in names:
            if not is_snapshot_name(name):
                raise AppError(f"Internal error: refusing to delete non-snapshot: {name}")
            quoted = shquote(f"{self.dst.path}/{name}")
            log.info("Deleting snapshot: %s", name)
            if self.cfg.dry_run and not real:
                continue
            # Hard-linked trees can contain read-only directories; only pay for
            # the recursive chmod if the plain removal actually fails.
            script.append(
                f"if [ -d {quoted} ]; then\n"
                f"  rm -rf {quoted} 2>/dev/null || {{\n"
                f"    chmod -R u+w {quoted} 2>/dev/null\n"
                f"    rm -rf {quoted} || exit 61\n"
                "  }\n"
                "fi"
            )
        if not script:
            return True
        result = run_on(self.dst, "\n".join([*script, "exit 0"]), timeout=None)
        if result.code != 0:
            log.error("Failed to delete one or more snapshots")
            return False
        return True

    def remove_interrupted_snapshots(self) -> None:
        names = [snap.name for snap in self.snapshots if not snap.complete]
        if names:
            log.warning("Removing %d interrupted snapshot(s)", len(names))
            self.delete_snapshots(names)
        self.snapshots = [snap for snap in self.snapshots if snap.complete]

    def remove_old_snapshots(self) -> None:
        keep = self.cfg.keep
        if keep is None:
            return
        to_delete = [snap.name for snap in self.snapshots[keep:]]
        if not to_delete:
            return
        log.warning("The following snapshots will be deleted:")
        for name in to_delete:
            log.warning("  %s", name)
        if not (self.cfg.yes or self.cfg.dry_run or confirm("Proceed with deletion?")):
            log.info("Snapshot deletion canceled.")
            return
        if self.delete_snapshots(to_delete) and not self.cfg.dry_run:
            log.info("Old snapshots deleted successfully.")

    # -- snapshot creation ------------------------------------------------

    def rsync_arg_for(self, side: Side, path: str) -> str:
        """The rsync source or destination argument for a side."""
        if side.remote and not self.rsync_on_dst:
            return f"{side.host}:{path}/"
        return f"{path}/"

    def build_exclude_patterns(self) -> list[str]:
        cfg = self.cfg
        patterns: list[str] = []
        if cfg.exclude_preset != "none":
            log.info("Using exclude preset: %s", cfg.exclude_preset)
            patterns += EXCLUDE_PRESETS[cfg.exclude_preset]
        if cfg.excludes:
            log.info("Adding %d exclude patterns from the command line", len(cfg.excludes))
            patterns += cfg.excludes
        if cfg.exclude_from:
            log.info("Adding patterns from %d exclude files", len(cfg.exclude_from))
        for exclude_file in cfg.exclude_from:
            log.info("  Including patterns from: %s", exclude_file)
            lines = exclude_file.read_text(encoding="utf-8").splitlines()
            valid = [line for line in lines if line.strip() and not line.startswith("#")]
            if not valid:
                log.warning("No valid patterns found in: %s", exclude_file)
            patterns += valid
        if not patterns:
            log.info("Exclude configuration: no patterns configured")
        else:
            log.info("Total exclude patterns: %d", len(patterns))
        return patterns

    def prepare_exclude_file(self) -> str:
        """Put the exclude patterns where rsync will read them; the path is
        empty when there is nothing to exclude."""
        patterns = self.build_exclude_patterns()
        if not patterns:
            return ""
        content = "".join(f"{pattern}\n" for pattern in patterns)
        local_file = self.tmp / "excludes"
        local_file.write_text(content, encoding="utf-8")
        if not self.rsync_on_dst:
            return str(local_file)
        result = run_on(self.dst, 'mktemp "${TMPDIR:-/tmp}/bsnap.XXXXXX"')
        remote_file = result.out.strip()
        if result.code != 0 or not remote_file:
            raise AppError(f"Failed to create a temporary file on {self.dst.host}")
        self.remote_tmp_files.append(remote_file)
        written = run_on(self.dst, f"cat > {shquote(remote_file)}", data=content.encode("utf-8"))
        if written.code != 0:
            raise AppError(f"Failed to copy the exclude file to {self.dst.host}")
        return remote_file

    def new_snapshot_name(self) -> str:
        """Snapshot names have one second of resolution, so two runs started
        within the same second would otherwise rsync into the same directory
        and hard-link it against itself."""
        existing = {snap.name for snap in self.snapshots}
        name = time.strftime(SNAPSHOT_NAME_FORMAT)
        for _ in range(3):
            if name not in existing:
                return name
            log.info("Snapshot %s already exists, waiting for the next second", name)
            time.sleep(1)
            name = time.strftime(SNAPSHOT_NAME_FORMAT)
        if name in existing:
            raise AppError(f"A snapshot named {name} already exists")
        return name

    def link_dest(self) -> str:
        """The newest complete snapshot, with the parent name it used."""
        if not self.snapshots:
            return ""
        previous = self.snapshots[0]
        # Markers written before Parent was recorded fall back to the current name
        previous_parent = previous.parent or self.parent_name
        if previous_parent != self.parent_name:
            log.info("Previous snapshot used parent name '%s'; linking against it", previous_parent)
        log.info("Hard-linking unchanged files against: %s/%s", previous.name, previous_parent)
        return f"{self.dst.path}/{previous.name}/{previous_parent}"

    def build_rsync_args(
        self, log_target: str, exclude_file: str, link_dest: str, target_dir: str
    ) -> list[str]:
        cfg = self.cfg
        args = [
            "--archive",
            "--delete",
            "--force",
            "--sparse",
            "--numeric-ids",
            "--human-readable",
            f"--log-file={log_target}",
        ]
        if cfg.quiet:
            args.append("--quiet")
        else:
            args.append("--stats")
            if sys.stdout.isatty():
                args.append("--info=progress2")
        if cfg.dry_run:
            args.append("--dry-run")
        # Listed first so that it cannot be overridden by a later rule: .zfs is
        # a synthetic directory whose contents are, by construction, copies of
        # the live tree at earlier points in time.
        if cfg.exclude_zfs_snapdir:
            log.info("Skipping ZFS snapshot directories (.zfs/), use --include-zfs-snapdir")
            args.append("--exclude=.zfs/")
        if exclude_file:
            args.append(f"--exclude-from={exclude_file}")
        if link_dest:
            args.append(f"--link-dest={link_dest}")
        if not self.rsync_on_dst:
            if self.rsync_rsh:
                args += ["-e", self.rsync_rsh]
            if cfg.rsync_path:
                args.append(f"--rsync-path={cfg.rsync_path}")
        args += cfg.rsync_args
        args += [self.rsync_arg_for(self.src, self.src.path)]
        args += [self.rsync_arg_for(self.dst, target_dir)]
        return args

    def create_snapshot(self) -> None:
        cfg = self.cfg
        name = self.new_snapshot_name()
        started = int(time.time())
        snapshot_dir = f"{self.dst.path}/{name}"
        target_dir = f"{snapshot_dir}/{self.parent_name}"

        link_dest = self.link_dest()
        exclude_file = self.prepare_exclude_file()

        log.info("Creating snapshot: %s", name)
        made = run_on(self.dst, f"mkdir -p {shquote(target_dir)}")
        if made.code != 0:
            raise AppError(f"Failed to create the snapshot directory: {snapshot_dir}")
        self.incomplete = name

        # The rsync log is written by whichever machine runs rsync, so when the
        # destination is remote and rsync runs here it is uploaded afterwards.
        upload_log = self.dst.remote and not self.rsync_on_dst
        log_target = (
            str(self.tmp / LOG_FILENAME) if upload_log else f"{snapshot_dir}/{LOG_FILENAME}"
        )

        args = self.build_rsync_args(log_target, exclude_file, link_dest, target_dir)
        code = self.run_rsync(args)
        # Expected on a live directory and does not invalidate the snapshot
        if code == RSYNC_VANISHED:
            log.warning("Some source files vanished during the transfer (rsync code 24)")
        elif code != 0:
            raise AppError(f"Rsync failed during snapshot creation (exit code {code})")
        finished = int(time.time())

        if cfg.dry_run:
            log.info("Dry run: removing the temporary snapshot directory")
            self.delete_snapshots([name], real=True)
            self.incomplete = ""
            return

        if upload_log:
            uploaded = run_on(
                self.dst,
                f"cat > {shquote(f'{snapshot_dir}/{LOG_FILENAME}')}",
                data=Path(log_target).read_bytes() if Path(log_target).exists() else b"",
            )
            if uploaded.code != 0:
                log.warning("Failed to upload the rsync log to the destination")

        self.write_success_marker(snapshot_dir, name, started, finished)
        # Update the directory timestamp, used as a fallback when the marker
        # cannot be parsed
        run_on(self.dst, f"touch {shquote(snapshot_dir)}")
        self.incomplete = ""
        log.info("Snapshot created successfully in %d seconds", finished - started)

    def run_rsync(self, args: list[str]) -> int:
        """Run rsync where it belongs and return its exit code."""
        if self.rsync_on_dst:
            command = self.cfg.rsync_path or "rsync"
            command += "".join(f" {shquote(arg)}" for arg in args)
            return run_on(self.dst, command, capture=False, timeout=None).code
        log.debug("rsync %s", " ".join(shquote(arg) for arg in args))
        try:
            return subprocess.run(["rsync", *args], check=False).returncode
        except FileNotFoundError as exc:
            raise AppError("rsync is not available on this machine") from exc

    def write_success_marker(
        self, snapshot_dir: str, name: str, started: int, finished: int
    ) -> None:
        # The snapshot name is the start time in a readable form
        started_date, started_clock = name.split("_")
        text = (
            f"Snapshot: {name}\n"
            f"Epoch: {started}\n"
            f"Parent: {self.parent_name}\n"
            f"Source: {self.src.where()}\n"
            f"Destination: {self.dst.where()}\n"
            f"Mode: {self.mode}\n"
            f"Rsync: {self.rsync_version}\n"
            f"Started: {started_date} {started_clock.replace('-', ':')}\n"
            f"Finished: {time.strftime('%Y-%m-%d %H:%M:%S')}\n"
            f"Duration: {finished - started} seconds\n"
            "\n"
            f"More info in {LOG_FILENAME}.\n"
            "\n"
            f"WARNING: If you rename or delete this file, the directory\n"
            "will be considered incomplete and deleted during the next run.\n"
        )
        marker = f"{snapshot_dir}/{SUCCESS_FILE}"
        result = run_on(self.dst, f"cat > {shquote(marker)}", data=text.encode("utf-8"))
        if result.code != 0:
            raise AppError(f"Failed to write the completion marker: {marker}")

    def should_create_snapshot(self) -> bool:
        """Decide whether enough time has passed since the last snapshot."""
        if not self.snapshots:
            log.info("No previous snapshots found, creating the initial backup")
            return True
        if self.cfg.force:
            return True
        last = self.snapshots[0]
        # Older snapshots have no recorded epoch; fall back to the directory mtime
        last_epoch = last.epoch or last.mtime
        if not last_epoch:
            log.warning("Cannot determine the age of the last snapshot: %s", last.name)
            log.warning("Creating a new snapshot anyway")
            return True
        now = int(time.time())
        age_hours = (now - last_epoch) // 3600
        if now < last_epoch + self.cfg.timeout_seconds:
            log.warning(
                "Snapshot creation skipped: the last snapshot is only %d hour(s) old", age_hours
            )
            log.warning(
                "Use --force to override the timeout (%d hours)", self.cfg.timeout_seconds // 3600
            )
            return False
        log.info("The last snapshot is %d hour(s) old, proceeding with the backup", age_hours)
        return True

    # -- cleanup and main flow --------------------------------------------

    def close_ssh_masters(self) -> None:
        if not self.control_dir:
            return
        hosts = {side.host: side for side in (self.src, self.dst) if side.remote}
        for host, side in hosts.items():
            try:
                subprocess.run(
                    [*side.ssh, "-O", "exit", host],
                    stdin=subprocess.DEVNULL,
                    capture_output=True,
                    timeout=30,
                    check=False,
                )
            except (OSError, subprocess.TimeoutExpired):
                log.debug("Could not close the ssh master for %s", host)
        with contextlib.suppress(OSError):
            self.control_dir.rmdir()  # only succeeds when no other run uses it

    def cleanup(self, *, failed: bool) -> None:
        if failed and self.incomplete:
            log.warning("Snapshot creation interrupted. Removing the incomplete snapshot.")
            try:
                removed = self.delete_snapshots([self.incomplete], real=True)
            except AppError as exc:
                log.error("%s", exc)
                removed = False
            if not removed:
                log.error("Failed to remove the incomplete snapshot: %s", self.incomplete)
            self.incomplete = ""
        self.release_lock()
        if self.remote_tmp_files:
            command = "\n".join(f"rm -f {shquote(path)}" for path in self.remote_tmp_files)
            run_on(self.dst, f"{command}\nexit 0")
            self.remote_tmp_files = []
        self.close_ssh_masters()

    def run(self) -> None:
        log.info("Starting backup process...")
        started = time.time()
        finished_ok = False
        with tempfile.TemporaryDirectory(prefix="bsnap.") as tmp:
            self.tmp = Path(tmp)
            try:
                self.setup_sides()
                self.show_configuration()
                self.check_rsync_available()
                self.validate_source()
                self.validate_destination()
                self.finalize_paths()
                self.acquire_lock()

                self.load_inventory()
                self.remove_interrupted_snapshots()
                if self.should_create_snapshot():
                    self.create_snapshot()
                    self.load_inventory()
                self.remove_old_snapshots()
                finished_ok = True
            finally:
                # Also runs on Ctrl-C and SIGTERM, which raise out of the code above
                self.cleanup(failed=not finished_ok)
        log.info("Backup completed successfully in %d seconds", int(time.time() - started))


def on_sigterm(signum: int, frame: object) -> NoReturn:
    """Unwind like Ctrl-C does, so that the cleanup runs."""
    raise SystemExit(SIGTERM_EXIT_CODE)


def cmd_backup(args: argparse.Namespace) -> int:
    explicit = args.config is not None or bool(os.environ.get(ENV_CONFIG))
    config_path = args.config or Path(os.environ.get(ENV_CONFIG) or DEFAULT_CONFIG)
    config = load_config(config_path.expanduser(), explicit)

    level = resolve(args.log_level, ENV_LOG_LEVEL, config, DEFAULT_LOG_LEVEL)
    if level not in LOG_LEVELS:
        raise AppError(f"Invalid {ENV_LOG_LEVEL} value: '{level}' (use {', '.join(LOG_LEVELS)})")
    if args.verbose and LOG_LEVELS.index(level) < LOG_LEVELS.index("info"):
        level = "info"
    configure_logging(level)

    settings = resolve_settings(args, config)
    signal.signal(signal.SIGTERM, on_sigterm)
    Backup(settings).run()
    return 0


def main(argv: Sequence[str] | None = None) -> int:
    argv = list(sys.argv[1:] if argv is None else argv)
    parser = build_parser()

    try:
        reject_short_equals(argv)
        args = parser.parse_args(argv)
        return cmd_backup(args)
    except UsageError as exc:
        parser.error(str(exc))
    except AppError as exc:
        print(f"Error: {exc}", file=sys.stderr)
        return 1
    except KeyboardInterrupt:
        print("Interrupted", file=sys.stderr)
        return 130
    except BrokenPipeError:
        # Output piped into a command that exited early (e.g. `| head`)
        devnull = os.open(os.devnull, os.O_WRONLY)
        os.dup2(devnull, sys.stdout.fileno())
        return 1


if __name__ == "__main__":
    sys.exit(main())

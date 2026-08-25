#!/usr/bin/env bash
# backup_snapshot.sh - differential snapshot backups with rsync and hard links.
#
# Either side may live on a remote host reachable over ssh, so the supported
# transfer modes are:
#
#   local  -> local     rsync runs locally
#   local  -> remote    rsync runs locally, destination is host:/path
#   remote -> local     rsync runs locally, source is host:/path
#   remote -> remote    both paths on the SAME host; rsync is executed there
#
# rsync cannot talk to two different remote hosts at once, so remote -> remote
# across two different hosts is rejected with a clear error.

set -euo pipefail

# ============================================================================
# CONSTANTS
# ============================================================================

# Names of generated files
readonly LOG_FILENAME="rsync-log"
readonly SUCCESS_FILE="completed_successfully"
readonly LOCK_DIRNAME=".backup_snapshot.lock"

# Snapshot directory name format: 2026-08-24_23-15-17
readonly SNAPSHOT_NAME_FORMAT="+%Y-%m-%d_%H-%M-%S"

# Strict ERE, used locally to decide whether a directory is a snapshot.
readonly SNAPSHOT_NAME_PATTERN="20[0-9]{2}-(0[1-9]|1[0-2])-\
(0[1-9]|[1-2][0-9]|3[0-1])_([0-1][0-9]|2[0-3])-\
([0-5][0-9])-([0-5][0-9])"

# Coarse glob, used on the destination host because POSIX sh has no ERE.
# Everything it returns is re-validated locally against the strict pattern.
readonly SNAPSHOT_NAME_GLOB="20[0-9][0-9]-[0-9][0-9]-[0-9][0-9]_\
[0-9][0-9]-[0-9][0-9]-[0-9][0-9]"

# Define colors (disabled when stdout is not a terminal)
if [[ -t 1 ]]; then
    COL_RESET=$'\033[0m'
    COL_R=$'\033[31m'
    COL_G=$'\033[32m'
    COL_Y=$'\033[33m'
else
    COL_RESET=""
    COL_R=""
    COL_G=""
    COL_Y=""
fi
readonly COL_RESET COL_R COL_G COL_Y

# ============================================================================
# GLOBAL STATE
# ============================================================================

# Path specs as given on the command line
SOURCE_SPEC=""
DEST_SPEC=""

# Parsed source side
SRC_IS_REMOTE=false
SRC_HOST="" # [user@]host
SRC_PORT=""
SRC_PATH=""
SRC_PATH_GIVEN="" # Before resolution, for messages

# Parsed destination side
DST_IS_REMOTE=false
DST_HOST=""
DST_PORT=""
DST_PATH=""
DST_PATH_GIVEN=""

# ssh port options (the path spec never carries a port, same as rsync)
SSH_PORT=""     # --port
SRC_SSH_PORT="" # --src-port
DST_SSH_PORT="" # --dst-port

# ssh transport (command plus options, never the target host)
SSH_COMMAND="ssh"
SRC_SSH_COMMAND=""
DST_SSH_COMMAND=""
SSH_MULTIPLEX=true
SSH_CONTROL_DIR=""
SSH_CONTROL_PATH=""

# Fully built ssh argv for each side, including the target host
SRC_SSH=()
DST_SSH=()

# Where rsync itself is executed: "local" or "dst"
RSYNC_SIDE="local"
RSYNC_VERSION="unknown"
MODE_DESCRIPTION=""

PARENT_DIR_NAME="" # Defaults to basename of the source path

# Default values that can be overridden by command line arguments
IS_FORCE=false     # -f, --force
SNAPSHOTS_TO_KEEP= # -k NUM, --keep=NUM
AUTO_CONFIRM=false # -y, --yes
DRY_RUN=false      # -n, --dry-run
QUIET=false        # -q, --quiet
# Minimal time between snapshots, in seconds (6 hours)
SNAPSHOT_TIMEOUT=$((60 * 60 * 6)) # -t MIN, --timeout=MIN

# Exclude patterns and files (arrays to handle multiple values)
EXCLUDE_PATTERNS=()   # -e/--exclude patterns
EXCLUDE_FROM_FILES=() # --exclude-from files
EXCLUDE_PRESET=""     # --exclude-preset=NAME
EXCLUDE_ZFS_SNAPDIR=true # --include-zfs-snapdir disables this

# rsync passthrough options
RSYNC_PATH=""       # --rsync-path
RSYNC_EXTRA_ARGS=() # --rsync-arg

# Snapshot name is generated right before use to avoid timestamp race conditions
SNAPSHOT_NAME=""
SNAPSHOT_START_EPOCH=""

# Cleanup bookkeeping
INCOMPLETE_SNAPSHOT="" # Snapshot dir to remove if the run does not finish
LOCK_ACQUIRED=false
LOCAL_TMP_FILES=()
REMOTE_TMP_FILES=()

# ============================================================================
# LOGGING
# ============================================================================

log_info() {
    "$QUIET" && return 0
    printf '%sINFO:%s %s\n' "$COL_G" "$COL_RESET" "$1"
}

log_warn() {
    printf '%sWARN:%s %s\n' "$COL_Y" "$COL_RESET" "$1"
}

log_error() {
    printf '%sERROR:%s %s\n' "$COL_R" "$COL_RESET" "$1" >&2
}

exit_err() {
    printf '%sERR:%s %s\n' "$COL_R" "$COL_RESET" "$1" >&2
    exit "${2:-1}"
}

# ============================================================================
# CONFIGURATION
# ============================================================================

# Exclude preset for a typical Linux home directory. It is NOT applied unless
# explicitly requested with --exclude-preset=home, so that backing up an
# unrelated directory can never silently skip its contents.
get_exclude_preset_home() {
    cat <<'EOF'
*/.terraform.lock.hcl
*/.terraform/
*/.venv/
.cache/
.cargo/
.config/Code/
.config/Slack/
.config/coc/
.config/google-chrome/
.config/joplin-desktop/
.config/skypeforlinux/
.config/pcloud/Cache/
.joplin/
.local/share/nvim/
.local/apps/jellyfin/cache/
.local/share/flatpak/
.local/share/bob/
.local/share/TelegramDesktop/tdata/user_data/
.mozilla/
.npm/
.nvm/
.rustup/
.tfenv/
.tgenv/
.thunderbird/
.vim/
.vscode/
Documents/
Downloads/
Timeshift_exclude/
build/
go/
migration/
pCloudDrive/
vm/
EOF
}

# Write the combined exclude patterns to the given file.
# Returns 1 when there is nothing to exclude.
create_exclude_file() {
    local exclude_file="$1"
    local pattern exclude_from_file pattern_count

    true >"$exclude_file"

    if [[ -n "$EXCLUDE_PRESET" && "$EXCLUDE_PRESET" != "none" ]]; then
        log_info "Using exclude preset: $EXCLUDE_PRESET"
        "get_exclude_preset_${EXCLUDE_PRESET}" >>"$exclude_file"
    fi

    if [[ ${#EXCLUDE_PATTERNS[@]} -gt 0 ]]; then
        log_info "Adding ${#EXCLUDE_PATTERNS[@]} exclude patterns from the command line"
        for pattern in "${EXCLUDE_PATTERNS[@]}"; do
            printf '%s\n' "$pattern" >>"$exclude_file"
        done
    fi

    if [[ ${#EXCLUDE_FROM_FILES[@]} -gt 0 ]]; then
        log_info "Adding patterns from ${#EXCLUDE_FROM_FILES[@]} exclude files"
        for exclude_from_file in "${EXCLUDE_FROM_FILES[@]}"; do
            log_info "  Including patterns from: $exclude_from_file"
            # Add patterns from file, skipping empty lines and comments
            grep -v '^#' "$exclude_from_file" | grep -v '^[[:space:]]*$' >>"$exclude_file" || {
                log_warn "No valid patterns found in: $exclude_from_file"
            }
        done
    fi

    pattern_count=$(grep -c -v '^[[:space:]]*$' "$exclude_file" 2>/dev/null || true)
    [[ -z "$pattern_count" ]] && pattern_count=0

    if [[ "$pattern_count" -eq 0 ]]; then
        log_info "Exclude configuration: no patterns configured"
        return 1
    fi

    log_info "Total exclude patterns: $pattern_count"
    return 0
}

usage() {
    cat <<EOF
USAGE: $(basename "$0") -s SOURCE -d DEST [OPTIONS]

Create a differential backup snapshot using rsync with hard links. Unchanged
files are hard-linked to the previous snapshot, so every snapshot is a full,
browsable copy of the source while costing only the changed files in space.

Either side may be remote. See PATHS below.

By default a snapshot is created only if the last one is older than the
configured timeout ($((SNAPSHOT_TIMEOUT / 3600)) hour(s)).

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

OPTIONS:
    -s, --source=PATH        Source directory to back up (required)

    -d, --dest=PATH          Directory holding the snapshots (required)

    -p, --parent-name=NAME   Name of the directory holding the copied data
                             inside each snapshot
                             (default: basename of the source path)

    -f, --force              Ignore the timeout and create a snapshot anyway

    -y, --yes                Auto-confirm all prompts (non-interactive mode)

    -n, --dry-run            Show what rsync would do, change nothing

    -q, --quiet              Suppress informational output

    -t MIN, --timeout=MIN    Minimum time in minutes between snapshots
                             (default: $((SNAPSHOT_TIMEOUT / 60)) minutes)

    -k NUM, --keep=NUM       Number of snapshots to retain
                             (default: keep all snapshots)

    -e, --exclude=PATTERN    Exclude files/directories matching PATTERN
                             (can be used multiple times)

    --exclude-from=FILE      Read exclude patterns from FILE
                             (can be used multiple times)

    --include-zfs-snapdir    Descend into .zfs directories. They are skipped
                             by default: on a dataset with snapdir=visible,
                             .zfs/snapshot exposes every ZFS snapshot as a
                             browsable tree, so copying it multiplies the
                             backup by the number of snapshots.

    --exclude-preset=NAME    Prepend a built-in exclude list. Supported names:
                             home, none. Later uses override earlier ones, so
                             --exclude-preset=none disables a preset set by a
                             wrapper script.
                             (default: none)

    --ssh-command=CMD        ssh command and options used to reach a remote
                             side, WITHOUT the target host
                             (default: $SSH_COMMAND)

    --src-ssh-command=CMD    Override --ssh-command for the source side only
    --dst-ssh-command=CMD    Override --ssh-command for the destination side

    --port=N                 ssh port used for every remote side

    --src-port=N             ssh port for the source side only
    --dst-port=N             ssh port for the destination side only
                             A port written into --ssh-command wins over
                             these, because ssh keeps the first -p it is
                             given.

    --no-multiplex           Do not add ssh connection multiplexing options.
                             Multiplexing is on by default so that the several
                             short ssh calls of one run share a single
                             authenticated connection. Any ControlMaster or
                             ControlPath given in --ssh-command takes
                             precedence over the ones added here.

    --rsync-path=CMD         Passed to rsync as --rsync-path when exactly one
                             side is remote. When both sides are on the same
                             remote host it is used as the rsync command run
                             there, so --rsync-path='sudo rsync' works in both
                             cases.

    --rsync-arg=ARG          Extra argument passed through to rsync
                             (can be used multiple times)

    -h, --help               Show this help message and exit

EXAMPLES:
    # Local to local
    $(basename "$0") -s /home/user -d /media/user/bckp/home_backup

    # Local to NAS
    $(basename "$0") -s /home/user -d truenas:/mnt/tank/backups/laptop

    # NAS to NAS, rsync runs on the NAS, nothing crosses this machine
    $(basename "$0") -s truenas:/mnt/tank/photo \\
        -d truenas:/mnt/tank/backups/photo -k 12

    # Pull from a NAS to a local disk, custom key and port
    $(basename "$0") -s andrei@192.168.50.185:/mnt/tank/photo \\
        -d /media/user/bckp/photo --port=2222 \\
        --ssh-command='ssh -i ~/.ssh/homenet'

    # Remote paths relative to the login directory and to the remote home
    $(basename "$0") -s truenas:photo -d truenas:backups/photo
    $(basename "$0") -s 'truenas:~/photo' -d truenas:/mnt/tank/backups/photo

    # Consistent source: read from a ZFS snapshot instead of the live dataset
    $(basename "$0") \\
        -s truenas:/mnt/tank/photo/.zfs/snapshot/auto-2026-08-24/ \\
        -d truenas:/mnt/tank/backups/photo -p photo

RESULTING LAYOUT:
    DEST/2026-08-24_23-15-17/PARENT/...   copied data
    DEST/2026-08-24_23-15-17/$LOG_FILENAME          rsync log for this snapshot
    DEST/2026-08-24_23-15-17/$SUCCESS_FILE      completion marker and metadata

NOTES:
    - Snapshots use hard links for space efficiency
    - Interrupted snapshots are removed on the next run
    - A snapshot without its $SUCCESS_FILE marker is considered incomplete
    - A lock directory in DEST prevents two runs from overlapping
    - If the parent name changes between runs, hard linking still works: the
      previous parent name is read back from the marker file
    - Remote relative and ~ paths are resolved to absolute at startup
    - .zfs directories are skipped unless --include-zfs-snapdir is given
    - rsync splits --ssh-command on whitespace, so paths inside it cannot
      contain spaces
    - Exclude files support comments (#) and blank lines are ignored
EOF
}

# ============================================================================
# ARGUMENT PARSING
# ============================================================================

process_cmd_options() {
    __show_error_and_usage() {
        log_error "$1"
        echo "Run with -h or --help for usage instructions." >&2
        exit "${2:-1}"
    }

    __is_positive_integer() {
        [[ "$1" =~ ^[1-9][0-9]*$ ]] 2>/dev/null
    }

    __validate_positive_integer() {
        if ! __is_positive_integer "$1"; then
            __show_error_and_usage "Invalid value '$1': must be a positive integer" 10
        fi
    }

    __validate_port() {
        if ! __is_positive_integer "$1" || [[ "$1" -gt 65535 ]]; then
            __show_error_and_usage "Invalid port '$1': must be between 1 and 65535" 10
        fi
    }

    __get_option_value() {
        local option="$1"
        local value="${2-}"

        if [[ -z "$value" || "$value" =~ ^- ]]; then
            __show_error_and_usage "Option $option requires a value" 9
        fi
        printf '%s' "$value"
    }

    # Values that may legitimately start with '-' (exclude patterns, rsync
    # arguments) are taken verbatim instead.
    __get_verbatim_value() {
        local option="$1"
        local count="$2"
        local value="${3-}"

        if [[ "$count" -lt 2 ]]; then
            __show_error_and_usage "Option $option requires a value" 9
        fi
        if [[ -z "$value" ]]; then
            __show_error_and_usage "Option $option requires a non-empty value" 9
        fi
        printf '%s' "$value"
    }

    # Short options that require a value. Used by the squash-expansion below
    # to stop mid-token once one of these is hit: a value-taking short
    # option consumes the rest of its token (or the next argv item, if
    # nothing is left) as its value, and nothing after it is treated as
    # more flags -- same GNU/POSIX convention as `tar -xvf file` (note -f
    # must come last).
    local value_opts="sdptke"

    # Normalize the command line into one token per option and one per value:
    # --opt=value becomes two tokens, and squashed short options (-fy -> -f -y)
    # are split, so the parsing loop below handles one thing at a time.
    local expanded=() chars i c rest
    while [[ $# -gt 0 ]]; do
        case "$1" in
        --*=*)
            expanded+=("${1%%=*}" "${1#*=}")
            ;;
        --*)
            expanded+=("$1")
            ;;
        -?*)
            if [[ ${#1} -gt 2 ]]; then
                chars="${1#-}"
                for ((i = 0; i < ${#chars}; i++)); do
                    c="${chars:i:1}"
                    expanded+=("-$c")
                    case "$value_opts" in
                    *"$c"*)
                        rest="${chars:i+1}"
                        if [[ -n "$rest" ]]; then
                            expanded+=("$rest")
                        fi
                        break
                        ;;
                    esac
                done
            else
                expanded+=("$1")
            fi
            ;;
        *)
            expanded+=("$1")
            ;;
        esac
        shift
    done
    if [[ ${#expanded[@]} -gt 0 ]]; then
        set -- "${expanded[@]}"
    fi

    while [[ $# -gt 0 ]]; do
        case "$1" in
        -h | --help)
            usage
            exit 0
            ;;
        -s | --source)
            SOURCE_SPEC=$(__get_option_value "$1" "${2-}")
            shift 2
            ;;
        -d | --dest)
            DEST_SPEC=$(__get_option_value "$1" "${2-}")
            shift 2
            ;;
        -p | --parent-name)
            PARENT_DIR_NAME=$(__get_option_value "$1" "${2-}")
            shift 2
            ;;
        -f | --force)
            IS_FORCE=true
            shift
            ;;
        -n | --dry-run)
            DRY_RUN=true
            shift
            ;;
        -q | --quiet)
            QUIET=true
            shift
            ;;
        -y | --yes)
            AUTO_CONFIRM=true
            shift
            ;;
        -t | --timeout)
            SNAPSHOT_TIMEOUT=$(__get_option_value "$1" "${2-}")
            __validate_positive_integer "$SNAPSHOT_TIMEOUT"
            SNAPSHOT_TIMEOUT="$((SNAPSHOT_TIMEOUT * 60))"
            shift 2
            ;;
        -k | --keep)
            SNAPSHOTS_TO_KEEP=$(__get_option_value "$1" "${2-}")
            __validate_positive_integer "$SNAPSHOTS_TO_KEEP"
            shift 2
            ;;
        -e | --exclude)
            EXCLUDE_PATTERNS+=("$(__get_verbatim_value "$1" "$#" "${2-}")")
            shift 2
            ;;
        --exclude-from)
            local exclude_file
            exclude_file="$(__get_option_value "$1" "${2-}")"
            if [[ ! -f "$exclude_file" ]]; then
                __show_error_and_usage "Exclude file does not exist: $exclude_file" 13
            fi
            if [[ ! -r "$exclude_file" ]]; then
                __show_error_and_usage "Exclude file is not readable: $exclude_file" 14
            fi
            EXCLUDE_FROM_FILES+=("$exclude_file")
            shift 2
            ;;
        --exclude-preset)
            EXCLUDE_PRESET="$(__get_option_value "$1" "${2-}")"
            case "$EXCLUDE_PRESET" in
            home | none) ;;
            *) __show_error_and_usage "Unknown exclude preset: $EXCLUDE_PRESET (supported: home, none)" 15 ;;
            esac
            shift 2
            ;;
        --ssh-command)
            SSH_COMMAND="$(__get_option_value "$1" "${2-}")"
            shift 2
            ;;
        --src-ssh-command)
            SRC_SSH_COMMAND="$(__get_option_value "$1" "${2-}")"
            shift 2
            ;;
        --dst-ssh-command)
            DST_SSH_COMMAND="$(__get_option_value "$1" "${2-}")"
            shift 2
            ;;
        --port)
            SSH_PORT="$(__get_option_value "$1" "${2-}")"
            __validate_port "$SSH_PORT"
            shift 2
            ;;
        --src-port)
            SRC_SSH_PORT="$(__get_option_value "$1" "${2-}")"
            __validate_port "$SRC_SSH_PORT"
            shift 2
            ;;
        --dst-port)
            DST_SSH_PORT="$(__get_option_value "$1" "${2-}")"
            __validate_port "$DST_SSH_PORT"
            shift 2
            ;;
        --no-multiplex)
            SSH_MULTIPLEX=false
            shift
            ;;
        --include-zfs-snapdir)
            EXCLUDE_ZFS_SNAPDIR=false
            shift
            ;;
        --rsync-path)
            RSYNC_PATH="$(__get_option_value "$1" "${2-}")"
            shift 2
            ;;
        --rsync-arg)
            RSYNC_EXTRA_ARGS+=("$(__get_verbatim_value "$1" "$#" "${2-}")")
            shift 2
            ;;
        -*)
            __show_error_and_usage "Unknown option: $1" 11
            ;;
        *)
            __show_error_and_usage "Unexpected positional argument: $1. This script does not accept positional arguments." 12
            ;;
        esac
    done

    [[ -z "$SOURCE_SPEC" ]] && __show_error_and_usage "Missing required option: -s/--source" 9
    [[ -z "$DEST_SPEC" ]] && __show_error_and_usage "Missing required option: -d/--dest" 9

    return 0
}

# ============================================================================
# PATH SPECS AND SSH TRANSPORT
# ============================================================================

# Quote a string for safe interpolation into a POSIX sh command line.
shquote() {
    local s="${1-}"
    s="${s//\'/\'\\\'\'}"
    printf "'%s'" "$s"
}

# Emit a shell word for a path. A leading ~/ has to survive as an unquoted
# expansion, so it becomes "$HOME"/rest; everything else is quoted verbatim.
path_expr() {
    local path="$1"

    case "$path" in
    "~") printf '"$HOME"' ;;
    "~/"*) printf '"$HOME"/%s' "$(shquote "${path#\~/}")" ;;
    *) shquote "$path" ;;
    esac
}

# Drop trailing slashes, keeping a bare "/" intact.
strip_trailing_slashes() {
    local path="$1"
    while [[ "$path" == */ && "$path" != "/" ]]; do
        path="${path%/}"
    done
    printf '%s' "$path"
}

# Reject ~user paths on either side: expanding them would mean handing an
# unquoted path to the remote shell, which is not worth the risk.
reject_user_tilde() {
    local path="$1" label="$2"

    case "$path" in
    "~" | "~/"*) return 0 ;;
    "~"*) exit_err "$label: ~user paths are not supported, use an absolute path: $path" 16 ;;
    esac
    return 0
}

# Parse a path spec into _PS_REMOTE / _PS_HOST / _PS_PATH.
#
# This is rsync's single-colon syntax and nothing more: [user@]host:path,
# where path may be absolute, relative to the login directory, or ~/relative.
# The ssh port is never part of the spec, which is exactly what keeps
# host:relative unambiguous; use --port for it.
parse_path_spec() {
    local spec="$1" label="$2"

    _PS_REMOTE=false
    _PS_HOST=""
    _PS_PATH=""

    case "$spec" in
    \[*)
        # Checked before the daemon syntax below, which [::1]:/path would
        # otherwise match on its double colon
        exit_err "$label: IPv6 literals are not supported, use a ~/.ssh/config host alias: $spec" 16
        ;;
    rsync://* | *::*)
        exit_err "$label: rsync daemon syntax is not supported: $spec" 16
        ;;
    /* | ./* | ../*)
        # A leading ./ is the escape hatch for a local path holding a colon
        _PS_PATH="$spec"
        ;;
    "~" | "~/"*)
        _PS_PATH="${HOME}${spec#\~}"
        ;;
    "~"*)
        reject_user_tilde "$spec" "$label"
        ;;
    *)
        if [[ "$spec" =~ ^(([A-Za-z0-9._+-]+)@)?([A-Za-z0-9._-]+):(.*)$ ]]; then
            _PS_REMOTE=true
            _PS_HOST="${BASH_REMATCH[3]}"
            [[ -n "${BASH_REMATCH[2]}" ]] && _PS_HOST="${BASH_REMATCH[2]}@${_PS_HOST}"
            _PS_PATH="${BASH_REMATCH[4]}"
            reject_user_tilde "$_PS_PATH" "$label"
        else
            _PS_PATH="$spec"
        fi
        ;;
    esac

    _PS_PATH="$(strip_trailing_slashes "$_PS_PATH")"
    [[ -z "$_PS_PATH" ]] && exit_err "$label: empty path in '$spec'" 16

    return 0
}

# Build the ssh argv (transport command, options, target host) for one side.
# Sets _SSH_ARGV (without host) and _SSH_RSH (the string handed to rsync -e).
build_ssh_argv() {
    local cmd_string="$1" port="$2" label="$3"
    local parts=() arg

    if ! eval "parts=( $cmd_string )" 2>/dev/null; then
        exit_err "$label: cannot parse ssh command: $cmd_string" 17
    fi
    if [[ ${#parts[@]} -eq 0 ]]; then
        exit_err "$label: empty ssh command" 17
    fi

    # Appended, not prepended: ssh keeps the first -p it is given, so a port
    # written into --ssh-command deliberately wins over --port.
    if [[ -n "$port" ]]; then
        parts+=(-p "$port")
    fi

    # rsync's -e option splits on whitespace and knows nothing about quoting.
    _SSH_RSH="${parts[*]}"
    for arg in "${parts[@]}"; do
        if [[ "$arg" == *[[:space:]]* ]]; then
            log_warn "$label: ssh argument '$arg' contains whitespace; rsync cannot pass it through -e"
        fi
    done

    if "$SSH_MULTIPLEX"; then
        # Appended last on purpose: ssh honours the first value it is given
        # for an option, so anything the user put in --ssh-command wins.
        parts+=(
            -o ControlMaster=auto
            -o "ControlPath=${SSH_CONTROL_PATH}"
            -o ControlPersist=60
        )
    fi

    _SSH_ARGV=("${parts[@]}")
    return 0
}

# Pick a directory for the ssh control sockets. Unix domain socket paths are
# limited to about 104 characters and ssh spends 40 of them on the %C hash
# plus a temporary suffix while the master starts, so the usual macOS TMPDIR
# under /var/folders is already too long to hold one.
setup_ssh_control_dir() {
    local dir

    "$SSH_MULTIPLEX" || return 0
    "$SRC_IS_REMOTE" || "$DST_IS_REMOTE" || return 0

    dir="/tmp/.bsnap-$(id -u 2>/dev/null || echo 0)"

    if ! mkdir -p "$dir" 2>/dev/null; then
        log_warn "Cannot create the ssh control directory: $dir"
        log_warn "Continuing without ssh connection multiplexing"
        SSH_MULTIPLEX=false
        return 0
    fi
    chmod 700 "$dir" 2>/dev/null || true

    if [[ $((${#dir} + 60)) -gt 104 ]]; then
        log_warn "Path too long for an ssh control socket: $dir"
        log_warn "Continuing without ssh connection multiplexing"
        SSH_MULTIPLEX=false
        return 0
    fi

    SSH_CONTROL_DIR="$dir"
    SSH_CONTROL_PATH="${dir}/%C"
    return 0
}

# Resolve both path specs, decide where rsync runs and describe the mode.
setup_sides() {
    local src_rsh="" dst_rsh=""

    parse_path_spec "$SOURCE_SPEC" "Source"
    SRC_IS_REMOTE="$_PS_REMOTE"
    SRC_HOST="$_PS_HOST"
    SRC_PATH="$_PS_PATH"
    SRC_PATH_GIVEN="$_PS_PATH"

    parse_path_spec "$DEST_SPEC" "Destination"
    DST_IS_REMOTE="$_PS_REMOTE"
    DST_HOST="$_PS_HOST"
    DST_PATH="$_PS_PATH"
    DST_PATH_GIVEN="$_PS_PATH"

    SRC_PORT="${SRC_SSH_PORT:-$SSH_PORT}"
    DST_PORT="${DST_SSH_PORT:-$SSH_PORT}"

    if [[ -n "${SSH_PORT}${SRC_SSH_PORT}${DST_SSH_PORT}" ]] &&
        ! "$SRC_IS_REMOTE" && ! "$DST_IS_REMOTE"; then
        log_warn "A port was given but neither side is remote; it will be ignored"
    fi

    setup_ssh_control_dir

    if "$SRC_IS_REMOTE"; then
        build_ssh_argv "${SRC_SSH_COMMAND:-$SSH_COMMAND}" "$SRC_PORT" "Source"
        SRC_SSH=("${_SSH_ARGV[@]}" "$SRC_HOST")
        src_rsh="$_SSH_RSH"
    fi

    if "$DST_IS_REMOTE"; then
        build_ssh_argv "${DST_SSH_COMMAND:-$SSH_COMMAND}" "$DST_PORT" "Destination"
        DST_SSH=("${_SSH_ARGV[@]}" "$DST_HOST")
        dst_rsh="$_SSH_RSH"
    fi

    if "$SRC_IS_REMOTE" && "$DST_IS_REMOTE"; then
        if [[ "$SRC_HOST" != "$DST_HOST" || "$SRC_PORT" != "$DST_PORT" ]]; then
            exit_err "rsync cannot transfer between two different remote hosts ($SRC_HOST -> $DST_HOST).
       Run this script on one of them, or make one side local." 18
        fi
        RSYNC_SIDE="dst"
        RSYNC_RSH=""
        MODE_DESCRIPTION="remote -> remote (same host; rsync executes on $DST_HOST)"
    elif "$SRC_IS_REMOTE"; then
        RSYNC_SIDE="local"
        RSYNC_RSH="$src_rsh"
        MODE_DESCRIPTION="remote -> local (rsync executes here)"
    elif "$DST_IS_REMOTE"; then
        RSYNC_SIDE="local"
        RSYNC_RSH="$dst_rsh"
        MODE_DESCRIPTION="local -> remote (rsync executes here)"
    else
        RSYNC_SIDE="local"
        RSYNC_RSH=""
        MODE_DESCRIPTION="local -> local"
    fi

    readonly SRC_IS_REMOTE SRC_HOST SRC_PORT
    readonly DST_IS_REMOTE DST_HOST DST_PORT
    readonly RSYNC_SIDE RSYNC_RSH MODE_DESCRIPTION
    return 0
}

# Called once both paths have been resolved to absolute paths.
finalize_paths() {
    if [[ "$SRC_PATH" != "$SRC_PATH_GIVEN" ]]; then
        log_info "Source path resolved to: $SRC_PATH"
    fi
    if [[ "$DST_PATH" != "$DST_PATH_GIVEN" ]]; then
        log_info "Destination path resolved to: $DST_PATH"
    fi

    # Default parent directory name is the basename of the resolved source
    [[ -z "$PARENT_DIR_NAME" ]] && PARENT_DIR_NAME="$(basename "$SRC_PATH")"

    case "$PARENT_DIR_NAME" in
    */* | *\\* | . | ..)
        exit_err "Invalid parent directory name: $PARENT_DIR_NAME" 4
        ;;
    esac
    # A tab would corrupt the tab separated snapshot inventory
    if [[ "$PARENT_DIR_NAME" == *$'\t'* ]]; then
        exit_err "Parent directory name cannot contain tabs: $PARENT_DIR_NAME" 4
    fi

    log_info "Parent name: $PARENT_DIR_NAME"

    readonly SRC_PATH DST_PATH PARENT_DIR_NAME
    return 0
}

# host:path for a remote side, plain path for a local one
location_of() {
    local is_remote="$1" host="$2" path="$3"

    if "$is_remote"; then
        printf '%s:%s' "$host" "$path"
    else
        printf '%s' "$path"
    fi
}

describe_side() {
    local is_remote="$1" host="$2" port="$3" path="$4"

    if "$is_remote"; then
        if [[ -n "$port" ]]; then
            printf 'remote  %s:%s (port %s)' "$host" "$path" "$port"
        else
            printf 'remote  %s:%s' "$host" "$path"
        fi
    else
        printf 'local   %s' "$path"
    fi
}

show_configuration() {
    log_info "Source:      $(describe_side "$SRC_IS_REMOTE" "$SRC_HOST" "$SRC_PORT" "$SRC_PATH")"
    log_info "Destination: $(describe_side "$DST_IS_REMOTE" "$DST_HOST" "$DST_PORT" "$DST_PATH")"
    log_info "Mode:        $MODE_DESCRIPTION"
    if [[ -n "$RSYNC_RSH" ]]; then
        log_info "Transport:   $RSYNC_RSH"
    elif "$DST_IS_REMOTE"; then
        log_info "Transport:   ${DST_SSH[*]:0:$((${#DST_SSH[@]} - 1))}"
    fi
    "$DRY_RUN" && log_warn "Dry run: no changes will be made"
    return 0
}

# ============================================================================
# LOCAL / REMOTE EXECUTION LAYER
# ============================================================================

# ssh hands the command to the remote login shell, which is not necessarily
# POSIX: zsh aborts on a glob that matches nothing, fish and csh do not even
# share the syntax. Wrapping every snippet in sh -c makes the remote side
# behave the same as the local one regardless of the account's shell.
remote_sh() {
    printf 'sh -c %s' "$(shquote "$1")"
}

# Run a POSIX sh command string on one side ("src" or "dst").
# stdin is closed so that ssh cannot swallow the caller's input.
run_on() {
    local side="$1" cmd="$2"

    case "$side" in
    src)
        if "$SRC_IS_REMOTE"; then
            "${SRC_SSH[@]}" "$(remote_sh "$cmd")" </dev/null
        else
            sh -c "$cmd" </dev/null
        fi
        ;;
    dst)
        if "$DST_IS_REMOTE"; then
            "${DST_SSH[@]}" "$(remote_sh "$cmd")" </dev/null
        else
            sh -c "$cmd" </dev/null
        fi
        ;;
    *)
        exit_err "Internal error: unknown side '$side'" 99
        ;;
    esac
}

# Same as run_on, but stdin is passed through (used to write remote files).
pipe_on() {
    local side="$1" cmd="$2"

    case "$side" in
    src)
        if "$SRC_IS_REMOTE"; then
            "${SRC_SSH[@]}" "$(remote_sh "$cmd")"
        else
            sh -c "$cmd"
        fi
        ;;
    dst)
        if "$DST_IS_REMOTE"; then
            "${DST_SSH[@]}" "$(remote_sh "$cmd")"
        else
            sh -c "$cmd"
        fi
        ;;
    esac
}

# Write stdin to a file on the given side.
write_file_on() {
    local side="$1" path="$2"
    pipe_on "$side" "cat > $(shquote "$path")"
}

# Create a temporary file on the destination host and remember it for cleanup.
# The path is returned in _TMP_FILE: a command substitution would run these in
# a subshell and lose the bookkeeping needed to clean the file up later.
create_remote_tmp_file() {
    if ! _TMP_FILE=$(run_on dst 'mktemp "${TMPDIR:-/tmp}/bsnap.XXXXXX"'); then
        exit_err "Failed to create a temporary file on $DST_HOST" 4
    fi
    REMOTE_TMP_FILES+=("$_TMP_FILE")
    return 0
}

create_local_tmp_file() {
    if ! _TMP_FILE=$(mktemp "${TMPDIR:-/tmp}/bsnap.XXXXXX"); then
        exit_err "Failed to create a temporary file" 4
    fi
    LOCAL_TMP_FILES+=("$_TMP_FILE")
    return 0
}

# ============================================================================
# PREFLIGHT AND VALIDATION
# ============================================================================

# ssh exits 255 when it could not establish the connection at all, which is a
# different problem from the command failing on the far side.
readonly SSH_CONNECT_FAILURE=255

fail_if_ssh_error() {
    local rc="$1" side="$2"
    local host

    [[ "$rc" -ne "$SSH_CONNECT_FAILURE" ]] && return 0
    if [[ "$side" == "src" ]]; then
        host="$SRC_HOST"
    else
        host="$DST_HOST"
    fi
    exit_err "Cannot connect to $host over ssh; see the ssh error above" 42
}

# Run a command on whichever machine executes rsync.
run_on_rsync_host() {
    if [[ "$RSYNC_SIDE" == "dst" ]]; then
        run_on dst "$1"
    else
        sh -c "$1" </dev/null
    fi
}

check_rsync_available() {
    local cmd

    # When rsync runs on the destination host, --rsync-path names the command
    # to run there, so a plain "rsync" may legitimately be absent.
    if [[ "$RSYNC_SIDE" == "dst" && -n "$RSYNC_PATH" ]]; then
        return 0
    fi

    cmd='command -v rsync >/dev/null 2>&1 || exit 41; rsync --version 2>/dev/null | head -n 1'

    local out rc=0
    out=$(run_on_rsync_host "$cmd") || rc=$?
    if [[ "$rc" -ne 0 ]]; then
        [[ "$RSYNC_SIDE" == "dst" ]] && fail_if_ssh_error "$rc" dst
        if [[ "$RSYNC_SIDE" == "dst" ]]; then
            exit_err "rsync is not available on $DST_HOST" 41
        fi
        exit_err "rsync is not available on this machine" 41
    fi

    RSYNC_VERSION="$out"
    log_info "Rsync:       $RSYNC_VERSION"
    return 0
}

# Check the source and resolve it to an absolute path in the same round trip.
validate_source() {
    local cmd out rc=0
    cmd="p=$(path_expr "$SRC_PATH")
[ -e \"\$p\" ] || exit 21
[ -d \"\$p\" ] || exit 22
[ -r \"\$p\" ] || exit 23
cd -- \"\$p\" 2>/dev/null || exit 24
pwd"

    out=$(run_on src "$cmd") || rc=$?
    fail_if_ssh_error "$rc" src
    case "$rc" in
    0) ;;
    21) exit_err "Source directory does not exist: $SOURCE_SPEC" 2 ;;
    22) exit_err "Source path is not a directory: $SOURCE_SPEC" 2 ;;
    23) exit_err "Source directory is not readable: $SOURCE_SPEC" 2 ;;
    24) exit_err "Source directory cannot be entered: $SOURCE_SPEC" 2 ;;
    *) exit_err "Failed to inspect the source: $SOURCE_SPEC (exit code $rc)" 2 ;;
    esac

    # Everything after this point works with the absolute path, so no later
    # operation depends on the login directory of the ssh session.
    case "$out" in
    /*) SRC_PATH="$(strip_trailing_slashes "$out")" ;;
    *) exit_err "Source did not resolve to an absolute path: $SOURCE_SPEC" 2 ;;
    esac
    return 0
}

# Create the destination if needed, check it, and resolve it to an absolute
# path. Resolution happens here, before the lock and before anything can be
# deleted, so every destructive command later runs against an absolute path.
validate_destination() {
    local cmd out rc=0
    cmd="d=$(path_expr "$DST_PATH")
if [ ! -d \"\$d\" ]; then
  mkdir -p \"\$d\" || exit 31
fi
[ -w \"\$d\" ] || exit 32
cd -- \"\$d\" 2>/dev/null || exit 33
pwd"

    out=$(run_on dst "$cmd") || rc=$?
    fail_if_ssh_error "$rc" dst
    case "$rc" in
    0) ;;
    31) exit_err "Failed to create the destination directory: $DEST_SPEC" 3 ;;
    32) exit_err "Destination directory is not writable: $DEST_SPEC" 3 ;;
    33) exit_err "Destination directory cannot be entered: $DEST_SPEC" 3 ;;
    *) exit_err "Failed to inspect the destination: $DEST_SPEC (exit code $rc)" 3 ;;
    esac

    case "$out" in
    /*) DST_PATH="$(strip_trailing_slashes "$out")" ;;
    *) exit_err "Destination did not resolve to an absolute path: $DEST_SPEC" 3 ;;
    esac
    return 0
}

# ============================================================================
# LOCKING
# ============================================================================

acquire_lock() {
    local lock_dir="${DST_PATH}/${LOCK_DIRNAME}"
    local cmd info

    "$DRY_RUN" && return 0

    cmd="mkdir $(shquote "$lock_dir") 2>/dev/null || exit 51
printf '%s\n' \"host=\$(hostname 2>/dev/null)\" \"pid=$$\" \"started=$(date '+%Y-%m-%d %H:%M:%S')\" \
  > $(shquote "${lock_dir}/info") 2>/dev/null || true
exit 0"

    if ! run_on dst "$cmd"; then
        info=$(run_on dst "cat $(shquote "${lock_dir}/info") 2>/dev/null" || true)
        log_error "Another backup is already running for this destination."
        [[ -n "$info" ]] && printf '%s\n' "$info" >&2
        exit_err "If this is stale, remove the lock: ${DEST_SPEC}/${LOCK_DIRNAME}" 19
    fi

    LOCK_ACQUIRED=true
    return 0
}

release_lock() {
    "$LOCK_ACQUIRED" || return 0
    local lock_dir="${DST_PATH}/${LOCK_DIRNAME}"

    run_on dst "rm -f $(shquote "${lock_dir}/info"); rmdir $(shquote "$lock_dir") 2>/dev/null" >/dev/null 2>&1 || true
    LOCK_ACQUIRED=false
    return 0
}

# ============================================================================
# SNAPSHOT INVENTORY
# ============================================================================

# Parallel arrays describing existing snapshots, newest first.
SNAP_NAMES=()
SNAP_MTIME=()
SNAP_COMPLETE=()
SNAP_EPOCH=()
SNAP_PARENT=()

# One round trip: name, mtime, marker presence, recorded epoch, recorded parent.
build_inventory_command() {
    cat <<EOF
d=$(shquote "$DST_PATH")
[ -d "\$d" ] || exit 0
for p in "\$d"/$SNAPSHOT_NAME_GLOB; do
  [ -d "\$p" ] || continue
  n=\${p##*/}
  m=\$(stat -c %Y "\$p" 2>/dev/null) || m=\$(stat -f %m "\$p" 2>/dev/null) || m=0
  s="\$p/$SUCCESS_FILE"
  if [ -f "\$s" ]; then
    k=1
    e=\$(sed -n 's/^Epoch: //p' "\$s" 2>/dev/null | head -n 1)
    r=\$(sed -n 's/^Parent: //p' "\$s" 2>/dev/null | head -n 1)
  else
    k=0
    e=
    r=
  fi
  printf '%s\t%s\t%s\t%s\t%s\n' "\$n" "\${m:-0}" "\$k" "\${e:-0}" "\$r"
done
exit 0
EOF
}

load_inventory() {
    local tmp_file name mtime complete epoch parent

    SNAP_NAMES=()
    SNAP_MTIME=()
    SNAP_COMPLETE=()
    SNAP_EPOCH=()
    SNAP_PARENT=()

    create_local_tmp_file
    tmp_file="$_TMP_FILE"

    if ! run_on dst "$(build_inventory_command)" >"$tmp_file"; then
        exit_err "Failed to list snapshots in: $DEST_SPEC" 20
    fi

    while IFS=$'\t' read -r name mtime complete epoch parent; do
        [[ -z "$name" ]] && continue
        # Re-validate against the strict pattern; the remote glob is coarse.
        [[ "$name" =~ ^${SNAPSHOT_NAME_PATTERN}$ ]] || continue
        [[ "$mtime" =~ ^[0-9]+$ ]] || mtime=0
        [[ "$epoch" =~ ^[0-9]+$ ]] || epoch=0
        SNAP_NAMES+=("$name")
        SNAP_MTIME+=("$mtime")
        SNAP_COMPLETE+=("$complete")
        SNAP_EPOCH+=("$epoch")
        SNAP_PARENT+=("$parent")
    done < <(LC_ALL=C sort -r "$tmp_file")

    log_info "Found ${#SNAP_NAMES[@]} existing snapshots in $DEST_SPEC"
    return 0
}

is_snapshot_name() {
    [[ "$1" =~ ^${SNAPSHOT_NAME_PATTERN}$ ]]
}

# ============================================================================
# SNAPSHOT DELETION
# ============================================================================

confirmation_dialog() {
    local user_prompt="${1:-Are you sure?}"
    local answer

    printf '%s (y|N): ' "$user_prompt"
    read -rn 1 answer
    echo

    case "$answer" in
    [yY]) return 0 ;;
    *) return 1 ;;
    esac
}

# Delete the named snapshots on the destination host. Every name is validated
# against the snapshot pattern first: this builds "rm -rf" command lines.
delete_snapshots() {
    [[ $# -eq 0 ]] && return 0

    local name path cmd="" quoted

    if [[ -z "$DST_PATH" ]]; then
        exit_err "Internal error: empty destination path, refusing to delete" 99
    fi

    for name in "$@"; do
        if ! is_snapshot_name "$name"; then
            exit_err "Internal error: refusing to delete non-snapshot directory: $name" 99
        fi
        path="${DST_PATH}/${name}"
        quoted=$(shquote "$path")
        log_info "Deleting snapshot: $name"
        if "$DRY_RUN"; then
            continue
        fi
        # Hard-linked trees can contain read-only directories; only pay for
        # the recursive chmod if the plain removal actually fails.
        cmd="${cmd}if [ -d ${quoted} ]; then
  rm -rf ${quoted} 2>/dev/null || {
    chmod -R u+w ${quoted} 2>/dev/null
    rm -rf ${quoted} || exit 61
  }
fi
"
    done

    "$DRY_RUN" && return 0
    [[ -z "$cmd" ]] && return 0

    if ! run_on dst "${cmd}exit 0"; then
        log_error "Failed to delete one or more snapshots"
        return 1
    fi
    return 0
}

remove_interrupted_snapshots() {
    local i names=() keep_names=() keep_mtime=() keep_epoch=() keep_parent=()

    for ((i = 0; i < ${#SNAP_NAMES[@]}; i++)); do
        if [[ "${SNAP_COMPLETE[$i]}" == "1" ]]; then
            keep_names+=("${SNAP_NAMES[$i]}")
            keep_mtime+=("${SNAP_MTIME[$i]}")
            keep_epoch+=("${SNAP_EPOCH[$i]}")
            keep_parent+=("${SNAP_PARENT[$i]}")
        else
            names+=("${SNAP_NAMES[$i]}")
        fi
    done

    if [[ ${#names[@]} -gt 0 ]]; then
        log_warn "Removing ${#names[@]} interrupted snapshot(s)"
        delete_snapshots "${names[@]}" || true
    fi

    # Drop them from the in-memory inventory as well
    SNAP_NAMES=(${keep_names[@]+"${keep_names[@]}"})
    SNAP_MTIME=(${keep_mtime[@]+"${keep_mtime[@]}"})
    SNAP_EPOCH=(${keep_epoch[@]+"${keep_epoch[@]}"})
    SNAP_PARENT=(${keep_parent[@]+"${keep_parent[@]}"})
    SNAP_COMPLETE=()
    for ((i = 0; i < ${#SNAP_NAMES[@]}; i++)); do
        SNAP_COMPLETE+=("1")
    done
    return 0
}

remove_old_snapshots() {
    [[ -z "$SNAPSHOTS_TO_KEEP" ]] && return 0

    local i to_delete=()

    for ((i = SNAPSHOTS_TO_KEEP; i < ${#SNAP_NAMES[@]}; i++)); do
        to_delete+=("${SNAP_NAMES[$i]}")
    done

    [[ ${#to_delete[@]} -eq 0 ]] && return 0

    # Always shown when a prompt follows, otherwise it would ask blind
    if ! "$QUIET" || ! "$AUTO_CONFIRM"; then
        log_warn "The following snapshots will be deleted:"
        printf '  %s\n' "${to_delete[@]}"
    fi

    if ! "$AUTO_CONFIRM" && ! "$DRY_RUN" && ! confirmation_dialog "Proceed with deletion?"; then
        log_info "Snapshot deletion canceled."
        return 0
    fi

    delete_snapshots "${to_delete[@]}"
    "$DRY_RUN" || log_info "Old snapshots deleted successfully."
    return 0
}

# ============================================================================
# SNAPSHOT CREATION
# ============================================================================

# Build the rsync source/destination arguments for the current mode.
rsync_arg_for() {
    local side="$1" path="$2"

    if [[ "$RSYNC_SIDE" == "dst" ]]; then
        # rsync runs on the remote host: both paths are local there
        printf '%s/' "$path"
        return 0
    fi

    case "$side" in
    src)
        if "$SRC_IS_REMOTE"; then
            printf '%s:%s/' "$SRC_HOST" "$path"
        else
            printf '%s/' "$path"
        fi
        ;;
    dst)
        if "$DST_IS_REMOTE"; then
            printf '%s:%s/' "$DST_HOST" "$path"
        else
            printf '%s/' "$path"
        fi
        ;;
    esac
}

# Put the exclude file where rsync will read it. The path is returned in
# _EXCLUDE_FILE, which is empty when there is nothing to exclude.
prepare_exclude_file() {
    local local_file

    _EXCLUDE_FILE=""

    create_local_tmp_file
    local_file="$_TMP_FILE"

    if ! create_exclude_file "$local_file"; then
        return 0 # nothing to exclude
    fi

    if [[ "$RSYNC_SIDE" == "dst" ]]; then
        create_remote_tmp_file
        if ! write_file_on dst "$_TMP_FILE" <"$local_file"; then
            exit_err "Failed to copy the exclude file to $DST_HOST" 4
        fi
        _EXCLUDE_FILE="$_TMP_FILE"
        return 0
    fi

    _EXCLUDE_FILE="$local_file"
    return 0
}

# Find the newest complete snapshot and the parent directory name it used.
# Sets _LINK_DEST (empty when there is nothing to link against).
resolve_link_dest() {
    local prev_name prev_parent

    _LINK_DEST=""
    [[ ${#SNAP_NAMES[@]} -eq 0 ]] && return 0

    prev_name="${SNAP_NAMES[0]}"
    prev_parent="${SNAP_PARENT[0]}"
    # Markers written before Parent was recorded fall back to the current name
    [[ -z "$prev_parent" ]] && prev_parent="$PARENT_DIR_NAME"

    _LINK_DEST="${DST_PATH}/${prev_name}/${prev_parent}"

    if [[ "$prev_parent" != "$PARENT_DIR_NAME" ]]; then
        log_info "Previous snapshot used parent name '$prev_parent'; linking against it"
    fi
    log_info "Hard-linking unchanged files against: ${prev_name}/${prev_parent}"
    return 0
}

# True if a snapshot with this name is already present
snapshot_name_exists() {
    local name="$1" existing

    for existing in ${SNAP_NAMES[@]+"${SNAP_NAMES[@]}"}; do
        [[ "$existing" == "$name" ]] && return 0
    done
    return 1
}

create_snapshot() {
    local snapshot_dir target_dir exclude_file link_dest
    local log_target log_local_tmp="" rsync_args=() rsync_rc=0
    local start_time end_time cmd arg attempts=0

    # Snapshot names have one second of resolution, so two runs started within
    # the same second would otherwise rsync into the same directory and
    # hard-link it against itself.
    SNAPSHOT_NAME=$(date "$SNAPSHOT_NAME_FORMAT")
    while snapshot_name_exists "$SNAPSHOT_NAME"; do
        attempts=$((attempts + 1))
        if [[ $attempts -gt 3 ]]; then
            exit_err "A snapshot named $SNAPSHOT_NAME already exists" 5
        fi
        log_info "Snapshot $SNAPSHOT_NAME already exists, waiting for the next second"
        sleep 1
        SNAPSHOT_NAME=$(date "$SNAPSHOT_NAME_FORMAT")
    done
    readonly SNAPSHOT_NAME
    SNAPSHOT_START_EPOCH=$(date +%s)

    snapshot_dir="${DST_PATH}/${SNAPSHOT_NAME}"
    target_dir="${snapshot_dir}/${PARENT_DIR_NAME}"

    resolve_link_dest
    link_dest="$_LINK_DEST"

    prepare_exclude_file
    exclude_file="$_EXCLUDE_FILE"

    log_info "Creating snapshot: $SNAPSHOT_NAME"
    if ! run_on dst "mkdir -p $(shquote "$target_dir")"; then
        exit_err "Failed to create the snapshot directory: $snapshot_dir" 5
    fi
    INCOMPLETE_SNAPSHOT="$SNAPSHOT_NAME"

    # The rsync log is written by whichever machine runs rsync, so when the
    # destination is remote and rsync runs here it has to be uploaded after.
    if [[ "$RSYNC_SIDE" == "dst" ]] || ! "$DST_IS_REMOTE"; then
        log_target="${snapshot_dir}/${LOG_FILENAME}"
    else
        create_local_tmp_file
        log_local_tmp="$_TMP_FILE"
        log_target="$log_local_tmp"
    fi

    rsync_args=(
        --archive
        --delete
        --force
        --sparse
        --numeric-ids
        --human-readable
        --log-file="$log_target"
    )

    if "$QUIET"; then
        rsync_args+=(--quiet)
    else
        rsync_args+=(--stats)
        [[ -t 1 ]] && rsync_args+=(--info=progress2)
    fi

    "$DRY_RUN" && rsync_args+=(--dry-run)

    # Listed first so that it cannot be overridden by a later rule: .zfs is a
    # synthetic directory whose contents are, by construction, copies of the
    # live tree at earlier points in time.
    if "$EXCLUDE_ZFS_SNAPDIR"; then
        log_info "Skipping ZFS snapshot directories (.zfs/), use --include-zfs-snapdir to copy them"
        rsync_args+=(--exclude=".zfs/")
    fi

    [[ -n "$exclude_file" ]] && rsync_args+=(--exclude-from="$exclude_file")
    [[ -n "$link_dest" ]] && rsync_args+=(--link-dest="$link_dest")

    if [[ "$RSYNC_SIDE" != "dst" ]]; then
        [[ -n "$RSYNC_RSH" ]] && rsync_args+=(-e "$RSYNC_RSH")
        [[ -n "$RSYNC_PATH" ]] && rsync_args+=(--rsync-path="$RSYNC_PATH")
    fi

    rsync_args+=(${RSYNC_EXTRA_ARGS[@]+"${RSYNC_EXTRA_ARGS[@]}"})
    rsync_args+=("$(rsync_arg_for src "$SRC_PATH")" "$(rsync_arg_for dst "$target_dir")")

    start_time=$(date +%s)

    if [[ "$RSYNC_SIDE" == "dst" ]]; then
        cmd="${RSYNC_PATH:-rsync}"
        for arg in "${rsync_args[@]}"; do
            cmd="${cmd} $(shquote "$arg")"
        done
        run_on dst "$cmd" || rsync_rc=$?
    else
        rsync "${rsync_args[@]}" || rsync_rc=$?
    fi

    # 24 means "some source files vanished during the transfer", which is
    # expected on a live directory and does not invalidate the snapshot.
    case "$rsync_rc" in
    0) ;;
    24) log_warn "Some source files vanished during the transfer (rsync code 24)" ;;
    *) exit_err "Rsync failed during snapshot creation (exit code $rsync_rc)" 6 ;;
    esac

    end_time=$(date +%s)

    if "$DRY_RUN"; then
        log_info "Dry run: removing the temporary snapshot directory"
        if [[ -n "$DST_PATH" ]] && is_snapshot_name "$SNAPSHOT_NAME"; then
            run_on dst "rm -rf $(shquote "$snapshot_dir")" || true
        fi
        INCOMPLETE_SNAPSHOT=""
        return 0
    fi

    if [[ -n "$log_local_tmp" ]]; then
        if ! write_file_on dst "${snapshot_dir}/${LOG_FILENAME}" <"$log_local_tmp"; then
            log_warn "Failed to upload the rsync log to the destination"
        fi
    fi

    write_success_marker "$snapshot_dir" "$start_time" "$end_time"

    # Update directory timestamp, used as a fallback when the marker
    # cannot be parsed by an older version of this script.
    run_on dst "touch $(shquote "$snapshot_dir")" || true

    INCOMPLETE_SNAPSHOT=""
    log_info "Snapshot created successfully in $((end_time - start_time)) seconds"
    return 0
}

write_success_marker() {
    local snapshot_dir="$1" start_time="$2" end_time="$3"
    local started_date started_time

    # The snapshot name is the start time; deriving the human readable form
    # from it avoids the incompatible epoch flags of GNU and BSD date.
    started_date="${SNAPSHOT_NAME%%_*}"
    started_time="${SNAPSHOT_NAME#*_}"
    started_time="${started_time//-/:}"

    if ! write_file_on dst "${snapshot_dir}/${SUCCESS_FILE}" <<EOF
Snapshot: ${SNAPSHOT_NAME}
Epoch: ${SNAPSHOT_START_EPOCH}
Parent: ${PARENT_DIR_NAME}
Source: $(location_of "$SRC_IS_REMOTE" "$SRC_HOST" "$SRC_PATH")
Destination: $(location_of "$DST_IS_REMOTE" "$DST_HOST" "$DST_PATH")
Mode: ${MODE_DESCRIPTION}
Rsync: ${RSYNC_VERSION}
Started: ${started_date} ${started_time}
Finished: $(date '+%Y-%m-%d %H:%M:%S')
Duration: $((end_time - start_time)) seconds

More info in ${LOG_FILENAME}.

WARNING: If you rename or delete this file, the directory
will be considered incomplete and deleted during the next run.
EOF
    then
        exit_err "Failed to write the completion marker: ${snapshot_dir}/${SUCCESS_FILE}" 7
    fi
    return 0
}

# Decide whether enough time has passed since the last snapshot.
should_create_snapshot() {
    local last_name last_epoch now age_hours

    if [[ ${#SNAP_NAMES[@]} -eq 0 ]]; then
        log_info "No previous snapshots found, creating the initial backup"
        return 0
    fi

    "$IS_FORCE" && return 0

    last_name="${SNAP_NAMES[0]}"
    last_epoch="${SNAP_EPOCH[0]}"
    # Older snapshots have no recorded epoch; fall back to the directory mtime
    [[ "$last_epoch" == "0" ]] && last_epoch="${SNAP_MTIME[0]}"

    if [[ "$last_epoch" == "0" ]]; then
        log_warn "Cannot determine the age of the last snapshot: $last_name"
        log_warn "Creating a new snapshot anyway"
        return 0
    fi

    now=$(date +%s)
    age_hours=$(((now - last_epoch) / 3600))

    if ((now < last_epoch + SNAPSHOT_TIMEOUT)); then
        log_warn "Snapshot creation skipped: the last snapshot is only $age_hours hour(s) old"
        log_warn "Use --force to override the timeout ($((SNAPSHOT_TIMEOUT / 3600)) hours)"
        return 1
    fi

    log_info "The last snapshot is $age_hours hour(s) old, proceeding with the backup"
    return 0
}

# ============================================================================
# CLEANUP
# ============================================================================

cleanup_temp_files() {
    local path

    if [[ ${#LOCAL_TMP_FILES[@]} -gt 0 ]]; then
        for path in "${LOCAL_TMP_FILES[@]}"; do
            rm -f "$path" 2>/dev/null || true
        done
        LOCAL_TMP_FILES=()
    fi

    if [[ ${#REMOTE_TMP_FILES[@]} -gt 0 ]]; then
        local cmd=""
        for path in "${REMOTE_TMP_FILES[@]}"; do
            cmd="${cmd}rm -f $(shquote "$path")
"
        done
        run_on dst "${cmd}exit 0" >/dev/null 2>&1 || true
        REMOTE_TMP_FILES=()
    fi
    return 0
}

close_ssh_masters() {
    "$SSH_MULTIPLEX" || return 0

    if "$SRC_IS_REMOTE" && [[ ${#SRC_SSH[@]} -gt 0 ]]; then
        "${SRC_SSH[@]:0:$((${#SRC_SSH[@]} - 1))}" -O exit "$SRC_HOST" >/dev/null 2>&1 || true
    fi
    if "$DST_IS_REMOTE" && [[ ${#DST_SSH[@]} -gt 0 ]] && [[ "$DST_HOST" != "$SRC_HOST" ]]; then
        "${DST_SSH[@]:0:$((${#DST_SSH[@]} - 1))}" -O exit "$DST_HOST" >/dev/null 2>&1 || true
    fi
    [[ -n "$SSH_CONTROL_DIR" ]] && rmdir "$SSH_CONTROL_DIR" 2>/dev/null
    return 0
}

on_exit() {
    local exit_code=$?

    if [[ $exit_code -ne 0 && -n "$INCOMPLETE_SNAPSHOT" ]]; then
        log_warn "Snapshot creation interrupted. Removing the incomplete snapshot."
        delete_snapshots "$INCOMPLETE_SNAPSHOT" >/dev/null 2>&1 ||
            log_error "Failed to remove the incomplete snapshot: $INCOMPLETE_SNAPSHOT"
        INCOMPLETE_SNAPSHOT=""
    fi

    release_lock
    cleanup_temp_files
    close_ssh_masters
    return 0
}

on_signal() {
    local signal_exit_code="$1"
    trap - INT TERM
    log_warn "Interrupted, cleaning up..."
    exit "$signal_exit_code"
}

# ============================================================================
# MAIN
# ============================================================================

main() {
    local start_time end_time duration

    trap 'on_exit' EXIT
    trap 'on_signal 130' INT
    trap 'on_signal 143' TERM

    process_cmd_options "$@"

    log_info "Starting backup process..."
    start_time=$(date +%s)

    setup_sides
    show_configuration
    check_rsync_available

    validate_source
    validate_destination
    finalize_paths
    acquire_lock

    load_inventory
    remove_interrupted_snapshots

    if should_create_snapshot; then
        create_snapshot
        load_inventory
    fi

    remove_old_snapshots

    end_time=$(date +%s)
    duration=$((end_time - start_time))

    log_info "Backup completed successfully in ${duration} seconds"
    return 0
}

main "$@"

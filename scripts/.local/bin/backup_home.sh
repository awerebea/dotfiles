#!/usr/bin/env bash

set -euo pipefail # Exit on error, undefined vars, pipe failures

trap cleanup INT TERM

# Global variables with defaults (can be overridden by CLI arguments)
SOURCE_PATH="/home/andrei"
DEST_PATH="/media/andrei/bckp/home_backup"
PARENT_DIR_NAME="" # Will be set to basename of SOURCE_PATH if not specified

# Names of generated files
readonly LOG_FILENAME="rsync-log"
readonly SUCCESS_FILE="completed_successfully"

# Define colors
readonly COL_RESET='\033[0m'
readonly COL_R='\033[31m'
readonly COL_G='\033[32m'
readonly COL_Y='\033[33m'
# readonly COL_B='\033[34m'
# readonly COL_M='\033[35m'
# readonly COL_BOLD='\033[1m'
# readonly COL_R_BOLD='\033[1;31m'
# readonly COL_G_BOLD='\033[1;32m'
# readonly COL_Y_BOLD='\033[1;33m'
# readonly COL_B_BOLD='\033[1;34m'

# Snapshot name will be generated when needed to avoid timestamp race conditions
SNAPSHOT_NAME=""
# Pattern to match snapshot directory names (must match SNAPSHOT_NAME format)
readonly SNAPSHOT_NAME_PATTERN="20([0-9]{2})-(0[1-9]|1[0-2])-\
(0[1-9]|[1-2][0-9]|3[0-1])_(0[0-9]|1[0-9]|2[0-3])-\
([0-5][0-9])-([0-5][0-9])"

# Default values that can be overridden by command line argument
IS_FORCE=false     # -f, --force
SNAPSHOTS_TO_KEEP= # -k NUM, --keep=NUM
AUTO_CONFIRM=false # -y, --yes
# Minimal timeout in minutes (6 hours)
SNAPSHOT_TIMEOUT=$((60 * 60 * 6)) # -t MIN, --timeout=MIN

# Exclude patterns and files (arrays to handle multiple values)
EXCLUDE_PATTERNS=()    # -e/--exclude patterns
EXCLUDE_FROM_FILES=()  # --exclude-from files

# ============================================================================
# CONFIGURATION FUNCTIONS
# ============================================================================

# Default exclude patterns (used when no custom excludes are specified)
get_default_exclude_patterns() {
    cat <<-'EOF'
	*/.terraform.lock.hcl
	*/.terraform/
	.cache/
	.cargo/
	.config/Code/
	.config/Slack/
	.config/coc/
	.config/google-chrome/
	.config/joplin-desktop/
	.config/skypeforlinux/
	.joplin/
	.local/share/nvim/
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

# Create exclude file combining all exclusion sources
create_exclude_file() {
    local exclude_file="$1"
    local pattern exclude_from_file

    # Clear the exclude file
    true > "$exclude_file"

    # If no custom excludes specified, use defaults
    if [[ ${#EXCLUDE_PATTERNS[@]} -eq 0 && ${#EXCLUDE_FROM_FILES[@]} -eq 0 ]]; then
        get_default_exclude_patterns > "$exclude_file"
        log_info "Using default exclude patterns"
        return 0
    fi

    # Add custom exclude patterns
    if [[ ${#EXCLUDE_PATTERNS[@]} -gt 0 ]]; then
        log_info "Adding ${#EXCLUDE_PATTERNS[@]} custom exclude patterns"
        for pattern in "${EXCLUDE_PATTERNS[@]}"; do
            echo "$pattern" >> "$exclude_file"
        done
    fi

    # Add patterns from exclude files
    if [[ ${#EXCLUDE_FROM_FILES[@]} -gt 0 ]]; then
        log_info "Adding patterns from ${#EXCLUDE_FROM_FILES[@]} exclude files"
        for exclude_from_file in "${EXCLUDE_FROM_FILES[@]}"; do
            log_info "  Including patterns from: $exclude_from_file"
            # Add patterns from file, skipping empty lines and comments
            grep -v '^#' "$exclude_from_file" | grep -v '^[[:space:]]*$' >> "$exclude_file" || {
                log_warn "No valid patterns found in: $exclude_from_file"
            }
        done
    fi

    # Log the final number of exclude patterns
    local pattern_count
    pattern_count=$(grep -c -v '^[[:space:]]*$' "$exclude_file" 2>/dev/null || echo 0)
    log_info "Total exclude patterns: $pattern_count"
}

# Show exclude configuration for transparency
show_exclude_info() {
    if [[ ${#EXCLUDE_PATTERNS[@]} -eq 0 && ${#EXCLUDE_FROM_FILES[@]} -eq 0 ]]; then
        log_info "Exclude configuration: Using default patterns"
    else
        log_info "Exclude configuration: Using custom patterns"
        if [[ ${#EXCLUDE_PATTERNS[@]} -gt 0 ]]; then
            log_info "  Command-line patterns: ${#EXCLUDE_PATTERNS[@]}"
        fi
        if [[ ${#EXCLUDE_FROM_FILES[@]} -gt 0 ]]; then
            log_info "  Exclude files: ${EXCLUDE_FROM_FILES[*]}"
        fi
    fi
}

# Usage message
usage() {
    cat <<-EOF
	USAGE: $(basename "$0") [OPTIONS]

	Create differential backup using rsync with hard links.

	By default, creates a snapshot only if the last snapshot is older than
	the configured timeout ($((SNAPSHOT_TIMEOUT / 3600)) hour(s)).

	OPTIONS:
	    -s, --source=PATH        Source directory to backup
	                             (default: $SOURCE_PATH)

	    -d, --dest=PATH          Destination directory for snapshots
	                             (default: $DEST_PATH)

	    -p, --parent-name=NAME   Name for the parent directory in snapshots
	                             (default: basename of source path)

	    -f, --force              Ignore timeout and create snapshot anyway

	    -y, --yes                Auto-confirm all prompts (non-interactive mode)

	    -t MIN, --timeout=MIN    Minimum time in minutes between snapshots
	                             (default: $((SNAPSHOT_TIMEOUT / 60)) minutes)

	    -k NUM, --keep=NUM       Number of snapshots to retain
	                             (default: keep all snapshots)

	    -e, --exclude=PATTERN    Exclude files/directories matching PATTERN
	                             (can be used multiple times)

	    --exclude-from=FILE      Read exclude patterns from FILE
	                             (can be used multiple times)

	    -h, --help               Show this help message and exit

	EXAMPLES:
	    $(basename "$0")                              # Use default paths
	    $(basename "$0") -s /home/user -d /backup     # Custom paths
	    $(basename "$0") --force                      # Force backup creation
	    $(basename "$0") -k 7 -t 1440                 # Keep 7 snapshots, 24h timeout
	    $(basename "$0") -s /data -p mydata           # Custom source and parent name
	    $(basename "$0") -e "*.tmp" -e "cache/"       # Exclude patterns
	    $(basename "$0") -e "-*" -e ".*backup*"       # Exclude patterns starting with - or containing backup
	    $(basename "$0") --exclude-from=.gitignore    # Use exclude file
	    $(basename "$0") -e "*.log" --exclude-from=/etc/backup.exclude  # Combine methods

	NOTES:
	    - Snapshots use hard links for space efficiency
	    - Interrupted snapshots are automatically cleaned up
	    - Each snapshot contains a success marker file for integrity checking
	    - If no exclude options are specified, default exclude patterns are used
	    - Custom excludes completely override defaults (use --exclude-from with defaults if needed)
	    - Multiple -e/--exclude and --exclude-from options can be combined
	    - Exclude files support comments (#) and blank lines are ignored
	EOF
}

# Process and validate command line arguments
process_cmd_options() {
    __show_error_and_usage() {
        log_error "$1"
        echo "Run with -h or --help for usage instructions."
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

    __get_option_value() {
        local option="$1"
        local value="$2"

        if [[ -z "$value" || "$value" =~ ^- ]]; then
            __show_error_and_usage "Option $option requires a value" 9
        fi
        echo "$value"
    }

    while [[ $# -gt 0 ]]; do
        case "$1" in
        -h | --help)
            usage
            exit 0
            ;;
        -s | --source)
            SOURCE_PATH=$(__get_option_value "$1" "$2")
            shift 2
            ;;
        --source=*)
            SOURCE_PATH="${1#*=}"
            if [[ -z "$SOURCE_PATH" ]]; then
                __show_error_and_usage "Option --source requires a value" 9
            fi
            shift
            ;;
        -d | --dest)
            DEST_PATH=$(__get_option_value "$1" "$2")
            shift 2
            ;;
        --dest=*)
            DEST_PATH="${1#*=}"
            if [[ -z "$DEST_PATH" ]]; then
                __show_error_and_usage "Option --dest requires a value" 9
            fi
            shift
            ;;
        -p | --parent-name)
            PARENT_DIR_NAME=$(__get_option_value "$1" "$2")
            shift 2
            ;;
        --parent-name=*)
            PARENT_DIR_NAME="${1#*=}"
            if [[ -z "$PARENT_DIR_NAME" ]]; then
                __show_error_and_usage "Option --parent-name requires a value" 9
            fi
            shift
            ;;
        -f | --force)
            IS_FORCE=true
            shift
            ;;
        -t | --timeout)
            SNAPSHOT_TIMEOUT=$(__get_option_value "$1" "$2")
            __validate_positive_integer "$SNAPSHOT_TIMEOUT"
            SNAPSHOT_TIMEOUT="$((SNAPSHOT_TIMEOUT * 60))"
            shift 2
            ;;
        --timeout=*)
            SNAPSHOT_TIMEOUT="${1#*=}"
            if [[ -z "$SNAPSHOT_TIMEOUT" ]]; then
                __show_error_and_usage "Option --timeout requires a value" 9
            fi
            __validate_positive_integer "$SNAPSHOT_TIMEOUT"
            SNAPSHOT_TIMEOUT="$((SNAPSHOT_TIMEOUT * 60))"
            shift
            ;;
        -k | --keep)
            SNAPSHOTS_TO_KEEP=$(__get_option_value "$1" "$2")
            __validate_positive_integer "$SNAPSHOTS_TO_KEEP"
            shift 2
            ;;
        --keep=*)
            SNAPSHOTS_TO_KEEP="${1#*=}"
            if [[ -z "$SNAPSHOTS_TO_KEEP" ]]; then
                __show_error_and_usage "Option --keep requires a value" 9
            fi
            __validate_positive_integer "$SNAPSHOTS_TO_KEEP"
            shift
            ;;
        -y | --yes)
            AUTO_CONFIRM=true
            shift
            ;;
        -e | --exclude)
            # Handle exclude patterns specially - they can start with '-'
            if [[ $# -lt 2 ]]; then
                __show_error_and_usage "Option $1 requires a value" 9
            fi
            if [[ -z "$2" ]]; then
                __show_error_and_usage "Option $1 requires a non-empty value" 9
            fi
            EXCLUDE_PATTERNS+=("$2")
            shift 2
            ;;
        --exclude=*)
            local pattern="${1#*=}"
            if [[ -z "$pattern" ]]; then
                __show_error_and_usage "Option --exclude requires a value" 9
            fi
            EXCLUDE_PATTERNS+=("$pattern")
            shift
            ;;
        --exclude-from)
            local exclude_file
            exclude_file="$(__get_option_value "$1" "$2")"
            if [[ ! -f "$exclude_file" ]]; then
                __show_error_and_usage "Exclude file does not exist: $exclude_file" 13
            fi
            if [[ ! -r "$exclude_file" ]]; then
                __show_error_and_usage "Exclude file is not readable: $exclude_file" 14
            fi
            EXCLUDE_FROM_FILES+=("$exclude_file")
            shift 2
            ;;
        --exclude-from=*)
            local exclude_file="${1#*=}"
            if [[ -z "$exclude_file" ]]; then
                __show_error_and_usage "Option --exclude-from requires a value" 9
            fi
            if [[ ! -f "$exclude_file" ]]; then
                __show_error_and_usage "Exclude file does not exist: $exclude_file" 13
            fi
            if [[ ! -r "$exclude_file" ]]; then
                __show_error_and_usage "Exclude file is not readable: $exclude_file" 14
            fi
            EXCLUDE_FROM_FILES+=("$exclude_file")
            shift
            ;;
        -*)
            __show_error_and_usage "Unknown option: $1" 11
            ;;
        *)
            __show_error_and_usage "Unexpected positional argument: $1. This script does not accept positional arguments." 12
            ;;
        esac
    done

    # Set default parent directory name if not specified
    [[ -z "$PARENT_DIR_NAME" ]] && PARENT_DIR_NAME="$(basename "$SOURCE_PATH")"

    # Make variables readonly after initialization
    readonly SOURCE_PATH DEST_PATH PARENT_DIR_NAME
}

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================

# Define functions
exit_err() {
    echo -e "${COL_R}ERR:${COL_RESET} $1" >&2
    exit "${2:-1}"
}

log_info() {
    echo -e "${COL_G}INFO:${COL_RESET} $1"
}

log_warn() {
    echo -e "${COL_Y}WARN:${COL_RESET} $1"
}

log_error() {
    echo -e "${COL_R}ERROR:${COL_RESET} $1" >&2
}

# Validate that required directories exist
validate_paths() {
    # Validate source path
    if [[ ! -d "$SOURCE_PATH" ]]; then
        exit_err "Source directory does not exist: $SOURCE_PATH" 2
    fi

    if [[ ! -r "$SOURCE_PATH" ]]; then
        exit_err "Source directory is not readable: $SOURCE_PATH" 2
    fi

    # Validate destination path
    if [[ ! -d "$DEST_PATH" ]]; then
        log_info "Creating destination directory: $DEST_PATH"
        mkdir -p "$DEST_PATH" || exit_err "Failed to create destination directory" 3
    fi

    if [[ ! -w "$DEST_PATH" ]]; then
        exit_err "Destination directory is not writable: $DEST_PATH" 3
    fi

    # Validate parent directory name
    if [[ "$PARENT_DIR_NAME" =~ [/\\] ]]; then
        exit_err "Parent directory name cannot contain path separators: $PARENT_DIR_NAME" 4
    fi

    log_info "Paths validated successfully:"
    log_info "  Source: $SOURCE_PATH"
    log_info "  Destination: $DEST_PATH"
    log_info "  Parent name: $PARENT_DIR_NAME"
}

# Get the list of directories with a name matches the snapshot name pattern
generate_snapshot_list() {
    # Check if destination directory exists before listing
    if [[ ! -d "$DEST_PATH" ]]; then
        return 0 # No snapshots if destination doesn't exist
    fi

    # Use PIPESTATUS to check if find operation succeeded
    local snapshots
    snapshots=$(find "$DEST_PATH" -maxdepth 1 -type d 2>/dev/null | sort -rn |
        grep -P "^${DEST_PATH}/${SNAPSHOT_NAME_PATTERN}$" | sed -e "s|^${DEST_PATH}/||")

    # Check if find command succeeded
    if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
        log_warn "Failed to list directory contents: $DEST_PATH"
        return 1
    fi

    echo "$snapshots"
}

confirmation_dialog() {
    # Confirmation dialog with a single 'y' character to accept

    local user_prompt="${1:-Are you sure?}"
    echo -en "$user_prompt (y|N): "

    local ANS
    if [[ -n "${ZSH_VERSION-}" ]]; then
        read -rk 1 ANS
    else
        read -rn 1 ANS
    fi
    echo # Move to the next line for a cleaner output

    case "$ANS" in
    [yY]) return 0 ;;
    *) return 1 ;;
    esac
}

delete_snapshots() {
    [[ $# -eq 0 ]] && return 0

    local -a non_writable_dirs
    local dir snapshot_path

    for snapshot in "$@"; do
        snapshot_path="${DEST_PATH}/${snapshot}"
        if [[ ! -d "$snapshot_path" ]]; then
            log_warn "Snapshot directory does not exist, skipping: $snapshot"
            continue
        fi

        log_info "Deleting snapshot: $snapshot"

        # Make read-only directories writable before deletion
        if mapfile -t non_writable_dirs < <(find "$snapshot_path" -type d ! -writable 2>/dev/null); then
            for dir in "${non_writable_dirs[@]}"; do
                [[ -n "$dir" ]] && chmod u+w "$dir" 2>/dev/null || true
            done
        fi

        if ! rm -rf "$snapshot_path"; then
            log_error "Failed to delete snapshot: $snapshot"
            return 1
        fi
    done
}

remove_old_snapshots() {
    [[ -z "$SNAPSHOTS_TO_KEEP" ]] && return 0

    local -a snapshots_to_delete_list
    mapfile -t snapshots_to_delete_list < <(
        generate_snapshot_list | tail -n +"$((SNAPSHOTS_TO_KEEP + 1))"
    )

    [[ ${#snapshots_to_delete_list[@]} -eq 0 ]] && return 0

    # List snapshots to be deleted
    log_info "The following snapshots will be deleted:"
    printf '  %s\n' "${snapshots_to_delete_list[@]}"

    # Delete listed snapshots
    if ! "$AUTO_CONFIRM" && ! confirmation_dialog "Proceed with deletion?"; then
        log_info "Snapshot deletion canceled."
        return 0
    fi

    log_info "Deleting old snapshots..."
    delete_snapshots "${snapshots_to_delete_list[@]}"
    log_info "Old snapshots deleted successfully."
}

# Delete interrupted or incomplete snapshots
remove_interrupted_snapshots() {
    local -a snapshots_to_delete_list
    local snapshot

    while IFS= read -r snapshot; do
        if [[ ! -f "${DEST_PATH}/${snapshot}/${SUCCESS_FILE}" ]]; then
            snapshots_to_delete_list+=("$snapshot")
        fi
    done < <(generate_snapshot_list)

    if [[ ${#snapshots_to_delete_list[@]} -gt 0 ]]; then
        log_info "Removing ${#snapshots_to_delete_list[@]} interrupted snapshots"
        delete_snapshots "${snapshots_to_delete_list[@]}"
    fi
}

create_snapshot() {
    local tmp_exclude_file snapshot_dir start_time end_time
    tmp_exclude_file=$(mktemp) || exit_err "Failed to create temporary file" 4
    snapshot_dir="${DEST_PATH}/${SNAPSHOT_NAME}"

    # Ensure cleanup of temp file
    trap 'rm -f "$tmp_exclude_file"' RETURN

    # Show exclude configuration and create exclude file
    show_exclude_info
    create_exclude_file "$tmp_exclude_file"

    log_info "Creating snapshot: $SNAPSHOT_NAME"
    mkdir -p "$snapshot_dir" || exit_err "Failed to create snapshot directory" 5

    start_time=$(date +%s)

    # Create snapshot with rsync
    # Note: includes must come before excludes to work properly
    if ! rsync \
        --archive \
        --recursive \
        --delete \
        --force \
        --sparse \
        --human-readable \
        --progress \
        --log-file="${snapshot_dir}/${LOG_FILENAME}" \
        --include="/*/.*" \
        --include="/.*" \
        --exclude-from="$tmp_exclude_file" \
        --stats \
        "${SOURCE_PATH}/" "${snapshot_dir}/${PARENT_DIR_NAME}/"; then
        exit_err "Rsync failed during snapshot creation" 6
    fi

    end_time=$(date +%s)

    # Create success marker file
    cat <<-EOF >"${snapshot_dir}/${SUCCESS_FILE}"
	Snapshot creation started:  ${SNAPSHOT_NAME}
	Snapshot creation finished: $(date +%Y-%m-%d_%H-%M-%S)
	Duration: $((end_time - start_time)) seconds

	More info in ${LOG_FILENAME}.

	WARNING: If you rename or delete this file, the directory
	will be considered incomplete and deleted during the next run.
	EOF

    # Update directory timestamp
    touch "$snapshot_dir"
    log_info "Snapshot created successfully in $((end_time - start_time)) seconds"
}

link_prev_snapshot() {
    local last_snapshot="$1"
    local snapshot_dir="${DEST_PATH}/${SNAPSHOT_NAME}"
    local prev_snapshot_dir="${DEST_PATH}/${last_snapshot}"

    if [[ ! -d "$prev_snapshot_dir" ]]; then
        log_warn "Previous snapshot directory not found: $last_snapshot"
        return 1
    fi

    log_info "Creating hard links from previous snapshot: $last_snapshot"
    mkdir -p "$snapshot_dir" || exit_err "Failed to create snapshot directory" 7

    if ! rsync \
        --archive \
        --exclude="/${LOG_FILENAME}" \
        --exclude="/${SUCCESS_FILE}" \
        --link-dest="$prev_snapshot_dir" \
        "$prev_snapshot_dir/" \
        "$snapshot_dir/"; then
        exit_err "Failed to create hard links from previous snapshot" 8
    fi
}

# Get the newest directory (by the last modified time) from snapshots
get_newest_dir() {
    local -a snapshots_list
    mapfile -t snapshots_list < <(generate_snapshot_list)

    [[ ${#snapshots_list[@]} -eq 0 ]] && return 0

    local modify_time last_modify_time newest_dir snapshot
    local i="${#snapshots_list[@]}"

    i=$((i - 1))
    # Use portable stat command (works on both Linux and macOS)
    if command -v stat >/dev/null 2>&1; then
        # Linux/GNU stat
        if stat -c %Y "${DEST_PATH}/${snapshots_list[$i]}" >/dev/null 2>&1; then
            last_modify_time=$(stat -c %Y "${DEST_PATH}/${snapshots_list[$i]}")
        # macOS/BSD stat
        else
            last_modify_time=$(stat -f %m "${DEST_PATH}/${snapshots_list[$i]}")
        fi
    else
        exit_err "stat command not available" 12
    fi

    newest_dir="${snapshots_list[$i]}"

    while [[ $i -gt 0 ]]; do
        i=$((i - 1))
        snapshot="${snapshots_list[$i]}"

        # Use the same stat variant as detected above
        if stat -c %Y "${DEST_PATH}/$snapshot" >/dev/null 2>&1; then
            modify_time=$(stat -c %Y "${DEST_PATH}/$snapshot")
        else
            modify_time=$(stat -f %m "${DEST_PATH}/$snapshot")
        fi

        if [[ $modify_time -gt $last_modify_time ]]; then
            last_modify_time="$modify_time"
            newest_dir="$snapshot"
        fi
    done
    echo "$newest_dir"
}

process_snapshot() {
    # Generate snapshot name right before use to avoid timestamp race conditions
    SNAPSHOT_NAME=$(date +%Y-%m-%d_%H-%M-%S)
    readonly SNAPSHOT_NAME

    # Get the last valid snapshot
    local last_snapshot snapshot_time current_time time_diff_hours
    if ! last_snapshot="$(generate_snapshot_list | head -n 1)"; then
        log_warn "Failed to list existing snapshots, proceeding with backup"
        last_snapshot=""
    fi

    if [[ -n "$last_snapshot" ]]; then
        if ! "$IS_FORCE"; then
            # Parse snapshot timestamp from directory name
            if ! snapshot_time=$(date -d "$(sed 's/_/ /;s/-/:/3;s/-/:/3' <<<"$last_snapshot")" +%s 2>/dev/null); then
                log_warn "Could not parse timestamp from snapshot name: $last_snapshot"
                log_warn "Creating new snapshot anyway"
            else
                current_time=$(date +%s)
                time_diff_hours=$(((current_time - snapshot_time) / 3600))

                if ((current_time < (snapshot_time + SNAPSHOT_TIMEOUT))); then
                    log_warn "Snapshot creation skipped: last snapshot is only $time_diff_hours hours old"
                    log_warn "Use --force to override timeout ($((SNAPSHOT_TIMEOUT / 3600)) hours)"
                    return 0
                fi

                log_info "Last snapshot is $time_diff_hours hours old, proceeding with backup"
            fi
        fi

        # Create hard links from previous snapshot for efficiency
        if ! link_prev_snapshot "$last_snapshot"; then
            log_warn "Failed to link previous snapshot, creating full backup"
        fi
    else
        log_info "No previous snapshots found, creating initial backup"
    fi

    create_snapshot
}

cleanup() {
    local exit_code=$?

    # Only cleanup if we're exiting due to an error or interruption
    # and SNAPSHOT_NAME has been generated (meaning we started snapshot creation)
    if [[ $exit_code -ne 0 && -n "${SNAPSHOT_NAME:-}" ]]; then
        log_warn "Snapshot creation interrupted. Cleaning up incomplete snapshot."
        local incomplete_snapshot="${DEST_PATH}/${SNAPSHOT_NAME}"
        if [[ -d "$incomplete_snapshot" ]]; then
            rm -rf "$incomplete_snapshot" 2>/dev/null || {
                log_error "Failed to clean up incomplete snapshot: $incomplete_snapshot"
            }
        fi
    fi
}

main() {
    local start_time end_time duration

    log_info "Starting backup process..."
    start_time=$(date +%s)

    # Process command line arguments
    process_cmd_options "$@"

    # Validate paths before starting
    validate_paths

    # Clean up any interrupted snapshots
    remove_interrupted_snapshots

    # Create new snapshot
    process_snapshot

    # Remove old snapshots if configured
    remove_old_snapshots

    end_time=$(date +%s)
    duration=$((end_time - start_time))

    log_info "Backup completed successfully in ${duration} seconds"
}

main "$@"

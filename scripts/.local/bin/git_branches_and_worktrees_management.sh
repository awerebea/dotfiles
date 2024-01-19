#! /usr/bin/env bash

# -e            Exit on error. Append "|| true" if you expect an error.
# -u            Treat unset variables as an error.
# -o pipefail   Fail if any part of a pipe chain fails.
set -euo pipefail

_is_positive_int() {
    # Check if the argument is a positive integer
    if ! [ "${1}" -gt 0 ] 2>/dev/null; then
        return 1
    fi
}

_is_positive_int_or_float() {
    # Check if the argument is a positive integer or a floating-point number
    if [[ $# -eq 0 ]]; then
        return 1
    fi
    local multiplier="$1"
    if [[ "$multiplier" =~ ^[0-9]+$ ]]; then
        return 0
    elif [[ "$multiplier" =~ ^[0-9]+\.[0-9]+$ ]]; then
        return 0
    else
        return 1
    fi
}

_show_git_branches() {
    # Show branches in a git repository

    local refname_width=75
    local author_width=40
    local sort_order="refname"
    local show_remote_branches=false
    local show_all_branches=false

    while [ $# -gt 0 ]; do
        case "${1}" in
            --refname-width)
                shift
                refname_width="${1}"
                ;;
            --refname-width=*)
                refname_width="${1#*=}"
                ;;
            --author-width)
                shift
                author_width="${1}"
                ;;
            --author-width=*)
                author_width="${1#*=}"
                ;;
            -s | --sort)
                shift
                sort_order="${1}"
                ;;
            --sort=*)
                sort_order="${1#*=}"
                ;;
            -r | --remotes)
                show_remote_branches=true
                ;;
            -a | --all)
                show_all_branches=true
                ;;
            *)
                echo "${0}: Invalid argument: ${1}"
                return 1
                ;;
        esac
        shift
    done

    local num
    for num in "$refname_width" "$author_width"; do
        if ! _is_positive_int "$num"; then
            echo "${0}: Invalid value for argument: ${num}"
            return 1
        fi
    done

    local ref_types=()
    if "$show_remote_branches"; then
        ref_types=("remotes")
    else
        ref_types=("heads")
    fi

    if "$show_all_branches"; then
        ref_types=("heads" "remotes")
    fi

    local -A type_strip
    type_strip=(
        ["heads"]=2
        ["remotes"]=1
    )

    local ref_type ref_name
    for ref_type in "${ref_types[@]}"; do
        git for-each-ref --format='%(refname)' --sort="$sort_order" refs/"$ref_type" | \
            while read -r ref_name; do
            local format_string="%(align:width=${refname_width})"
            format_string+="%(color:bold yellow)%(refname:lstrip=${type_strip[$ref_type]})%(color:reset)%(end)"
            format_string+="%(align:width=${author_width})"
            format_string+="%(color:green)%(committername)%(color:reset)%(end)"
            format_string+="(%(color:blue)%(committerdate:relative)%(color:reset))"
            git for-each-ref --format="$format_string" "$ref_name" --color=always
        done
    done
}

_sgb_get_segment_width_relative_to_window() {
    # Calculate the width of a segment relative to the width of the terminal window

    if [[ $# -eq 0 ]] || ! _is_positive_int_or_float "$1"; then
        echo "25"
        return
    else
        local multiplier; multiplier="$1"
    fi
    local width_of_window; width_of_window=$(tput cols)
    local available_width; available_width=$(( width_of_window - 5 )) # Extract the width of the age column
    printf "%.0f" "$(echo "$available_width $multiplier" | awk '{print $1 * $2}')"
}

_confirmation_dialog_with_single_y_char_to_accept() {
    # Confirmation dialog with a single 'y' character to accept

    local user_prompt="${1:-Are you sure?}"
    local read_cmd ANS
    local in_zsh=false
    if [[ -n "$BASH_VERSION" ]]; then
        read_cmd="read -n 1 ANS"
    elif [[ -n "$ZSH_VERSION" ]]; then
        in_zsh=true
        read_cmd="read -k 1 ANS"
    else
        echo "${0}: Unsupported shell"
        return 42
    fi

    echo -n "$user_prompt (y|N): "
    eval "$read_cmd"

    case "$ANS" in
        [yY])
            "$in_zsh" && echo # Move to the next line for a cleaner output
            return 0
            ;;
        *)
            "$in_zsh" && echo # Move to the next line for a cleaner output
            return 1
            ;;
    esac
}

_git_branch_delete() {
    # Delete a Git branch

    local force=false
    local positional_args=()
    while [ $# -gt 0 ]; do
        case "${1}" in
            -f | --force)
                force=true
                ;;
            *)
                positional_args+=("${1}")
                ;;
        esac
        shift
    done

    if [ "${#positional_args[@]}" -eq 0 ]; then
        echo "${0}: Missing argument: list of branches"
        return 1
    fi

    local branches_to_delete="${positional_args[*]}"
    local bare_path; bare_path="$(_git_worktree_get_bare_path)"
    local branch_name is_remote remote_name user_prompt

    while IFS='' read -r branch_name; do
        is_remote=false

        if [[ "$branch_name" == remotes/*/* ]]; then
            is_remote=true
            remote_name="${branch_name#*/}"
            remote_name="${remote_name%%/*}"
        fi

        if "$is_remote"; then
            branch_name="${branch_name#remotes/*/}"
            user_prompt="Delete branch: ${branch_name} from remote: ${remote_name}?"
            if "$force" || _confirmation_dialog_with_single_y_char_to_accept "$user_prompt"; then
                git push --delete "$remote_name" "$branch_name"
            fi
        else
            user_prompt="Delete local branch: ${branch_name}?"
            if "$force" || _confirmation_dialog_with_single_y_char_to_accept "$user_prompt"; then
                git branch -d "$branch_name"
            fi
        fi
    done <<< "$branches_to_delete"
}

_manage_git_branches() {
    # Manage Git branches

    local sort_order="-committerdate"
    local show_remote_branches=false
    local show_all_branches=false
    local positional_args=()

    while [ $# -gt 0 ]; do
        case "${1}" in
            -s | --sort)
                shift
                sort_order="${1}"
                ;;
            --sort=*)
                sort_order="${1#*=}"
                ;;
            -r | --remotes)
                show_remote_branches=true
                ;;
            -a | --all)
                show_all_branches=true
                ;;
            *)
                positional_args+=("${1}")
                ;;
        esac
        shift
    done

    local delete_key="ctrl-d"
    local fzf_cmd="fzf \
        --ansi \
        --header 'Manage recent Git Branches: ctrl-y:jump, ctrl-t:toggle, $delete_key:delete' \
        --preview 'git diff --color=always {1}' \
        --expect='$delete_key' \
        --multi \
        --reverse \
        --cycle \
        --bind=ctrl-y:accept,ctrl-t:toggle+down \
        --select-1 \
        --pointer=''"

    if [[ "${#positional_args[@]}" -gt 0 ]]; then
        fzf_cmd="$fzf_cmd --query='${positional_args[*]}'"
    fi

    local refname_width; refname_width="$(_sgb_get_segment_width_relative_to_window 0.67)"
    local author_width; author_width="$(_sgb_get_segment_width_relative_to_window 0.33)"
    local sgb_cmd="_show_git_branches \
        --sort '$sort_order' \
        --refname-width '$refname_width' \
        --author-width '$author_width'"

    if "$show_remote_branches"; then
        sgb_cmd+=" --remotes"
    fi

    if "$show_all_branches"; then
        sgb_cmd+=" --all"
    fi

    local lines; lines="$(eval "$sgb_cmd" | eval "$fzf_cmd" | cut -d " " -f 1)"

    if [[ -z "$lines" ]]; then
        return
    fi

    local key; key=$(head -1 <<< "$lines")

    if [[ $key == "$delete_key" ]]; then
        _git_branch_delete "$(sed 1d <<< "$lines")"
    else
        local branch_name; branch_name="$(tail -1 <<< "$lines")"
        if [[ "$branch_name" == remotes/*/* ]]; then
            # Remove first two components of the reference name (remotes/<upstream>/)
            branch_name="${branch_name#*/}"
            branch_name="${branch_name#*/}"
        fi
        git switch "$branch_name"
    fi
}

_git_worktree_get_list_of_trees() {
    # Get a list of worktrees
    git worktree list --porcelain | grep -E "^branch refs/heads/" | sed "s|branch refs/heads/||"
}

_git_worktree_get_bare_path() {
    # Get the path to the bare repository
    git worktree list --porcelain | grep -E -B 2 "^bare$" | grep -E "^worktree" | cut -d " " -f 2
}

_git_worktree_get_path_for_branch() {
    # Get the path to the worktree for a given branch

    if [ $# -eq 0 ]; then
        echo "Missing argument: branch name"
        return 1
    fi
    local branch_name="$1"
    local worktrees; worktrees="$(_git_worktree_get_list_of_trees)"
    while IFS= read -r line; do
        if [[ "$line" == "$branch_name" ]]; then
            git worktree list --porcelain | \
                grep -E -B 2 "^branch refs/heads/${branch_name}$" | grep -E "^worktree" | \
                cut -d " " -f 2
        fi
    done <<< "$worktrees"
}

_git_worktree_jump_or_create() {
    # Jump to an existing worktree or create a new one for a given branch

    if [ $# -eq 0 ]; then
        echo "Missing argument: branch name"
        return 1
    fi
    local branch_name="$1"
    if [[ "$branch_name" == remotes/*/* ]]; then
        # Remove first two components of the reference name (remotes/<upstream>/)
        branch_name="${branch_name#*/}"
        branch_name="${branch_name#*/}"
    fi
    local worktree_path; worktree_path="$(_git_worktree_get_path_for_branch "$branch_name")"
    if [[ -n "$worktree_path" ]]; then
        cd "$worktree_path" && \
            echo "Jumped to worktree: $worktree_path, for branch: $branch_name" || return 1
    else
        local bare_path; bare_path="$(_git_worktree_get_bare_path)"
        local worktree_path="${bare_path}/${branch_name}"
        git worktree add "$worktree_path" "$branch_name"
        cd "$worktree_path" || return 1
    fi
}

_git_worktree_delete() {
    # Delete a Git worktree for a given branch

    local force=false
    local positional_args=()
    while [ $# -gt 0 ]; do
        case "${1}" in
            -f | --force)
                force=true
                ;;
            *)
                positional_args+=("${1}")
                ;;
        esac
        shift
    done

    if [ "${#positional_args[@]}" -eq 0 ]; then
        echo "${0}: Missing argument: list of branches"
        return 1
    fi

    local worktrees_to_delete="${positional_args[*]}"
    local bare_path; bare_path="$(_git_worktree_get_bare_path)"
    local branch_name worktree_path user_prompt
    while IFS='' read -r branch_name; do
        if [[ "$branch_name" == remotes/*/* ]]; then
            # Remove first two components of the reference name (remotes/<upstream>/)
            branch_name="${branch_name#*/}"
            branch_name="${branch_name#*/}"
        fi
        worktree_path="$(_git_worktree_get_path_for_branch "$branch_name")"
        if [[ -n "$worktree_path" ]]; then
            if [[ "$PWD" == "$worktree_path" ]]; then
                cd "$bare_path" || return 1
            fi
            user_prompt="Delete worktree: $worktree_path for branch: $branch_name?"
            if "$force" || _confirmation_dialog_with_single_y_char_to_accept "$user_prompt"; then
                git worktree remove "$branch_name" && \
                    echo "Deleted worktree: $worktree_path, for branch: $branch_name"
            fi
        fi
    done <<< "$worktrees_to_delete"
}

_manage_git_worktrees() {
    # Manage Git worktrees

    if [[ -z "$(_git_worktree_get_bare_path)" ]]; then
        echo "Not inside a bare Git repository. Exit..."
        return
    fi

    local sort_order="-committerdate"
    local show_remote_branches=false
    local show_all_branches=false
    local positional_args=()

    while [ $# -gt 0 ]; do
        case "${1}" in
            -s | --sort)
                shift
                sort_order="${1}"
                ;;
            --sort=*)
                sort_order="${1#*=}"
                ;;
            -r | --remotes)
                show_remote_branches=true
                ;;
            -a | --all)
                show_all_branches=true
                ;;
            *)
                positional_args+=("${1}")
                ;;
        esac
        shift
    done

    local delete_key="ctrl-d"
    local fzf_cmd="fzf \
        --ansi \
        --header 'Manage recent Git Worktrees: ctrl-y:jump, ctrl-t:toggle, $delete_key:delete' \
        --preview 'git diff --color=always {1}' \
        --expect='$delete_key' \
        --multi \
        --reverse \
        --cycle \
        --bind=ctrl-y:accept,ctrl-t:toggle+down \
        --select-1 \
        --pointer=''"

    if [[ "${#positional_args[@]}" -gt 0 ]]; then
        fzf_cmd="$fzf_cmd --query='${positional_args[*]}'"
    fi

    local refname_width; refname_width="$(_sgb_get_segment_width_relative_to_window 0.67)"
    local author_width; author_width="$(_sgb_get_segment_width_relative_to_window 0.33)"
    local sgb_cmd="_show_git_branches \
        --sort '$sort_order' \
        --refname-width '$refname_width' \
        --author-width '$author_width'"

    if "$show_remote_branches"; then
        sgb_cmd+=" --remotes"
    fi

    if "$show_all_branches"; then
        sgb_cmd+=" --all"
    fi

    local lines; lines="$(eval "$sgb_cmd" | eval "$fzf_cmd" | cut -d " " -f 1)"

    if [[ -z "$lines" ]]; then
        return
    fi

    local key; key=$(head -1 <<< "$lines")

    if [[ $key == "$delete_key" ]]; then
        _git_worktree_delete "$(sed 1d <<< "$lines")"
    else
        _git_worktree_jump_or_create "$(tail -1 <<< "$lines")"
    fi
}

_main() {
    local cmd="${1:-}"
    shift
    case "$cmd" in
        _show_git_branches)
            local refname_width; refname_width="$(_sgb_get_segment_width_relative_to_window 0.67)"
            local author_width; author_width="$(_sgb_get_segment_width_relative_to_window 0.33)"
            _show_git_branches --refname-width "$refname_width" --author-width "$author_width" "$@"
            ;;
        _manage_git_branches)
            _manage_git_branches "$@"
            ;;
        _manage_git_worktrees)
            _manage_git_worktrees "$@"
            ;;
        *)
            echo "Invalid command: $cmd"
            return 1
            ;;
    esac
}

_main "$@"

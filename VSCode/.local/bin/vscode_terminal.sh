#!/usr/bin/env zsh
# shellcheck disable=SC1071 # zsh script, shellcheck cannot check it
SESSION="vscode$(pwd | md5sum)"
tmux attach-session -d -t "$SESSION" || tmux new-session -s "$SESSION"

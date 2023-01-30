#!/usr/bin/env zsh
SESSION="vscode$(pwd | md5sum)"
tmux attach-session -d -t "$SESSION" || tmux new-session -s "$SESSION"

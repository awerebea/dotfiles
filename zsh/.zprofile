eval "$(/opt/homebrew/bin/brew shellenv)"
# export PATH="$HOMEBREW_PREFIX/opt/python@3.12/libexec/bin:$PATH"

mysql_bin_dir="$HOMEBREW_PREFIX/opt/mysql-client/bin"
if [ -d "$mysql_bin_dir" ] &&
[[ ":$PATH:" != *":$mysql_bin_dir:"* ]]; then
    export PATH="$mysql_bin_dir:$PATH"
fi

# mise shims for non-interactive shells; .zshrc does full activation
if (( $+commands[mise] )); then
    eval "$(mise activate zsh --shims)"
fi

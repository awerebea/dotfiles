#!/usr/bin/env bash

# Script for installing tmux on systems where you don't have root access.
# Tmux will be installed in the bin directory with $HOME/.local or whatever
# prefix passed as the first argument to this script.
# It's assumed that wget and a C/C++ compiler are installed.

# Exit on error
set -e

# Check if dependencies are installed
if ! command -v gcc &> /dev/null && ! command -v clang &> /dev/null; then
    echo "Required C compiler is not installed" 1>&2
    exit 1
fi

TMUX_VERSION="3.3-rc"
LIBEVENT_VERSION="2.1.12-stable"    # latest on 2021.10
NCURSES_VERSION="6.3"               # latest on 2021.10
PREFIX="${1:-$HOME/.local}"
# Generate a random name for temp directory
TMP_DIR=$HOME/tmux_$(tr -dc 'a-zA-Z0-9' < /dev/urandom |
    fold -w 32 | head -n 1)

# Create our directories
mkdir -p "$PREFIX" "$TMP_DIR"
cd "$TMP_DIR"

# Define colors
GRN='\e[1;32m'
YEL='\e[1;33m'
END='\e[0m' # No Color

# Download source files for tmux, libevent, and ncurses
TMUX_URL="https://github.com/tmux/tmux/releases/download/$TMUX_VERSION/\
tmux-$TMUX_VERSION.tar.gz"
LIBEVENT_URL="https://github.com/libevent/libevent/releases/download/\
release-$LIBEVENT_VERSION/libevent-$LIBEVENT_VERSION.tar.gz"
NCURSES_URL="https://invisible-mirror.net/archives/ncurses/\
ncurses-$NCURSES_VERSION.tar.gz"
if command -v curl >/dev/null 2>&1; then
    curl -OJL "$TMUX_URL"
    curl -OJL "$LIBEVENT_URL"
    curl -OJL "$NCURSES_URL"
else
    wget "$TMUX_URL"
    wget "$LIBEVENT_URL"
    wget "$NCURSES_URL"
fi

# Extract files, configure, and compile

# libevent
tar -xvf libevent-$LIBEVENT_VERSION.tar.gz
cd libevent-$LIBEVENT_VERSION
./configure --prefix="$PREFIX" --disable-openssl
make && make install
cd ..

# ncurses
tar -xvf ncurses-$NCURSES_VERSION.tar.gz
cd ncurses-$NCURSES_VERSION
./configure --prefix="$PREFIX"
make && make install
cd ..

# tmux
tar -xvf tmux-$TMUX_VERSION.tar.gz
cd tmux-$TMUX_VERSION
./configure --prefix="$PREFIX" \
    CFLAGS="-I$PREFIX/include -I$PREFIX/include/ncurses" \
    LDFLAGS="-L$PREFIX/lib"
make && make install
cd ..

# Cleanup
rm -rf "$TMP_DIR"

# Update LD_LIBRARY_PATH
if [[ ":$LD_LIBRARY_PATH:" != *":$PREFIX/lib:"* ]]; then
    echo export LD_LIBRARY_PATH="$PREFIX/lib:$LD_LIBRARY_PATH" \
        >> "$HOME"/.bashrc >> "$HOME"/.zshrc
fi
if [[ ":$PATH:" != *":$PREFIX/bin:"* ]]; then
    echo export PATH="$PREFIX/bin:$PATH" \
        >> "$HOME"/.bashrc >> "$HOME"/.zshrc
fi
echo -e "$GRN$PREFIX/bin/tmux$END is now ${GRN}available$END.
Restart the shell to start using it, or run:
${YEL}export LD_LIBRARY_PATH=$PREFIX/lib:\$LD_LIBRARY_PATH
export PATH=$PREFIX/bin:\$PATH$END
to start using it in the current shell session."

#!/usr/bin/env bash

# Script for installing tmux on systems where you don't have root access.
# Tmux will be installed in the bin directory with $HOME/.local or whatever
# prefix passed as the first argument to this script.
# It's assumed that curl or wget and a C/C++ compiler make are installed.
# If the prefix passed in the argument is not writable by the current user,
# the sudo command is used to install.

# Cleanup and and exit
clean-exit () {
    rm -rf "$TMP_DIR"
    exit 1
}

# Check if dependencies are installed
if ! command -v gcc &> /dev/null && ! command -v clang &> /dev/null; then
    echo "Required C compiler is not installed" 1>&2
    exit 1
fi
if ! command -v make &> /dev/null; then
    echo "Required make package is not installed" 1>&2
    exit 1
fi

# Define versions
TMUX_VER="3.3-rc"
LIBEVENT_VER="2.1.12-stable"    # latest on 2021.10
NCURSES_VER="6.3"               # latest on 2021.10

# Define installation prefix
PREFIX="${1:-$HOME/.local}"

# Generate a random name for temp directory
TMP_DIR=$HOME/tmux_$(tr -dc 'a-zA-Z0-9' < /dev/urandom |
    fold -w 32 | head -n 1)

# Check if PREFIX directory is writable for the current user
if [ -w "$PREFIX" ]; then
    MAKE_COMMAND="make"
else
    MAKE_COMMAND="sudo make"
fi

# Create our directories
mkdir -p "$PREFIX" "$TMP_DIR"
cd "$TMP_DIR" || exit 1

# Define colors
GRN='\e[1;32m'
END='\e[0m' # No Color

# Download source files for tmux, libevent, and ncurses
TMUX_URL="https://github.com/tmux/tmux/releases/download/$TMUX_VER/tmux-$TMUX_VER.tar.gz"
LIBEVENT_URL="https://github.com/libevent/libevent/releases/download/release-$LIBEVENT_VER/libevent-$LIBEVENT_VER.tar.gz"
NCURSES_URL="https://ftp.gnu.org/pub/gnu/ncurses/ncurses-$NCURSES_VER.tar.gz"
if command -v curl >/dev/null 2>&1; then
    curl -OJL "$TMUX_URL" || clean-exit
    curl -OJL "$LIBEVENT_URL" || clean-exit
    curl -OJL "$NCURSES_URL" || clean-exit
else
    wget "$TMUX_URL" || clean-exit
    wget "$LIBEVENT_URL" || clean-exit
    wget "$NCURSES_URL" || clean-exit
fi

# Extract files, configure, compile and install

# libevent
tar -xvf libevent-$LIBEVENT_VER.tar.gz || clean-exit
cd libevent-$LIBEVENT_VER || clean-exit
(./configure --prefix="$PREFIX" --disable-openssl && make && $MAKE_COMMAND install) || clean-exit
cd ..

# ncurses
tar -xvf ncurses-$NCURSES_VER.tar.gz
cd ncurses-$NCURSES_VER || clean-exit
(./configure --prefix="$PREFIX" \
    --with-default-terminfo-dir=/usr/share/terminfo \
    --with-terminfo-dirs="/etc/terminfo:/lib/terminfo:/usr/share/terminfo" \
    --enable-pc-files \
    --with-pkg-config-libdir="$PREFIX/lib/pkgconfig" && make && $MAKE_COMMAND install) || clean-exit
cd ..

# tmux
tar -xvf tmux-$TMUX_VER.tar.gz
cd tmux-$TMUX_VER || clean-exit
export PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig"
(./configure --enable-static --prefix="$PREFIX" \
    CFLAGS="-I$PREFIX/include -I$PREFIX/include/ncurses" \
    LDFLAGS="-L$PREFIX/lib" && make && $MAKE_COMMAND install) || clean-exit
cd ..

if [[ ":$PATH:" != *":$PREFIX/bin:"* ]]; then
    cat <<EOT >> "$HOME"/.bashrc >> "$HOME"/.zshrc
if [[ ":\$PATH:" != *":$PREFIX/bin:"* ]]; then
    export PATH="$PREFIX/bin:\$PATH"
fi
EOT
fi

echo -e "$GRN$PREFIX/bin/tmux$END is now ${GRN}available$END."

# Cleanup
rm -rf "$TMP_DIR" || echo "Cleanup of temp dir $TMP_DIR failed."

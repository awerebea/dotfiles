#!/bin/env bash

# Disable password prompt for sudo command
echo "$USER ALL = NOPASSWD: ALL" | sudo tee -a /etc/sudoers

# Disable ssh password authentication
echo "PasswordAuthentication no" | sudo tee -a /etc/ssh/sshd_config
# Disable ssh root login
echo "PermitRootLogin no" | sudo tee -a /etc/ssh/sshd_config

# Add git repository
sudo add-apt-repository -y ppa:git-core/ppa

# Install required packages
sudo apt-get update && \
sudo apt-get install -y \
curl \
git \
gcc \
cmake \
unzip \
gettext \
libx11-dev \
xorg-dev \
xclip \
liblua5.3-dev \
python3-pip \
net-tools \
docker-ce \
nfs-kernel-server \
fasd \
xdotool \
wmctrl

# Install VIM from sources
sudo ln -s /usr/include/lua5.3/lua.h /usr/include/
sudo ln -s /usr/include/lua5.3/luaconf.h /usr/include/
sudo ln -s /usr/include/lua5.3/lualib.h /usr/include/
sudo ln -s /usr/include/lua5.3/lauxlib.h /usr/include/
sudo ln -s /usr/lib/x86_64-linux-gnu/liblua5.3.so.0.0.0 /usr/lib/liblua.so

mkdir -p ~/build
git clone https://github.com/vim/vim.git ~/build/vim
cd ~/build/vim || return
sudo ./configure \
--enable-multibyte \
--with-features=huge \
--enable-luainterp=dynamic \
--enable-python3interp=dynamic \
--enable-cscope \
--enable-gui=auto \
--enable-fontset \
--enable-largefile \
--disable-netbeans \
--with-x \
--enable-fail-if-missing
make && sudo make install

# Install neovim from sources
mkdir -p ~/build
git clone https://github.com/neovim/neovim.git ~/build/neovim
cd ~/build/neovim || return
make && sudo make install

# Install ranger from sources
mkdir -p ~/build
git clone https://github.com/ranger/ranger.git ~/build/ranger
cd ~/build/ranger || return
sudo make install
# To prevent runtime errors
pip3 install gnupg
echo 'export LANGUAGE="en_US.UTF-8"' >> ~/.zshenv
echo 'export LC_ALL="en_US.UTF-8"' >> ~/.zshenv

# Install latest docker
# sudo apt-get install -y \
#     ca-certificates \
#     curl \
#     gnupg \
#     lsb-release
# curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
# echo \
#     "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
#     $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
# sudo apt-get update
# sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# OR

mkdir -p ~/build
cd ~/build || return
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Install latest docker-compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Install anchore-cli
pip3 install anchorecli
{ echo 'export ANCHORE_CLI_URL=http://localhost:8228/v1'; \
    echo 'export ANCHORE_CLI_USER=admin'; \
    echo 'export ANCHORE_CLI_PASS=foobar'; } >> ~/.zshenv

FROM	debian:buster

ENV COLORTERM=truecolor \
	DEBUG_COLORS=true \
	LANG=en_US.UTF-8 \
	LANGUAGE=en_US:en \
	LC_ALL=en_US.UTF-8 \
	TERM=xterm-256color

RUN apt-get update \
&&	apt-get install -y \
	automake \
	bison \
	ctags \
	curl \
	highlight \
	htop \
	libevent-dev \
	locales \
	locales-all \
	make \
	ncurses-dev \
	nginx \
	openssh-server \
	pkg-config \
	ranger \
	ruby \
	telnet \
	unifont \
	wget \
	xdg-utils \
	zsh \
&&	echo "deb http://ftp.de.debian.org/debian sid main" >> /etc/apt/sources.list \
&&	apt -y install software-properties-common dirmngr apt-transport-https lsb-release ca-certificates \
&&	apt-get update \
&&	apt-get install -y \
	clang \
	fasd \
	fzf \
	gcc \
	git \
	gpg \
	ripgrep \
	silversearcher-ag \
	tmux \
	valgrind \
	vim-nox

RUN	locale-gen "en_US.UTF-8" \
&&	rm -rf /var/lib/apt/lists/* \
&&	yes | sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
&&	git clone https://github.com/zsh-users/zsh-history-substring-search ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-history-substring-search \
&&	git clone https://github.com/supercrabtree/k ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/k \
&&	git clone https://github.com/wulfgarpro/history-sync.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/history-sync \
&&	git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions \
&&	git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:=~/.oh-my-zsh/custom}/plugins/zsh-completions \
&&	git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting \
&&	git clone https://github.com/b4b4r07/zsh-vimode-visual ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-vimode-visual \
&&	sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
&&	locale-gen \
&&	chsh -s $(which zsh) \
&&	git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm \
&&	git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim \
&&	cd ~/.vim && mkdir -p undo swap backup bundle \
&&	echo "export ZSH=$HOME/.oh-my-zsh" >> ~/.bashrc

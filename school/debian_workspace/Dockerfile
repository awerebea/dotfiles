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
	clang \
	ctags \
	curl \
	fasd \
	fzf \
	gcc \
	git \
	gpg \
	highlight \
	htop \
	libevent-dev \
	locales \
	locales-all \
	make \
	ncurses-dev \
	openssh-server \
	pkg-config \
	ranger \
	ruby \
	unifont \
	valgrind \
	vim-nox \
	wget \
	xdg-utils \
	zsh

RUN	locale-gen "en_US.UTF-8" \
&&	rm -rf /var/lib/apt/lists/* \
&&	yes | sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
&&	git clone https://github.com/zsh-users/zsh-history-substring-search ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-history-substring-search \
&&	git clone https://github.com/supercrabtree/k ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/k \
&&	git clone https://github.com/wulfgarpro/history-sync.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/history-sync \
&&	git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions \
&&	git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:=~/.oh-my-zsh/custom}/plugins/zsh-completions \
&&	git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting \
&&	sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
&&	locale-gen \
&&	chsh -s $(which zsh) \
&&	git clone https://github.com/tmux/tmux.git \
&&	cd tmux && ./autogen.sh && ./configure && make && make install \
&&	git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm \
&&	git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim \
&&	cd /root/.vim && mkdir -p undo swap backup bundle \
&&	echo "export ZSH=$HOME/.oh-my-zsh" >> ~/.bashrc

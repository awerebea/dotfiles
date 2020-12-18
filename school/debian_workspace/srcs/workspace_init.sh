#!/bin/bash

git clone https://awerebea@github.com/awerebea/workspace.git ~/Github/workspace
cd ~/Github/workspace && git remote set-url origin git@github.com:awerebea/workspace.git
cp -r ~/Github/workspace/.ssh ~/
chown -R root:root /root/.ssh
chmod 600 /root/.ssh/config
chmod 600 /root/.ssh/id_github
chmod 644 /root/.ssh/id_github.pub
chmod 600 /root/.ssh/id_vogsphere
chmod 644 /root/.ssh/id_vogsphere.pub
gpg --import ~/Github/workspace/gpg_keys/gpg_pub_key
gpg --import ~/Github/workspace/gpg_keys/gpg_sec_key
gpg --import ~/Github/workspace/gpg_keys/gpg_sec_sub_key

git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
# sed -i -e 's/ZSH_THEME=\"robbyrussell\"/ZSH_THEME=\"powerlevel10k\/powerlevel10k\"/' ~/.zshrc
# echo '[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh' >> ~/.zshrc

git clone https://github.com/awerebea/dotfiles.git ~/Github/dotfiles
cd ~/Github/dotfiles && git remote set-url origin git@github.com:awerebea/dotfiles.git
rm -f ~/.zshrc
mkdir ~/.config
ln -s ~/Github/dotfiles/.zshrc ~/
ln -s ~/Github/dotfiles/.zshscripts ~/
ln -s ~/Github/dotfiles/.p10k.zsh ~/
ln -s ~/Github/dotfiles/.vimrc ~/
ln -s ~/Github/dotfiles/.tmux.conf ~/
ln -s ~/Github/dotfiles/.tmux.conf.local ~/
ln -s ~/Github/dotfiles/ranger ~/.config/ranger
ln -s ~/Github/dotfiles/.highlight ~/.highlight
ln -s ~/Github/dotfiles/templates ~/.vim/templates
cd / && find ~/ -type f -name *.sh -exec chmod +x {} \;
cp ~/Github/dotfiles/Git/.gitconfig ~/

git config --global user.email "awerebea.21@gmail.com"
git config --global user.name "awerebea (debian_workspace)"

# git clone https://github.com/tmux/tmux.git ~/tmux_install
# cd ~/tmux_install && ./autogen.sh && ./configure && make && make install
# cd ~
# rm -rf ~/tmux_install

export TMUX_PLUGIN_MANAGER_PATH=~/.tmux/plugins/
bash ~/.tmux/plugins/tpm/scripts/install_plugins.sh

wget --directory-prefix=$HOME https://github.com/dandavison/delta/releases/download/0.4.4/delta-0.4.4-x86_64-unknown-linux-musl.tar.gz
tar xvfz ~/delta-0.4.4-x86_64-unknown-linux-musl.tar.gz
mv ~/delta-0.4.4-x86_64-unknown-linux-musl/delta /usr/local/bin/
rm -rf ~/delta-0.4.4-x86_64-unknown-linux-musl ~/delta-0.4.4-x86_64-unknown-linux-musl.tar.gz
ln -s ~/Github/dotfiles/Git/menos /usr/local/bin/

ln -s /usr/lib/x86_64-linux-gnu/libclang-7.so.1 /usr/lib/clang/libclang.so
bash ~/Github/dotfiles/global_gitignore.sh
echo "Vim plugins installing... Don't worry, it may take up to 10 minutes."
vim -E -u NONE -S ~/.vimrc +PluginInstall +qall > /dev/null
zsh

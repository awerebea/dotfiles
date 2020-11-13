#!/bin/sh

cat <<EOT >> ~/.gitignore
*.DS_Store
*.[doa]
*.dSYM/
*.dSYM/*
*.log
*.swo
*.swp
.DS_Store
.clang_complete
.clangd/
.clangd/*
.ctagsignore
.fuse_hidden*
.idea
.vscode
CMakeLists.txt
cmake-build-debug/
cmake-build-debug/*
compile_commands.json
obj/
obj/*
objs/
objs/*
vgcore.*
EOT

git config --global core.excludesfile ~/.gitignore

cat ~/.gitignore | LC_ALL=C sort -u > ~/.gitignore_
rm -f ~/.gitignore
mv ~/.gitignore_ ~/.gitignore

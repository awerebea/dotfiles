#!/bin/sh

cat <<EOT >> ~/.gitignore
*.DS_Store
*.[doa]
*.dSYM/
*.dSYM/*
*.log
*.swo
*.swp
*.tfstate*
.DS_Store
.clang_complete
.clangd/
.clangd/*
.ctagsignore
.fuse_hidden*
.idea
.ignore
.indexer_files_tags/
.indexer_files_tags/*
.ropeproject/
.ropeproject/*
.terraform.lock.hcl
.terraform/
.terraform/*
.venv/
.venv/*
.vimprj/
.vimprj/*
.vscode
CMakeLists.txt
__pycache__/
__pycache__/*
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

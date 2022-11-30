-- set leader key to space
vim.g.mapleader = " "

local keymap = vim.keymap -- for conciseness

---------------------
-- General Keymaps
---------------------

-- Save file as sudo on files that require root permission
keymap.set("c", "w!!", "execute 'silent! write !sudo tee % >/dev/null' <bar> edit!", { noremap = true })
-- clear search highlights
keymap.set("n", "<leader>/", ":<C-u>nohlsearch<CR><C-l>", { silent = true, noremap = true })
keymap.set("n", "<Esc><Esc>", ":<C-u>nohlsearch<CR><C-l>", { silent = true, noremap = true })

-- Always move by screen lines instead of virtual lines with 'j' and 'k'
keymap.set("n", "j", "gj", { silent = true, noremap = true })
keymap.set("n", "k", "gk", { silent = true, noremap = true })

-- increment/decrement numbers
keymap.set("n", "<leader>+", "<C-a>") -- increment
keymap.set("n", "<leader>-", "<C-x>") -- decrement

-- window management
keymap.set("n", "<leader>\\", "<C-w>v") -- split window vertically
keymap.set("n", "<leader>-", "<C-w>s") -- split window horizontally
keymap.set("n", "<leader>=", "<C-w>=") -- make split windows equal width & height
keymap.set("n", "<leader>x", ":close<CR>") -- close current split window
-- buffers management
keymap.set("n", "<M-S-l>", ":bnext<CR>", { noremap = true, silent = true })
keymap.set("n", "<M-S-h>", ":bprevious<CR>", { noremap = true, silent = true })
keymap.set("n", "gp", ":bprevious<CR>", { noremap = true, silent = true })
keymap.set("n", "gn", ":bnext<CR>", { noremap = true, silent = true })
-- tabs management
keymap.set("n", "<leader>o", ":tab ball<CR>", { noremap = true }) -- open all buffers in tab
keymap.set("n", "<leader><Left>", ":tabprevious<CR>", { noremap = true, silent = true })
keymap.set("n", "<leader><Right>", ":tabnext<CR>", { noremap = true, silent = true })
keymap.set("n", "<leader>tp", ":tabprevious<CR>", { noremap = true, silent = true })
keymap.set("n", "<leader>tn", ":tabnext<CR>", { noremap = true, silent = true })
keymap.set("n", "<leader>th", ":tabfirst<CR>", { noremap = true })
keymap.set("n", "<leader>tl", ":tablast<CR>", { noremap = true })
keymap.set("n", "<leader>te", ":tabedit<Space>", { noremap = true })
keymap.set("n", "<leader>tc", ":tabnew<CR>") -- open new tab
keymap.set("n", "<leader>tm", ":tabmove<Space>", { noremap = true })
keymap.set("n", "<leader>tx", ":tabclose<CR>") -- close current tab
keymap.set("n", "<leader>to", ":tabonly<CR>", { noremap = true })
-- Switch to last tab
vim.cmd([[
if !exists('g:lasttab')
  let g:lasttab = 1
endif
autocmd TabLeave * let g:lasttab = tabpagenr()
]])
keymap.set("n", "<leader>tt", ":exe 'tabn '.g:lasttab<CR>") -- switch to last tab
keymap.set("n", "gz", ":bdelete<CR>", { noremap = true }) -- close active buffer

----------------------
-- Plugin Keybinds
----------------------

-- vim-maximizer
keymap.set("n", "<leader><leader>z", ":MaximizerToggle<CR>") -- toggle split window maximization

-- nvim-tree
keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>")
keymap.set("n", "<F2>", ":NvimTreeToggle<CR>")
keymap.set("n", "<leader><F2>", ":NvimTreeFindFile<CR>")

-- telescope
keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>") -- find files within current working directory, respects .gitignore
keymap.set("n", "<C-p>", "<cmd>Telescope find_files<cr>") -- find files within current working directory, respects .gitignore
keymap.set("n", "<leader>fs", "<cmd>Telescope live_grep<cr>") -- find string in current working directory as you type
keymap.set("n", "<leader>fc", "<cmd>Telescope grep_string<cr>") -- find string under cursor in current working directory
keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<cr>") -- list open buffers in current neovim instance
keymap.set("n", "<leader><cr>", "<cmd>Telescope buffers<cr>") -- list open buffers in current neovim instance
keymap.set("n", "<leader>fh", "<cmd>Telescope help_tags<cr>") -- list available help tags

-- telescope git commands (not on youtube nvim video)
keymap.set("n", "<leader>gc", "<cmd>Telescope git_commits<cr>") -- list all git commits (use <cr> to checkout) ["gc" for git commits]
keymap.set("n", "<leader>gfc", "<cmd>Telescope git_bcommits<cr>") -- list git commits for current file/buffer (use <cr> to checkout) ["gfc" for git file commits]
keymap.set("n", "<leader>b", "<cmd>Telescope git_branches<cr>") -- list git branches (use <cr> to checkout) ["gb" for git branch]
keymap.set("n", "<leader>gs", "<cmd>Telescope git_status<cr>") -- list current changes per file with diff preview ["gs" for git status]

-- restart lsp server (not on youtube nvim video)
keymap.set("n", "<leader>rs", ":LspRestart<CR>") -- mapping to restart lsp if necessary

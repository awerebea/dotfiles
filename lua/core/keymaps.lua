-- set leader key to space
vim.g.mapleader = " "

local keymap = vim.keymap -- for conciseness

---------------------
-- General Keymaps
---------------------

-- Save file as sudo on files that require root permission
keymap.set(
  "c",
  "w!!",
  "execute 'silent! write !sudo tee % >/dev/null' <bar> edit!",
  { noremap = true }
)
-- clear search highlights
keymap.set("n", "<leader>/", "<Cmd><C-u>nohlsearch<CR><C-l>", { silent = true, noremap = true })
keymap.set("n", "<Esc><Esc>", "<Cmd><C-u>nohlsearch<CR><C-l>", { silent = true, noremap = true })

-- paste over without overwriting register
vim.cmd([[
  xnoremap <expr> p 'pgv"'.v:register.'y'
]])

-- keep selection when indenting
keymap.set("v", "<", "<gv", { silent = true, noremap = true })
keymap.set("v", ">", ">gv", { silent = true, noremap = true })

-- always move by screen lines instead of virtual lines with 'j' and 'k'
keymap.set("n", "j", "gj", { silent = true, noremap = true })
keymap.set("n", "k", "gk", { silent = true, noremap = true })

-- increment/decrement numbers
keymap.set("n", "<leader>+", "<C-a>") -- increment
keymap.set("n", "<leader>-", "<C-x>") -- decrement

-- window management
keymap.set("n", "<leader>\\", "<C-w>v") -- split window vertically
keymap.set("n", "<leader>-", "<C-w>s") -- split window horizontally
keymap.set("n", "<leader>=", "<C-w>=") -- make split windows equal width & height
keymap.set("n", "<leader>xy", "<Cmd>close<CR>", { silent = true }) -- close current split window
-- buffers management
keymap.set("n", "<M-S-l>", "<Cmd>bnext<CR>", { noremap = true, silent = true })
keymap.set("n", "<M-S-h>", "<Cmd>bprevious<CR>", { noremap = true, silent = true })
keymap.set("n", "gp", "<Cmd>bprevious<CR>", { noremap = true, silent = true })
keymap.set("n", "gn", "<Cmd>bnext<CR>", { noremap = true, silent = true })
-- tabs management
keymap.set("n", "<leader>o", "<Cmd>tab ball<CR>", { noremap = true }) -- open all buffers in tab
keymap.set("n", "<leader><Left>", "<Cmd>tabprevious<CR>", { noremap = true, silent = true })
keymap.set("n", "<leader><Right>", "<Cmd>tabnext<CR>", { noremap = true, silent = true })
keymap.set("n", "<leader>tp", "<Cmd>tabprevious<CR>", { noremap = true, silent = true })
keymap.set("n", "<leader>tn", "<Cmd>tabnext<CR>", { noremap = true, silent = true })
keymap.set("n", "<leader>th", "<Cmd>tabfirst<CR>", { noremap = true })
keymap.set("n", "<leader>tl", "<Cmd>tablast<CR>", { noremap = true })
keymap.set("n", "<leader>te", "<Cmd>tabedit<Space>", { noremap = true })
keymap.set("n", "<leader>tc", "<Cmd>tabnew<CR>") -- open new tab
keymap.set("n", "<leader>tm", "<Cmd>tabmove<Space>", { noremap = true })
keymap.set("n", "<leader>tmp", "<Cmd>-tabmove<CR>", { noremap = true }) -- move current tab left
keymap.set("n", "<leader>tmn", "<Cmd>+tabmove<CR>", { noremap = true }) -- move current tab right
keymap.set("n", "<leader>tx", "<Cmd>tabclose<CR>") -- close current tab
keymap.set("n", "<leader>to", "<Cmd>tabonly<CR>", { noremap = true })
-- Switch to last tab
vim.cmd([[
if !exists('g:lasttab')
  let g:lasttab = 1
endif
autocmd TabLeave * let g:lasttab = tabpagenr()
]])
keymap.set("n", "<leader>tt", "<Cmd>exe 'tabn '.g:lasttab<CR>") -- switch to last tab
keymap.set("n", "gz", "<Cmd>bdelete<CR>", { noremap = true }) -- close active buffer

----------------------
-- Plugin Keybinds
----------------------

-- vim-maximizer
keymap.set("n", "<leader>z", "<Cmd>MaximizerToggle<CR>") -- toggle split window maximization

-- nvim-tree
keymap.set("n", "<leader>e", "<Cmd>NvimTreeToggle<CR>")
keymap.set("n", "<F2>", "<Cmd>NvimTreeToggle<CR>")
keymap.set("n", "<leader><F2>", "<Cmd>NvimTreeFindFile<CR>")

-- telescope
keymap.set("n", "<leader>ff", "<Cmd>Telescope find_files<CR>") -- find files within current working directory, respects .gitignore
keymap.set("n", "<C-p>", "<Cmd>Telescope find_files<CR>") -- find files within current working directory, respects .gitignore
keymap.set("n", "<leader>fg", "<Cmd>Telescope live_grep<CR>") -- find string in current working directory as you type
keymap.set("n", "<leader>fw", "<Cmd>Telescope grep_string<CR>") -- find word under cursor in current working directory
keymap.set("n", "<leader>fb", "<Cmd>Telescope buffers<CR>") -- list open buffers in current neovim instance
keymap.set("n", "<leader><CR>", "<Cmd>Telescope buffers<CR>") -- list open buffers in current neovim instance
keymap.set("n", "<leader>fh", "<Cmd>Telescope help_tags<CR>") -- list available help tags

-- telescope git commands (not on youtube nvim video)
keymap.set("n", "<leader>glg", "<Cmd>echo 'Git commits'<CR> <Cmd>Telescope git_commits<CR>")
keymap.set(
  "n",
  "<leader>glgf",
  "<Cmd>echo 'Git commits of the current file'<CR> <Cmd>Telescope git_bcommits<CR>"
)
keymap.set("n", "<leader>gb", "<Cmd>echo 'Git branches'<CR> <Cmd>Telescope git_branches<CR>")
keymap.set("n", "<leader>gst", "<Cmd>echo 'Git status'<CR> <Cmd>Telescope git_status<CR>")

-- restart lsp server (not on youtube nvim video)
keymap.set("n", "<leader>rs", "<Cmd>LspRestart<CR>") -- mapping to restart lsp if necessary

-- Toggle spell checking
keymap.set("n", "<leader>ssa", "<Cmd>setlocal spell! spelllang=en_us,ru_yo<CR>")
keymap.set("n", "<leader>sse", "<Cmd>setlocal spell! spelllang=en_us<CR>")
keymap.set("n", "<leader>ssr", "<Cmd>setlocal spell! spelllang=ru_yo<CR>")

-- Toggle show non-visible white spaces
keymap.set("n", "<leader>ll", "<Cmd>set list!<CR>")

-- set leader key to space
vim.g.mapleader = " "

local keymap = vim.keymap -- for conciseness
local default_opts = { silent = true, noremap = true }

---------------------
-- General Keymaps
---------------------

-- Save file as sudo on files that require root permission
keymap.set("c", "w!!", "execute 'silent! write !sudo tee % >/dev/null' <bar> edit!", default_opts)
-- clear search highlights
keymap.set("n", "<leader>/", "<Cmd>nohlsearch<CR>", default_opts)
keymap.set("n", "<Esc><Esc>", "<Cmd>nohlsearch<CR>", default_opts)

-- paste over without overwriting register
vim.cmd([[
  xnoremap <expr> p 'pgv"'.v:register.'y'
]])

-- keep selection when indenting
keymap.set("v", "<", "<gv", default_opts)
keymap.set("v", ">", ">gv", default_opts)

-- always move by screen lines instead of virtual lines with 'j' and 'k'
keymap.set("n", "j", "gj", default_opts)
keymap.set("n", "k", "gk", default_opts)

-- window management
keymap.set("n", "<leader>\\", "<C-w>v") -- split window vertically
keymap.set("n", "<leader>-", "<C-w>s") -- split window horizontally
keymap.set("n", "<leader>=", "<C-w>=") -- make split windows equal width & height
keymap.set("n", "<leader>xy", "<Cmd>close<CR>", default_opts) -- close current split window
-- buffers management
keymap.set("n", "<M-S-l>", "<Cmd>bnext<CR>", default_opts)
keymap.set("n", "<M-S-h>", "<Cmd>bprevious<CR>", default_opts)
keymap.set("n", "gp", "<Cmd>bprevious<CR>", default_opts)
keymap.set("n", "gn", "<Cmd>bnext<CR>", default_opts)
-- tabs management
keymap.set("n", "<leader>o", "<Cmd>tab ball<CR>", default_opts) -- open all buffers in tab
keymap.set("n", "<leader><Left>", "<Cmd>tabprevious<CR>", default_opts)
keymap.set("n", "<leader><Right>", "<Cmd>tabnext<CR>", default_opts)
keymap.set("n", "<leader>tp", "<Cmd>tabprevious<CR>", default_opts)
keymap.set("n", "<leader>tn", "<Cmd>tabnext<CR>", default_opts)
keymap.set("n", "<leader>th", "<Cmd>tabfirst<CR>", default_opts)
keymap.set("n", "<leader>tl", "<Cmd>tablast<CR>", default_opts)
keymap.set("n", "<leader>te", "<Cmd>tabedit<Space>", default_opts)
keymap.set("n", "<leader>tc", "<Cmd>tabnew<CR>") -- open new tab
keymap.set("n", "<leader>tm", "<Cmd>tabmove<Space>", default_opts)
keymap.set("n", "<leader>tmp", "<Cmd>-tabmove<CR>", default_opts) -- move current tab left
keymap.set("n", "<leader>tmn", "<Cmd>+tabmove<CR>", default_opts) -- move current tab right
keymap.set("n", "<leader>tx", "<Cmd>tabclose<CR>") -- close current tab
keymap.set("n", "<leader>to", "<Cmd>tabonly<CR>", default_opts)
-- Switch to last tab
vim.cmd([[
if !exists('g:lasttab')
  let g:lasttab = 1
endif
autocmd TabLeave * let g:lasttab = tabpagenr()
]])
keymap.set("n", "<leader>tt", "<Cmd>exe 'tabn '.g:lasttab<CR>", default_opts) -- switch to last tab
keymap.set("n", "gz", "<Cmd>bdelete<CR>", default_opts) -- close active buffer

----------------------
-- Plugin Keybinds
----------------------

-- vim-maximizer
-- toggle split window maximization
keymap.set("n", "<leader>z", "<Cmd>MaximizerToggle<CR>", default_opts)

-- nvim-tree
keymap.set("n", "<leader>e", "<Cmd>NvimTreeToggle<CR>", default_opts)
keymap.set("n", "<F2>", "<Cmd>NvimTreeToggle<CR>", default_opts)
keymap.set("n", "<leader><F2>", "<Cmd>NvimTreeFindFile<CR>", default_opts)

-- telescope
-- find files within current working directory, respects .gitignore
keymap.set("n", "<leader>ff", "<Cmd>Telescope find_files<CR>", default_opts)
-- find files within current working directory, respects .gitignore
keymap.set("n", "<C-p>", "<Cmd>Telescope find_files<CR>", default_opts)
-- find string in current working directory as you type
keymap.set("n", "<leader>fg", "<Cmd>Telescope live_grep<CR>", default_opts)
-- find word under cursor in current working directory
keymap.set("n", "<leader>fw", "<Cmd>Telescope grep_string<CR>", default_opts)
-- list open buffers in current neovim instance
keymap.set("n", "<leader>fb", "<Cmd>Telescope buffers<CR>", default_opts)
-- list open buffers in current neovim instance
keymap.set("n", "<leader><CR>", "<Cmd>Telescope buffers<CR>", default_opts)

keymap.set("n", "<leader>fh", "<Cmd>Telescope help_tags<CR>", default_opts)

-- repeat last telescope command and query
keymap.set("n", "<leader>fr", "<Cmd>Telescope resume<CR>", default_opts)

-- list of items copied to clipboard
keymap.set("n", "<leader>fc", "<Cmd>Telescope neoclip<CR>", default_opts)

-- telescope git commands (not on youtube nvim video)
keymap.set(
  "n",
  "<leader>glg",
  "<Cmd>echo 'Git commits'<CR> <Cmd>Telescope git_commits<CR>",
  default_opts
)
keymap.set(
  "n",
  "<leader>glgf",
  "<Cmd>echo 'Git commits of the current file'<CR> <Cmd>Telescope git_bcommits<CR>",
  default_opts
)
keymap.set(
  "n",
  "<leader>gb",
  "<Cmd>echo 'Git branches'<CR> <Cmd>Telescope git_branches<CR>",
  default_opts
)
keymap.set(
  "n",
  "<leader>gst",
  "<Cmd>echo 'Git status'<CR> <Cmd>Telescope git_status<CR>",
  default_opts
)

-- restart lsp server (not on youtube nvim video)
keymap.set("n", "<leader>rs", "<Cmd>LspRestart<CR>", default_opts) -- mapping to restart lsp if necessary

-- Toggle spell checking
keymap.set("n", "<leader>ssa", "<Cmd>setlocal spell! spelllang=en_us,ru_yo<CR>", default_opts)
keymap.set("n", "<leader>sse", "<Cmd>setlocal spell! spelllang=en_us<CR>", default_opts)
keymap.set("n", "<leader>ssr", "<Cmd>setlocal spell! spelllang=ru_yo<CR>", default_opts)

-- Toggle show non-visible white spaces
keymap.set("n", "<leader>ll", "<Cmd>set list!<CR>", default_opts)

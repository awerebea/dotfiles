local keymap = vim.keymap.set

-- Remap for dealing with word wrap
keymap("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true })
keymap("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true })

-- Better viewing
keymap("n", "n", "nzzzv")
keymap("n", "N", "Nzzzv")
keymap("n", "g,", "g,zvzz")
keymap("n", "g;", "g;zvzz")

-- Add undo break-points
keymap("i", ",", ",<c-g>u")
keymap("i", ".", ".<c-g>u")
keymap("i", ";", ";<c-g>u")

-- Move Lines
keymap("n", "<A-j>", ":m .+1<CR>==")
keymap("v", "<A-j>", ":m '>+1<CR>gv=gv")
keymap("i", "<A-j>", "<Esc>:m .+1<CR>==gi")
keymap("n", "<A-k>", ":m .-2<CR>==")
keymap("v", "<A-k>", ":m '<-2<CR>gv=gv")
keymap("i", "<A-k>", "<Esc>:m .-2<CR>==gi")

-- Resize window using <shift> arrow keys
keymap("n", "<S-Up>", "<cmd>resize +2<CR>")
keymap("n", "<S-Down>", "<cmd>resize -2<CR>")
keymap("n", "<S-Left>", "<cmd>vertical resize -2<CR>")
keymap("n", "<S-Right>", "<cmd>vertical resize +2<CR>")

local default_opts = { silent = true, noremap = true }

---------------------
-- General Keymaps
---------------------

-- Save file as sudo on files that require root permission
keymap("c", "w!!", "execute 'silent! write !sudo tee % >/dev/null' <bar> edit!", default_opts)
-- clear search highlights
keymap("n", "<leader>/", "<Cmd>nohlsearch<CR>", default_opts)
keymap("n", "<Esc><Esc>", "<Cmd>nohlsearch<CR>", default_opts)

-- paste over without overwriting register
vim.cmd [[
  xnoremap <expr> p 'pgv"'.v:register.'y'
]]

-- send changed text segment to black hole
keymap({ "n", "v" }, "c", '"_c')
keymap({ "n", "v" }, "C", '"_C')

-- -- TODO: always move by screen lines instead of virtual lines with 'j' and 'k'
-- keymap("n", "j", "gj", default_opts)
-- keymap("n", "k", "gk", default_opts)

-- window management
keymap("n", "<leader>\\", "<C-w>v") -- split window vertically
keymap("n", "<leader>-", "<C-w>s") -- split window horizontally
keymap("n", "<leader>=", "<C-w>=") -- make split windows equal width & height
keymap("n", "<leader>xy", "<Cmd>close<CR>", default_opts) -- close current split window
-- buffers management
keymap("n", "<M-S-l>", "<Cmd>bnext<CR>", default_opts)
keymap("n", "<M-S-h>", "<Cmd>bprevious<CR>", default_opts)
keymap("n", "gp", "<Cmd>bprevious<CR>", default_opts)
keymap("n", "gn", "<Cmd>bnext<CR>", default_opts)
-- tabs management
keymap("n", "<leader>o", "<Cmd>tab ball<CR>", default_opts) -- open all buffers in tab
keymap("n", "<leader><Left>", "<Cmd>tabprevious<CR>", default_opts)
keymap("n", "<leader><Right>", "<Cmd>tabnext<CR>", default_opts)
keymap("n", "<leader>tp", "<Cmd>tabprevious<CR>", default_opts)
keymap("n", "<leader>tn", "<Cmd>tabnext<CR>", default_opts)
keymap("n", "<leader>th", "<Cmd>tabfirst<CR>", default_opts)
keymap("n", "<leader>tl", "<Cmd>tablast<CR>", default_opts)
keymap("n", "<leader>te", "<Cmd>tabedit<Space>", default_opts)
keymap("n", "<leader>tc", "<Cmd>tabnew<CR>") -- open new tab
keymap("n", "<leader>tm", "<Cmd>tabmove<Space>", default_opts)
keymap("n", "<leader>tmp", "<Cmd>-tabmove<CR>", default_opts) -- move current tab left
keymap("n", "<leader>tmn", "<Cmd>+tabmove<CR>", default_opts) -- move current tab right
keymap("n", "<leader>tx", "<Cmd>tabclose<CR>") -- close current tab
keymap("n", "<leader>to", "<Cmd>tabonly<CR>", default_opts)
-- Switch to last tab
vim.cmd [[
if !exists('g:lasttab')
  let g:lasttab = 1
endif
autocmd TabLeave * let g:lasttab = tabpagenr()
]]
keymap("n", "<leader>tt", "<Cmd>exe 'tabn '.g:lasttab<CR>", default_opts) -- switch to last tab
keymap("n", "gz", "<Cmd>bdelete<CR>", default_opts) -- close active buffer

----------------------
-- Plugin Keybinds
----------------------

-- vim-maximizer
-- toggle split window maximization
keymap("n", "<leader>z", "<Cmd>MaximizerToggle<CR>", default_opts)

-- nvim-tree
keymap("n", "<leader>e", "<Cmd>NvimTreeToggle<CR>", default_opts)
keymap("n", "<F2>", "<Cmd>NvimTreeToggle<CR>", default_opts)
keymap("n", "<leader><F2>", "<Cmd>NvimTreeFindFile<CR>", default_opts)

-- telescope
-- find files within current working directory, respects .gitignore
keymap("n", "<leader>ff", "<Cmd>Telescope find_files<CR>", default_opts)
-- find files within current working directory, respects .gitignore
keymap("n", "<C-p>", "<Cmd>Telescope find_files<CR>", default_opts)
-- find string in current working directory as you type
keymap("n", "<leader>fg", "<Cmd>Telescope live_grep<CR>", default_opts)
-- find word under cursor in current working directory
keymap("n", "<leader>fw", "<Cmd>Telescope grep_string<CR>", default_opts)
-- list open buffers in current neovim instance
keymap("n", "<leader>fb", "<Cmd>Telescope buffers<CR>", default_opts)
-- list open buffers in current neovim instance
keymap("n", "<leader><CR>", "<Cmd>Telescope buffers<CR>", default_opts)

keymap("n", "<leader>fh", "<Cmd>Telescope help_tags<CR>", default_opts)

-- repeat last telescope command and query
keymap("n", "<leader>fr", "<Cmd>Telescope resume<CR>", default_opts)

-- list of items copied to clipboard
keymap("n", "<leader>fc", "<Cmd>Telescope neoclip<CR>", default_opts)

-- telescope git commands (not on youtube nvim video)
keymap("n", "<leader>glg", "<Cmd>echo 'Git commits'<CR> <Cmd>Telescope git_commits<CR>", default_opts)
keymap("n", "<leader>glgf", "<Cmd>echo 'Git commits of the current file'<CR> <Cmd>Telescope git_bcommits<CR>", default_opts)
keymap("n", "<leader>gb", "<Cmd>echo 'Git branches'<CR> <Cmd>Telescope git_branches<CR>", default_opts)
keymap("n", "<leader>gst", "<Cmd>echo 'Git status'<CR> <Cmd>Telescope git_status<CR>", default_opts)

-- restart lsp server (not on youtube nvim video)
keymap("n", "<leader>rs", "<Cmd>LspRestart<CR>", default_opts) -- mapping to restart lsp if necessary

-- Toggle spell checking
keymap("n", "<leader>ssa", "<Cmd>setlocal spell! spelllang=en_us,ru_yo<CR>", default_opts)
keymap("n", "<leader>sse", "<Cmd>setlocal spell! spelllang=en_us<CR>", default_opts)
keymap("n", "<leader>ssr", "<Cmd>setlocal spell! spelllang=ru_yo<CR>", default_opts)

-- Toggle show non-visible white spaces
keymap("n", "<leader>ll", "<Cmd>set list!<CR>", default_opts)

-- Remove duplicate lines (leave only the last occurrence)
keymap("n", "<leader>rd", "<Cmd>g/^\\(.*\\)\\ze\\n\\%(.*\\n\\)*\\1$/d<CR>", vim.tbl_extend("force", default_opts, { desc = "Remove duplicarte lines" }))

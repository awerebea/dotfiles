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
keymap("i", ",", "<c-g>u,")
keymap("i", ".", "<c-g>u.")
keymap("i", ";", "<c-g>u;")
keymap("i", ":", "<c-g>u:")

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

---------------------
-- General Keymaps
---------------------

-- Save file as sudo on files that require root permission
keymap("c", "w!!", "execute 'silent! write !sudo tee % >/dev/null' <bar> edit!", { silent = true })
-- clear search highlights
keymap("n", "<leader>/", "<Cmd>nohlsearch<CR>", { silent = true })
keymap("n", "<Esc><Esc>", "<Cmd>nohlsearch<CR>", { silent = true })

-- paste over without overwriting register
vim.cmd [[
  xnoremap <expr> p 'pgv"'.v:register.'y'
]]

-- send changed text segment to black hole
keymap({ "n", "v" }, "c", '"_c')
keymap({ "n", "v" }, "C", '"_C')

-- window management
keymap("n", "<leader>\\", "<C-w>v") -- split window vertically
keymap("n", "<leader>-", "<C-w>s") -- split window horizontally

-- split left
SplitLeft = function()
  vim.opt.splitright = false
  vim.cmd "vsplit"
  vim.opt.splitright = true
end
keymap("n", "<leader><M-\\>", "<Cmd>lua SplitLeft()<CR>")

-- split above
SplitAbove = function()
  vim.opt.splitbelow = false
  vim.cmd "split"
  vim.opt.splitbelow = true
end
keymap("n", "<leader><M-->", "<Cmd>lua SplitAbove()<CR>")

keymap("n", "<leader>=", "<C-w>=") -- make split windows equal width & height
keymap("n", "<leader>xy", "<Cmd>close<CR>", { silent = true }) -- close current split window
-- buffers management
-- keymap("n", "<M-S-l>", "<Cmd>bnext<CR>", { silent = true }) -- override by byfferline plugin
-- keymap("n", "<M-S-h>", "<Cmd>bprevious<CR>", { silent = true }) -- override by byfferline plugin
keymap("n", "gp", "<Cmd>bprevious<CR>", { silent = true })
keymap("n", "gn", "<Cmd>bnext<CR>", { silent = true })
-- tabs management
keymap("n", "<leader>o", "<Cmd>tab ball<CR>", { silent = true }) -- open all buffers in tab
keymap("n", "<leader><Left>", "<Cmd>tabprevious<CR>", { silent = true })
keymap("n", "<leader><Right>", "<Cmd>tabnext<CR>", { silent = true })
keymap("n", "<leader>tp", "<Cmd>tabprevious<CR>", { silent = true })
keymap("n", "<leader>tn", "<Cmd>tabnext<CR>", { silent = true })
keymap("n", "<leader>th", "<Cmd>tabfirst<CR>", { silent = true })
keymap("n", "<leader>tl", "<Cmd>tablast<CR>", { silent = true })
keymap("n", "<leader>te", "<Cmd>tabedit<Space>", { silent = true })
keymap("n", "<leader>tc", "<Cmd>tabnew<CR>", { silent = true }) -- open new tab
keymap("n", "<leader>tm", "<Cmd>tabmove<Space>", { silent = true })
keymap("n", "<leader>tmp", "<Cmd>-tabmove<CR>", { silent = true }) -- move current tab left
keymap("n", "<leader>tmn", "<Cmd>+tabmove<CR>", { silent = true }) -- move current tab right
keymap("n", "<leader>tx", "<Cmd>tabclose<CR>", { silent = true }) -- close current tab
keymap("n", "<leader>to", "<Cmd>tabonly<CR>", { silent = true })
-- Switch to last tab
vim.cmd [[
if !exists('g:lasttab')
  let g:lasttab = 1
endif
autocmd TabLeave * let g:lasttab = tabpagenr()
]]
keymap("n", "<leader>tt", "<Cmd>exe 'tabn '.g:lasttab<CR>", { silent = true }) -- switch to last tab
-- keymap("n", "gz", "<Cmd>bdelete<CR>", { silent = true }) -- override keymap by bufdelete plugin

-- Toggle spell checking
keymap("n", "<leader>ssa", "<Cmd>setlocal spell! spelllang=en_us,ru_yo<CR>", { silent = true })
keymap("n", "<leader>sse", "<Cmd>setlocal spell! spelllang=en_us<CR>", { silent = true })
keymap("n", "<leader>ssr", "<Cmd>setlocal spell! spelllang=ru_yo<CR>", { silent = true })

-- Toggle show non-visible white spaces
keymap("n", "<leader>ll", "<Cmd>set list!<CR>", { silent = true })

-- Remove duplicate lines (leave only the last occurrence)
keymap(
  "n",
  "<leader>rd",
  "<Cmd>g/^\\(.*\\)\\ze\\n\\%(.*\\n\\)*\\1$/d<CR>",
  { silent = true, desc = "Remove duplicarte lines" }
)

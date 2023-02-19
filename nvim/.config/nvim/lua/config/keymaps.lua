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
keymap("c", "w!!", "execute 'silent! write !sudo tee % >/dev/null' <bar> edit!")
-- clear search highlights
keymap("n", "<leader>/", "<Cmd>nohlsearch<CR>")
keymap("n", "<Esc><Esc>", "<Cmd>nohlsearch<CR>")

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
keymap("n", "<leader>xy", "<Cmd>close<CR>") -- close current split window
-- buffers management
keymap("n", "<M-S-l>", "<Cmd>bnext<CR>")
keymap("n", "<M-S-h>", "<Cmd>bprevious<CR>")
keymap("n", "<M-S-k>", "<Cmd>tabnext<CR>")
keymap("n", "<M-S-j>", "<Cmd>tabprevious<CR>")
keymap("n", "gp", "<Cmd>bprevious<CR>")
keymap("n", "gn", "<Cmd>bnext<CR>")
-- tabs management
keymap("n", "<leader>o", "<Cmd>tab ball<CR>", { desc = "Open all buffers in separate tabs" })
keymap("n", "<leader><Left>", "<Cmd>tabprevious<CR>", { desc = "Previous tab" })
keymap("n", "<leader><Right>", "<Cmd>tabnext<CR>", { desc = "Next tab" })
keymap("n", "<leader>tp", "<Cmd>tabprevious<CR>", { desc = "Previous tab" })
keymap("n", "<leader>tn", "<Cmd>tabnext<CR>", { desc = "Next tab" })
keymap("n", "<leader>th", "<Cmd>tabfirst<CR>", { desc = "First tab" })
keymap("n", "<leader>tl", "<Cmd>tablast<CR>", { desc = "Last tab" })
keymap("n", "<leader>te", ":tabedit<Space>", { desc = "Tab .. N" })
keymap("n", "<leader>tc", "<Cmd>tabnew<CR>", { desc = "Open new tab" })
keymap("n", "<leader>tm", ":tabmove<Space>", { desc = "Move tab to position .. N" })
keymap("n", "<leader>tmp", "<Cmd>-tabmove<CR>", { desc = "Move current tab left" })
keymap("n", "<leader>tmn", "<Cmd>+tabmove<CR>", { desc = "Move current tab right" })
keymap("n", "<leader>tx", "<Cmd>tabclose<CR>", { desc = "Close current tab" })
keymap("n", "<leader>tz", "<Cmd>tabonly<CR>", { desc = "Close all tabs except the current one" })
-- Switch to last tab
vim.cmd [[
if !exists('g:lasttab')
  let g:lasttab = 1
endif
autocmd TabLeave * let g:lasttab = tabpagenr()
]]
keymap("n", "<leader>tt", "<Cmd>exe 'tabn '.g:lasttab<CR>", { desc = "Switch to last tab" })
-- keymap("n", "gz", "<Cmd>bdelete<CR>") -- overriden by bufdelete plugin

-- Toggle spell checking
--stylua: ignore
keymap("n", "<leader>sca", "<Cmd>setlocal spell! spelllang=en_us,ru_yo<CR>", { desc = "Toggle spellcheck All" })
--stylua: ignore
keymap("n", "<leader>sce", "<Cmd>setlocal spell! spelllang=en_us<CR>", { desc = "Toggle spellcheck English" })
--stylua: ignore
keymap("n", "<leader>scr", "<Cmd>setlocal spell! spelllang=ru_yo<CR>", { desc = "Toggle spellcheck Russian" })

-- Toggle show non-visible white spaces
keymap("n", "<leader>ll", "<Cmd>set list!<CR>")

-- Remove duplicate lines (leave only the last occurrence)
keymap(
  "n",
  "<leader>rd",
  "<Cmd>g/^\\(.*\\)\\ze\\n\\%(.*\\n\\)*\\1$/d<CR>",
  { desc = "Remove duplicate lines, keep last occurrence" }
)

keymap("n", "<leader>e", "<Cmd>edit<CR>")

-- Jump to closed folds
vim.cmd [[
  function! NextClosedFold(dir)
  let cmd = 'norm!z'..a:dir
  let view = winsaveview()
  let [l0, l, open] = [0, view.lnum, 1]
  while l != l0 && open
      exe cmd
      let [l0, l] = [l, line('.')]
      let open = foldclosed(l) < 0
  endwhile
  if open
      call winrestview(view)
  endif
  endfunction

  function! RepeatCmd(cmd) range abort
      let n = v:count < 1 ? 1 : v:count
      while n > 0
          exe a:cmd
          let n -= 1
      endwhile
  endfunction
]]

--stylua: ignore
vim.keymap.set("n", "zj", ":<c-u>call RepeatCmd('call NextClosedFold(\"j\")')<cr>", { silent = true })
--stylua: ignore
vim.keymap.set("n", "zk", ":<c-u>call RepeatCmd('call NextClosedFold(\"k\")')<cr>", { silent = true })

vim.keymap.set(
  "n",
  "<leader><Tab>",
  "<Cmd>lua ToggleTabSwitcherMode()<CR>",
  { desc = "Toggle Tab switcher mode." }
)
vim.keymap.set(
  "n",
  "<leader><leader>rn",
  "<Cmd>call ToggleSmartRelativenumbers()<CR>",
  { desc = "Toggle smart relative numbers." }
)

-- Toggle word wrap for current buffer
vim.keymap.set(
  "n",
  "<leader>ww",
  "<Cmd>setlocal wrap!<CR> <bar> <Cmd>echo 'wordwrap!'<CR>",
  { desc = "Toggle visual wrapping of long lines." }
)
-- Toggle wrap at textwidth column
vim.keymap.set(
  "n",
  "<leader>aw",
  "<Cmd>call AutoWrapToggle()<CR> <bar> <Cmd>echo 'autowrap!'<CR>",
  { desc = "Toggle automatic wrapping of long lines." }
)

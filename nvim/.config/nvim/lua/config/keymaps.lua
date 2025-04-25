-- Remap for dealing with word wrap
vim.keymap.set({ "n", "v" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true })
vim.keymap.set({ "n", "v" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true })

-- Better viewing
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")
vim.keymap.set("n", "g,", "g,zvzz")
vim.keymap.set("n", "g;", "g;zvzz")
vim.keymap.set("n", "<C-d>", "<C-d>zvzz")
vim.keymap.set("n", "<C-u>", "<C-u>zvzz")

-- Add undo break-points
vim.keymap.set("i", ",", "<c-g>u,")
vim.keymap.set("i", ".", "<c-g>u.")
vim.keymap.set("i", ";", "<c-g>u;")
vim.keymap.set("i", ":", "<c-g>u:")

-- Move Lines vertically (use mini.move instead)
-- vim.keymap.set("n", "<A-j>", ":m .+1<CR>==")
-- vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv")
-- vim.keymap.set("i", "<A-j>", "<Esc>:m .+1<CR>==gi")
-- vim.keymap.set("n", "<A-k>", ":m .-2<CR>==")
-- vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv")
-- vim.keymap.set("i", "<A-k>", "<Esc>:m .-2<CR>==gi")

-- Resize window using <shift> arrow keys
vim.keymap.set("n", "<S-Up>", "<cmd>resize +2<CR>")
vim.keymap.set("n", "<S-Down>", "<cmd>resize -2<CR>")
vim.keymap.set("n", "<S-Left>", "<cmd>vertical resize -2<CR>")
vim.keymap.set("n", "<S-Right>", "<cmd>vertical resize +2<CR>")

---------------------
-- General Keymaps
---------------------

-- Save file as sudo on files that require root permission
vim.keymap.set("c", "w!!", "execute 'silent! write !sudo tee % >/dev/null' <bar> edit!")
-- clear search highlights
vim.keymap.set("n", "<Esc><Esc>", "<Cmd>nohlsearch<CR>")

-- paste over without overwriting register
vim.cmd [[
  xnoremap <expr> p 'pgv"'.v:register.'y'
]]

-- send changed text segment to black hole
vim.keymap.set({ "n", "v" }, "c", '"_c')
vim.keymap.set({ "n", "v" }, "C", '"_C')

-- window management
vim.keymap.set("n", "<leader>\\", "<C-w>v") -- split window vertically
vim.keymap.set("n", "<leader>-", "<C-w>s") -- split window horizontally

-- split left
SplitLeft = function()
  vim.opt.splitright = false
  vim.cmd "vsplit"
  vim.opt.splitright = true
end
vim.keymap.set("n", "<leader><M-\\>", "<Cmd>lua SplitLeft()<CR>")

-- split above
SplitAbove = function()
  vim.opt.splitbelow = false
  vim.cmd "split"
  vim.opt.splitbelow = true
end
vim.keymap.set("n", "<leader><M-->", "<Cmd>lua SplitAbove()<CR>")

vim.keymap.set("n", "<leader>=", "<C-w>=") -- make split windows equal width & height
vim.keymap.set("n", "<leader>xy", "<Cmd>close<CR>") -- close current split window
-- buffers management
vim.keymap.set("n", "<M-S-l>", "<Cmd>bnext<CR>")
vim.keymap.set("n", "<M-S-h>", "<Cmd>bprevious<CR>")
vim.keymap.set("n", "<M-S-k>", "<Cmd>tabnext<CR>")
vim.keymap.set("n", "<M-S-j>", "<Cmd>tabprevious<CR>")
vim.keymap.set("n", "gp", "<Cmd>bprevious<CR>")
vim.keymap.set("n", "gn", "<Cmd>bnext<CR>")
-- tabs management
vim.keymap.set(
  "n",
  "<leader>ta",
  "<Cmd>tab ball<CR>",
  { desc = "Open all buffers in separate tabs" }
)
vim.keymap.set("n", "<leader><Left>", "<Cmd>tabprevious<CR>", { desc = "Previous tab" })
vim.keymap.set("n", "<leader><Right>", "<Cmd>tabnext<CR>", { desc = "Next tab" })
vim.keymap.set("n", "<leader>tp", "<Cmd>tabprevious<CR>", { desc = "Previous tab" })
vim.keymap.set("n", "<leader>tn", "<Cmd>tabnext<CR>", { desc = "Next tab" })
vim.keymap.set("n", "<leader>th", "<Cmd>tabfirst<CR>", { desc = "First tab" })
vim.keymap.set("n", "<leader>tl", "<Cmd>tablast<CR>", { desc = "Last tab" })
vim.keymap.set("n", "<leader>te", ":tabedit<Space>", { desc = "Tab .. N" })
vim.keymap.set("n", "<leader>tc", "<Cmd>tabnew<CR>", { desc = "Open new tab" })
vim.keymap.set("n", "<leader>tm", ":tabmove<Space>", { desc = "Move tab to position .. N" })
vim.keymap.set("n", "<leader>tmp", "<Cmd>-tabmove<CR>", { desc = "Move current tab left" })
vim.keymap.set("n", "<leader>tmn", "<Cmd>+tabmove<CR>", { desc = "Move current tab right" })
vim.keymap.set("n", "<leader>tx", "<Cmd>tabclose<CR>", { desc = "Close current tab" })
vim.keymap.set(
  "n",
  "<leader>tz",
  "<Cmd>tabonly<CR>",
  { desc = "Close all tabs except the current one" }
)
-- Switch to last tab
vim.cmd [[
if !exists('g:lasttab')
  let g:lasttab = 1
endif
autocmd TabLeave * let g:lasttab = tabpagenr()
]]
vim.keymap.set(
  "n",
  "<leader>tt",
  "<Cmd>exe 'tabn '.g:lasttab<CR>",
  { desc = "Switch to last tab" }
)
-- vim.keymap.set("n", "gz", "<Cmd>bdelete<CR>") -- overriden by bufdelete plugin

-- Toggle spell checking
--stylua: ignore
vim.keymap.set("n", "<leader>sca", "<Cmd>setlocal spell! spelllang=en_us,ru_yo<CR>", { desc = "Toggle spellcheck All" })
--stylua: ignore
vim.keymap.set("n", "<leader>sce", "<Cmd>setlocal spell! spelllang=en_us<CR>", { desc = "Toggle spellcheck English" })
--stylua: ignore
vim.keymap.set("n", "<leader>scr", "<Cmd>setlocal spell! spelllang=ru_yo<CR>", { desc = "Toggle spellcheck Russian" })

-- Toggle show non-visible white spaces
vim.keymap.set("n", "<leader>ll", "<Cmd>set list!<CR>")

-- Remove duplicate lines (leave only the last occurrence)
vim.keymap.set(
  "n",
  "<leader>rd",
  "<Cmd>g/^\\(.*\\)\\ze\\n\\%(.*\\n\\)*\\1$/d<CR>",
  { desc = "Remove duplicate lines, keep last occurrence" }
)

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
vim.keymap.set("n", "zJ", ":<c-u>call RepeatCmd('call NextClosedFold(\"j\")')<cr>", { silent = true })
--stylua: ignore
vim.keymap.set("n", "zK", ":<c-u>call RepeatCmd('call NextClosedFold(\"k\")')<cr>", { silent = true })

-- Insert empty line above/below (functions from vim-unimpaired)
vim.cmd [[
function! UnimpairedBlankUp() abort
  let cmd = 'put!=repeat(nr2char(10), v:count1)|silent '']+'
  if &modifiable
    let cmd .= '|silent! call repeat#set("\<Plug>(unimpaired-blank-up)", v:count1)'
  endif
  return cmd
endfunction

function! UnimpairedBlankDown() abort
  let cmd = 'put =repeat(nr2char(10), v:count1)|silent ''[-'
  if &modifiable
    let cmd .= '|silent! call repeat#set("\<Plug>(unimpaired-blank-down)", v:count1)'
  endif
  return cmd
endfunction
]]
vim.keymap.set("n", "[<Space>", ":<C-U>exe UnimpairedBlankUp()<CR>")
vim.keymap.set("n", "]<Space>", ":<C-U>exe UnimpairedBlankDown()<CR>")

vim.keymap.set(
  "n",
  "<leader><Tab>",
  "<Cmd>lua ToggleTabSwitcherMode()<CR>",
  { desc = "Toggle Tab switcher mode." }
)
vim.keymap.set("n", "<leader><leader>rn", function()
  ToggleSmartRelativenumbers()
end, { desc = "Toggle smart relative numbers." })

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

-- Auto Indent the Current Empty Line
vim.keymap.set("n", "i", function()
  if #vim.fn.getline "." == 0 then
    return [["_cc]]
  else
    return "i"
  end
end, { expr = true })

-- Copy current file name/full path/dir name/dir path
vim.cmd [[
  command! CopyFileName let @+ = expand("%:t")
  command! CopyFilePath let @+ = expand("%:p")
  command! CopyFileRelPath let @+ = (expand("%:h") . "/" . expand("%:t"))
  command! CopyDirName let @+ = expand("%:h:t")
  command! CopyDirPath let @+ = expand("%:p:h")
  command! CopyDirRelPath let @+ = expand("%:h")
]]
vim.keymap.set(
  "n",
  "<leader>cpfn",
  "<Cmd>CopyFileName<CR>",
  { noremap = true, silent = true, desc = "Name only" }
)
vim.keymap.set(
  "n",
  "<leader>cpfp",
  "<Cmd>CopyFilePath<CR>",
  { noremap = true, silent = true, desc = "Full path" }
)
vim.keymap.set(
  "n",
  "<leader>cpfr",
  "<Cmd>CopyFileRelPath<CR>",
  { noremap = true, silent = true, desc = "Relative path" }
)
vim.keymap.set(
  "n",
  "<leader>cpdn",
  "<Cmd>CopyDirName<CR>",
  { noremap = true, silent = true, desc = "Name only" }
)
vim.keymap.set(
  "n",
  "<leader>cpdp",
  "<Cmd>CopyDirPath<CR>",
  { noremap = true, silent = true, desc = "Full path" }
)
vim.keymap.set(
  "n",
  "<leader>cpdr",
  "<Cmd>CopyDirRelPath<CR>",
  { noremap = true, silent = true, desc = "Relative path" }
)

-- pastetoggle option is deprecated in 0.10.0
vim.keymap.set("n", "<F4>", [[:set paste!<CR>:set paste?<CR>]], { noremap = true, silent = true })

-- append empty line above
-- stylua: ignore
vim.keymap.set({ "n", "i" }, "<M-CR>", "<Cmd>call append(line('.') - 1, repeat([''], v:count1))<CR>")

-- Blazingly fast macros!
-- (https://www.reddit.com/r/neovim/comments/1cgoz22/blazingly_fast_macros)
vim.cmd [[
  nnoremap @ <Cmd>set lazyredraw <bar> execute "noautocmd norm! " . v:count1 . "@" . getcharstr() <bar> set nolazyredraw<CR>
  xnoremap @ :<C-U>set lazyredraw <bar> execute "noautocmd '<,'>norm! " . v:count1 . "@" . getcharstr()<bar> set nolazyredraw<CR>
  nnoremap Q <Cmd>set lazyredraw <bar> execute "noautocmd norm! Q" <bar> set nolazyredraw<cr>
  xnoremap Q :<C-U>set lazyredraw <bar> execute "noautocmd '<,'>norm! Q" <bar> set nolazyredraw<cr>
]]

-- Yank the line on `dd` only if it is non-empty
vim.keymap.set("n", "dd", function()
  if vim.fn.getline("."):match "^%s*$" then
    return '"_dd'
  end
  return "dd"
end, { expr = true })

-- Dot "." command in visual mode
vim.keymap.set("x", ".", ":norm .<CR>", { silent = false })
-- Execute "q" macro in visual mode
vim.keymap.set("x", "@", ":norm @q<CR>", { silent = false })

-- Cmd line navigation
vim.cmd [[set cedit=<C-y>]]
vim.keymap.set("c", "<C-a>", "<Home>", { desc = "move to start" })
vim.keymap.set("c", "<M-^>", "<Home>", { desc = "move to start" })
vim.keymap.set("c", "<C-b>", "<Left>", { desc = "move left" })
vim.keymap.set("c", "<M-h>", "<Left>", { desc = "move left" })
vim.keymap.set("c", "<C-d>", "<Del>", { desc = "delete" })
vim.keymap.set("c", "<C-e>", "<End>", { desc = "move to end" })
vim.keymap.set("c", "<M-$>", "<End>", { desc = "move to end" })
vim.keymap.set("c", "<C-f>", "<Right>", { desc = "move right" })
vim.keymap.set("c", "<M-l>", "<Right>", { desc = "move right" })
vim.keymap.set("c", "<C-n>", "<Down>", { desc = "next history byprefix" })
vim.keymap.set("c", "<M-j>", "<Down>", { desc = "next history byprefix" })
vim.keymap.set("c", "<C-p>", "<Up>", { desc = "prev history byprefix" })
vim.keymap.set("c", "<M-k>", "<Up>", { desc = "prev history byprefix" })
vim.keymap.set("c", "<M-n>", "<S-Down>", { desc = "next history" })
vim.keymap.set("c", "<M-J>", "<S-Down>", { desc = "next history" })
vim.keymap.set("c", "<M-p>", "<S-Up>", { desc = "prev history" })
vim.keymap.set("c", "<M-K>", "<S-Up>", { desc = "prev history" })
vim.keymap.set("c", "<M-b>", "<S-Left>", { desc = "move to prev word" })
vim.keymap.set("c", "<M-b>", "<S-Left>", { desc = "move to prev word" })
vim.keymap.set("c", "<M-f>", "<S-Right>", { desc = "move to next word" })
vim.keymap.set("c", "<M-w>", "<S-Right>", { desc = "move to next word" })

vim.keymap.set("n", "::", "<Cmd>update<CR>", { desc = "Save file if it was changed" })

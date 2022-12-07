-- NERDTree
vim.cmd([[
  let NERDTreeShowBookmarks=1
  let NERDTreeShowHidden=1
  let NERDTreeChDirMode=0
  let NERDTreeQuitOnOpen=1
  let NERDTreeKeepTreeInNewTab=1
  let NERDTreeIgnore=['\\.swo$', '\\.swp$', '\\.git', '\\.pyc$', '\\.vim$',
    \ '\\~$', '\\.venv$', '.DS_Store']

  augroup NERDTreeCloseOnVimLeave
      autocmd VimLeavePre * :tabdo NERDTreeClose
  augroup end
]])

vim.g.NERDTreeIndicatorMapCustom = {
  Modified = "M",
  Staged = "S",
  Untracked = "*",
  Renamed = "R",
  Unmerged = "U",
  Deleted = "!",
  Dirty = "D",
  Clean = "C",
  Ignored = "I",
  Unknown = "?",
}

-- vim.g.NERDTreeMapCloseDir = "h"
-- vim.g.NERDTreeMapActivateNode = "l"

local keymap = vim.keymap
keymap.set("n", "<F2>", ":NERDTreeToggle<CR>")
keymap.set("n", "<leader><F2>", ":NERDTreeFind<cr>")

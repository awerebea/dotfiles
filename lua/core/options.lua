local opt = vim.opt -- for conciseness
local keymap = vim.keymap -- for conciseness

-- line numbers
opt.relativenumber = true -- show relative line numbers
opt.number = true -- shows absolute line number on cursor line (when relative number is on)

-- line wrapping
opt.wrap = false -- disable line wrapping

-- search settings
opt.ignorecase = true -- ignore case when searching
opt.smartcase = true -- if you include mixed case in your search, assumes you want case-sensitive

-- cursor line
opt.cursorline = true -- highlight the current cursor line

-- appearance

-- turn on termguicolors for colorscheme to work
-- (have to use iterm2 or any other true color terminal)
opt.termguicolors = true
opt.background = "dark" -- colorschemes that can be light or dark will be made dark
opt.signcolumn = "yes" -- show sign column so that text doesn't shift

-- backspace
opt.backspace = "indent,eol,start" -- allow backspace on indent, end of line or insert mode start position

-- clipboard
opt.clipboard:append("unnamedplus") -- use system clipboard as default register

-- split windows
opt.splitright = true -- split vertical window to the right
opt.splitbelow = true -- split horizontal window to the bottom

opt.iskeyword:append("-") -- consider string-string as whole word

-- Show non-visible white spaces
vim.opt.list = true
vim.opt.listchars:append("eol:¬,tab:▸—,trail:~,extends:»,precedes:«,space:·")

-- {{{ Backup, Undo and Swap files settings
-- Save your backup files to a less annoying place than the current directory.
-- Default location of backup files is ~/.local/state/nvim/backup
opt.backup = true
opt.backupdir:remove(".")
opt.backupdir:append(".")

-- Default location of swap files (echo &directory) is ~/.local/state/nvim/swap
opt.swapfile = true
opt.updatecount = 100

-- Viminfo stores the the state of your previous editing session
opt.viminfo:append("n" .. os.getenv("HOME") .. "/.local/state/nvim/nviminfo")

-- Save undo history of edited files.
-- Default files location: ~/.local/state/nvim/undo
opt.undofile = true

-- Default location of viewdir is ~/.local/state/nvim/view
-- }}}

-- {{{ tabs (indentation) settings
-- tabs & indentation
opt.tabstop = 2 -- 2 spaces for tabs (prettier default)
opt.shiftwidth = 2 -- 2 spaces for indent width
opt.expandtab = true -- expand tab to spaces
opt.autoindent = true -- copy indent from current line when starting new one

vim.cmd([[
function! TabsNoExpandByFourSpaces()
  setlocal tabstop=4
  setlocal shiftwidth=4
  setlocal softtabstop=4
  setlocal noexpandtab
endfunction
command! TabsNoExpandByFourSpaces call TabsNoExpandByFourSpaces()

function! TabsExpandByFourSpaces()
  setlocal tabstop=4
  setlocal shiftwidth=4
  setlocal softtabstop=4
  setlocal expandtab
endfunction
command! TabsNoExpandByFourSpaces call TabsExpandByFourSpaces()

function! TabsExpandByTwoSpaces()
  setlocal tabstop=2
  setlocal shiftwidth=2
  setlocal softtabstop=2
  setlocal expandtab
endfunction
command! TabsExpandByTwoSpaces call TabsExpandByTwoSpaces()

set noexpandtab
augroup filetypeRelatedSettings
  autocmd!
  autocmd BufRead,BufNewFile Chart.yaml set ft=helm
  autocmd BufRead,BufNewFile .yamllint set ft=yaml
  autocmd FileType bash,sh,json*,dockerfile,python,cmake
    \ setlocal tabstop=4 softtabstop=4 shiftwidth=4 expandtab
  autocmd FileType javascript,c,make,cpp,**/cpp.snippets,gitignore,gitconfig
    \ setlocal tabstop=4 softtabstop=4 shiftwidth=4 noexpandtab
  autocmd FileType vim,zsh,tmux,conf,nginx,ruby,gitcommit,yaml,yaml.ansible,helm
    \ setlocal tabstop=2 softtabstop=2 shiftwidth=2 expandtab
augroup END
]])
-- }}}

-- {{{ Tabs navigation
opt.switchbuf = "usetab,newtab"

-- Smart buffers/tabs switch
vim.cmd([[
let s:tab_switcher_mode="buffers"
nnoremap <Tab> :bnext<CR>
nnoremap <S-Tab> :bprevious<CR>
function! ToggleTabSwitcherMode()
  if s:tab_switcher_mode == "buffers"
    nnoremap <Tab> :tabnext<CR>
    nnoremap <S-Tab> :tabprevious<CR>
    let s:tab_switcher_mode="tabs"
    echo "Switch tabs"
  else
    nnoremap <Tab> :bnext<CR>
    nnoremap <S-Tab> :bprevious<CR>
    let s:tab_switcher_mode="buffers"
    echo "Switch buffers"
  endif
endfunction
nnoremap <silent> <leader><Tab> :call ToggleTabSwitcherMode()<CR>
]])
-- }}}

-- {{{ toggle relativenumber
vim.cmd([[
augroup SmartRelativenumbers
  autocmd!
  autocmd InsertEnter * :set norelativenumber
  autocmd InsertLeave * :set relativenumber
  autocmd BufLeave * :set norelativenumber
  autocmd BufEnter * :set relativenumber
augroup END

function! ToggleSmartRelativenumbers()
  if !exists('#SmartRelativenumbers#InsertEnter')
    set relativenumber
    augroup SmartRelativenumbers
      autocmd!
      autocmd InsertEnter * :set norelativenumber
      autocmd InsertLeave * :set relativenumber
      autocmd BufLeave * :set norelativenumber
      autocmd BufEnter * :set relativenumber
    augroup END
else
    set relativenumber!
    augroup SmartRelativenumbers
      autocmd!
    augroup END
  endif
endfunction
]])
keymap.set("n", "<leader><leader>rn", ":call ToggleSmartRelativenumbers()<CR>", { noremap = true })
-- }}}

-- misc
opt.showcmd = true
opt.laststatus = 3

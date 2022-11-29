local opt = vim.opt -- for conciseness
local keymap = vim.keymap -- for conciseness

-- delete single character without copying into register (in visual mode only)
keymap.set("v", "x", '"_x')
-- send changed text segment to blackhole
keymap.set({ "n", "v" }, "c", '"_c')
keymap.set({ "n", "v" }, "C", '"_C')

-- line numbers
opt.relativenumber = true -- show relative line numbers
opt.number = true -- shows absolute line number on cursor line (when relative number is on)

-- always show minimum n lines after current line
opt.scrolloff = 5

-- hide "-- INSERT --" text in status
vim.cmd("set noshowmode")

-- {{{ Wildmenu completion
opt.wildmenu = true
opt.wildmode = "full"

opt.wildignore:append(".hg,.git,.svn") -- Version control
opt.wildignore:append("*.aux,*.out,*.toc") -- LaTeX intermediate files
opt.wildignore:append("*.jpg,*.bmp,*.gif,*.png,*.jpeg") -- binary images
opt.wildignore:append("*.o,*.obj,*.exe,*.dll,*.manifest") -- compiled object files
opt.wildignore:append("*.spl") -- compiled spelling word list
opt.wildignore:append("*.sw?") -- Vim swap files
opt.wildignore:append("*.DS_Store") -- OSX bullshit
opt.wildignore:append("*.luac") -- Lua byte code
opt.wildignore:append("migrations") -- Django migrations
opt.wildignore:append("go/pkg") -- Go static files
opt.wildignore:append("go/bin") -- Go bin files
opt.wildignore:append("go/bin-vagrant") -- Go bin-vagrant files
opt.wildignore:append("*.pyc") -- Python byte code
opt.wildignore:append("*.orig") -- Merge resolution files
-- }}}

-- line wrapping
opt.wrap = false -- disable line wrapping

-- search settings
opt.ignorecase = true -- ignore case when searching
opt.smartcase = true -- if you include mixed case in your search, assumes you want case-sensitive

-- highlight the current cursor line
opt.cursorline = false

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
opt.viminfo = { "!,'1000,<1000,s200,h" } -- Increasing the buffer size
opt.viminfo:append("n" .. os.getenv("HOME") .. "/.local/state/nvim/nviminfo")

-- Save undo history of edited files.
-- Default files location: ~/.local/state/nvim/undo
opt.undofile = true
opt.undolevels = 2048
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
nnoremap gn             :silent bnext<CR>
nnoremap gp             :silent bprevious<CR>
function! ToggleTabSwitcherMode()
  if s:tab_switcher_mode == "buffers"
    nnoremap gn             :silent tabnext<CR>
    nnoremap gp             :silent tabprevious<CR>
    let s:tab_switcher_mode="tabs"
    echo "Switch tabs"
  else
    nnoremap gn             :silent bnext<CR>
    nnoremap gp             :silent bprevious<CR>
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

-- {{{ Word wrap
opt.textwidth = 99
opt.wrapmargin = 0
opt.colorcolumn = "+1"
opt.wrap = true
opt.linebreak = false
vim.cmd([[
function! AutoWrapToggle()
  if &formatoptions =~ 't'
    setlocal textwidth=0
    setlocal fo-=t
    setlocal colorcolumn=
  else
    if (&filetype=='python')
      setlocal textwidth=99
    else
      setlocal textwidth=99
    endif
    setlocal fo+=t
    setlocal colorcolumn=+1
  endif
endfunction
]])
-- Toggle word wrap for current buffer
keymap.set("n", "<leader>ww", ":setlocal wrap!<CR>")
-- Toggle wrap at 80 column
keymap.set("n", "<leader>aw", ":call AutoWrapToggle()<CR>")
-- }}}

-- {{{ Auto save/load view
-- List of filenames to skip mkview
vim.g.skipview_files = { "EXAMPLE", "PLUGIN", "BUFFER", "COMMIT_EDITMSG", "git-rebase-todo" }
vim.cmd([[
function! MakeViewCheck()
    if has('quickfix') && &buftype =~ 'nofile'
        " Buffer is marked as not a file
        return 0
    endif
    if empty(glob(expand('%:p')))
        " File does not exist on disk
        return 0
    endif
    if expand('%:p:h') == "/tmp"
        " We're in a temp dir
        return 0
    endif
    if expand('%:p:h') == "/var/tmp"
        " Also in temp dir
        return 0
    endif
    if index(g:skipview_files, expand("%:t")) >= 0
        " File is in skip list
        return 0
    endif
    return 1
endfunction
augroup vimrcAutoView
    autocmd!
    " Autosave & Load Views.
    autocmd BufWritePost,BufLeave,WinLeave ?* if MakeViewCheck() | mkview | endif
    autocmd BufWinEnter ?* if MakeViewCheck() | silent! loadview | endif
augroup end
]])
-- }}}

-- Change cursor view:
opt.guicursor = "n-v-c-sm:block,i-ci-ve:ver25-Cursor,r-cr-o:hor20,a:blinkon1"

-- misc
opt.showcmd = true
opt.laststatus = 3
opt.autoindent = true
opt.pastetoggle = "<F4>"
opt.whichwrap:append("<,>,[,]")

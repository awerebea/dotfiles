local opt = vim.opt -- for conciseness
local keymap = vim.keymap -- for conciseness

-- send changed text segment to black hole
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

-- opt.iskeyword:append("-") -- consider string-string as whole word

-- Show non-visible white spaces
vim.opt.list = true
vim.opt.listchars:append("eol:¬,tab:▸—,trail:~,extends:»,precedes:«,space:·")

-- {{{ Backup, Undo and Swap files settings
-- Save your backup files to a less annoying place than the current directory.
-- Default location of backup files is ~/.local/state/nvim/backup
opt.backup = true
opt.backupdir:remove(".")
opt.backupdir:append(".")
-- Try to create a backup directory in the default location if it doesn't exist
vim.cmd([[
  if !isdirectory($HOME."/.local/state/nvim/backup")
    try
      silent call mkdir ($HOME."/.local/state/nvim/backup", "p")
    catch
    endtry
  endif
]])

-- Default location of swap files (echo &directory) is ~/.local/state/nvim/swap
opt.swapfile = true
opt.updatecount = 100

-- Viminfo stores the state of your previous editing session
opt.viminfo = { "!,'1000,<1000,s200,h" } -- Increasing the buffer size
opt.viminfo:append("n" .. os.getenv("HOME") .. "/.local/state/nvim/nviminfo")
opt.sessionoptions:remove({ "folds" })
-- Save undo history of edited files.
-- Default files location: ~/.local/state/nvim/undo
opt.undofile = true
opt.undolevels = 2048
-- Default location of viewdir is ~/.local/state/nvim/view
opt.viewoptions:remove({ "folds" })
-- }}}

-- {{{ spell check
-- opt.spelllang = "en_us"
-- opt.spell = true
-- opt.spellfile:append(os.getenv("HOME") .. "/.config/nvim/spell/nvim-config.en.utf-8.add")

-- re-create spl files for additional vocabularies
vim.cmd([[
for d in glob('~/.config/nvim/spell/*.add', 1, 1)
  if filereadable(d) && (!filereadable(d . '.spl') || getftime(d) >
  \ getftime(d . '.spl'))
    exec 'mkspell! ' . fnameescape(d)
  endif
endfor
]])
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
  autocmd FileType vim,zsh,tmux,conf,nginx,ruby,gitcommit,yaml,yaml.ansible,helm,lua,hcl,terraform
    \ setlocal tabstop=2 softtabstop=2 shiftwidth=2 expandtab
augroup END
]])
-- }}}

-- {{{ Tabs navigation
opt.switchbuf = "usetab,newtab"

-- Smart buffers/tabs switch
local tab_switcher_mode = "buffers"
function ToggleTabSwitcherMode()
  if tab_switcher_mode == "buffers" then
    keymap.set("n", "<M-S-l>", "<Cmd>tabnext<CR>", { noremap = true, silent = true })
    keymap.set("n", "<M-S-h>", "<Cmd>tabprevious<CR>", { noremap = true, silent = true })
    tab_switcher_mode = "tabs"
    print("Switch tabs")
  else
    keymap.set("n", "<M-S-l>", "<Cmd>bnext<CR>", { noremap = true, silent = true })
    keymap.set("n", "<M-S-h>", "<Cmd>bprevious<CR>", { noremap = true, silent = true })
    tab_switcher_mode = "buffers"
    print("Switch buffers")
  end
end
keymap.set(
  "n",
  "<leader><Tab>",
  "<Cmd>lua ToggleTabSwitcherMode()<CR>",
  { silent = true, noremap = true }
)
-- }}}

-- {{{ toggle relativenumber
vim.cmd([[
augroup SmartRelativenumbers
  let blacklist = ["toggleterm"]
  autocmd!
  autocmd InsertEnter * if index(blacklist, &ft) < 0 | :setlocal norelativenumber | endif
  autocmd InsertLeave * if index(blacklist, &ft) < 0 | :setlocal relativenumber | endif
  autocmd BufLeave * if index(blacklist, &ft) < 0 | :setlocal norelativenumber | endif
  autocmd BufEnter * if index(blacklist, &ft) < 0 | :setlocal relativenumber | endif
augroup END

function! ToggleSmartRelativenumbers()
  if !exists('#SmartRelativenumbers#InsertEnter')
    set relativenumber
    augroup SmartRelativenumbers
      autocmd!
      autocmd InsertEnter * if index(blacklist, &ft) < 0 | :setlocal norelativenumber | endif
      autocmd InsertLeave * if index(blacklist, &ft) < 0 | :setlocal relativenumber | endif
      autocmd BufLeave * if index(blacklist, &ft) < 0 | :setlocal norelativenumber | endif
      autocmd BufEnter * if index(blacklist, &ft) < 0 | :setlocal relativenumber | endif
    augroup END
else
    set relativenumber!
    augroup SmartRelativenumbers
      autocmd!
    augroup END
  endif
endfunction
]])
keymap.set(
  "n",
  "<leader><leader>rn",
  "<Cmd>call ToggleSmartRelativenumbers()<CR>",
  { noremap = true }
)
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
keymap.set("n", "<leader>ww", "<Cmd>setlocal wrap!<CR>")
-- Toggle wrap at 80 column
keymap.set("n", "<leader>aw", "<Cmd>call AutoWrapToggle()<CR>")
-- }}}

-- {{{ Auto save/load view
-- List of filenames to skip mkview
vim.g.skipview_files =
  { "EXAMPLE", "PLUGIN", "BUFFER", "COMMIT_EDITMSG", "git-rebase-todo", "DiffviewFilePanel" }
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

-- Folding settings
-- zc fold block
-- zo unfold block
-- zM fold all blocks
-- zR unfold all blocks
-- za toggle folding
-- zf create manual fold, check :set foldmethod=manual
opt.foldmethod = "expr" -- "manual" for manual folds
opt.foldexpr = "nvim_treesitter#foldexpr()" -- use treesitter to generate folds
opt.foldcolumn = "2"
opt.foldlevel = 2 -- fold levels opened at file opens
opt.foldlevelstart = 99
-- opt.foldopen = "all" -- autoopen fold when enter it
opt.foldnestmax = 3 -- max level of fold

-- A way to delete 'mkview' for current file
vim.cmd([[
function! MyDeleteView()
  let path = fnamemodify(bufname('%'),':p')
  " vim's odd =~ escaping for /
  let path = substitute(path, '=', '==', 'g')
  if empty($HOME)
  else
    let path = substitute(path, '^'.$HOME, '\~', '')
  endif
  let path = substitute(path, '/', '=+', 'g') . '='
  " view directory
  let path = &viewdir.'/'.path
  call delete(path)
  echo "Deleted: ".path
  " re-open current file
  edit %
endfunction
command! Delview call MyDeleteView()
" Lower-case user commands: http://vim.wikia.com/wiki/Replace_a_builtin_command_using_cabbrev
cabbrev delview <c-r>=(getcmdtype()==':' && getcmdpos()==1 ? 'Delview' : 'delview')<CR>
]])

-- Toggle diff view for all visible windows
local diff_view_active = false
local opts = { noremap = true, silent = true }
function ToggleDiffViewMode()
  if diff_view_active then
    vim.cmd(":diffoff!")
    diff_view_active = false
    print("Diff view deactivated")
  else
    vim.cmd([[
    :NvimTreeClose
    :windo diffthis
    ]])
    diff_view_active = true
    print("Diff view activated")
  end
end
keymap.set("n", "<leader><F9>", "<Cmd>lua ToggleDiffViewMode()<CR>", opts)
keymap.set("n", "<leader>dg", "<Cmd>diffget<CR> <bar> :echo 'Get chunk'<CR>", opts)
keymap.set("n", "<leader>dp", "<Cmd>diffput<CR> <bar> :echo 'Put chunk'<CR>", opts)
-- }}}

-- Easily search and replace using quickfix window
vim.cmd([[
  function! QuickfixMapping()
    " Make the quickfix list modifiable and set errorformat
    setlocal errorformat+=%f\|%l\ col\ %c\|%m, modifiable
    " Go to the previous location and stay in the quickfix window
    nnoremap <buffer> K :cprev<CR>zz:cclose<CR>:copen<CR>
    " Go to the next location and stay in the quickfix window
    nnoremap <buffer> J :cnext<CR>zz:cclose<CR>:copen<CR>
    " Save the changes in the quickfix window
    cnoremap <buffer> w :cgetbuffer<CR>:cclose<CR>:copen<CR>
    " Begin the search and replace
    nnoremap <buffer> <leader>r :cdo s/// \| update<C-Left><C-Left><Left><Left><Left>
    " Open location and re-open quickfix window
    nnoremap <buffer> <CR> <CR>zz:cclose<CR>:copen<CR>
  endfunction

  augroup quickfix_group
      autocmd!
      autocmd BufWinEnter quickfix call QuickfixMapping()
  augroup END
]])

-- Highlight copied text
vim.cmd([[
  autocmd TextYankPost * silent! lua vim.highlight.on_yank { higroup="IncSearch", timeout=500 }
]])

-- misc
opt.showcmd = true
opt.laststatus = 3
opt.autoindent = true
opt.pastetoggle = "<F4>"
opt.whichwrap:append("<,>,[,]")
opt.mousemoveevent = true
opt.timeoutlen = 300
opt.signcolumn = "yes:2" -- Always show signcolumn, max width 2

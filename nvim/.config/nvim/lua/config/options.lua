-- line numbers
vim.opt.relativenumber = true -- show relative line numbers
vim.opt.number = true -- shows absolute line number on cursor line (when relative number is on)

-- always show minimum n lines after current line
vim.opt.scrolloff = 5
-- The minimal number of screen columns to keep to the left and to the right of the cursor if
-- 'nowrap' is set
vim.opt.sidescrolloff = 8

-- hide "-- INSERT --" text in status
vim.cmd "set noshowmode"

-- {{{ Wildmenu completion
vim.opt.wildmenu = true
-- vim.opt.wildmode = "full"
vim.opt.wildmode = "longest:full,full"

vim.opt.wildignore:append ".hg,.git,.svn" -- Version control
vim.opt.wildignore:append "*.aux,*.out,*.toc" -- LaTeX intermediate files
vim.opt.wildignore:append "*.jpg,*.bmp,*.gif,*.png,*.jpeg" -- binary images
vim.opt.wildignore:append "*.o,*.obj,*.exe,*.dll,*.manifest" -- compiled object files
vim.opt.wildignore:append "*.spl" -- compiled spelling word list
vim.opt.wildignore:append "*.sw?" -- Vim swap files
vim.opt.wildignore:append "*.DS_Store" -- OSX bullshit
vim.opt.wildignore:append "*.luac" -- Lua byte code
vim.opt.wildignore:append "migrations" -- Django migrations
vim.opt.wildignore:append "go/pkg" -- Go static files
vim.opt.wildignore:append "go/bin" -- Go bin files
vim.opt.wildignore:append "go/bin-vagrant" -- Go bin-vagrant files
vim.opt.wildignore:append "*.pyc" -- Python byte code
vim.opt.wildignore:append "*.orig" -- Merge resolution files
-- }}}

-- line wrapping
vim.opt.wrap = false -- disable line wrapping

-- search settings
vim.opt.ignorecase = true -- ignore case when searching
vim.opt.smartcase = true -- if you include mixed case in your search, assumes you want case-sensitive

-- highlight the current cursor line
vim.opt.cursorline = false

-- appearance

-- turn on termguicolors for colorscheme to work
-- (have to use iterm2 or any other true color terminal)
vim.opt.termguicolors = true
vim.opt.background = "dark" -- colorschemes that can be light or dark will be made dark
vim.opt.signcolumn = "yes:2" -- Always show signcolumn, max width 2

-- backspace
vim.opt.backspace = "indent,eol,start" -- allow backspace on indent, end of line or insert mode start position

-- clipboard
vim.opt.clipboard:append "unnamedplus" -- use system clipboard as default register

-- split windows
vim.opt.splitright = true -- split vertical window to the right
vim.opt.splitbelow = true -- split horizontal window to the bottom

-- vim.opt.iskeyword:append("-") -- consider string-string as whole word

-- Show non-visible white spaces
vim.opt.list = true
vim.opt.listchars:append "eol:¬,tab:▸—,trail:~,extends:»,precedes:«,space:·"

-- {{{ Backup, Undo and Swap files settings
-- Save your backup files to a less annoying place than the current directory.
-- Default location of backup files is ~/.local/state/nvim/backup
vim.opt.backup = true
vim.opt.backupdir:remove "."
vim.opt.backupdir:append "."
-- Try to create a backup directory in the default location if it doesn't exist
vim.cmd [[
  if !isdirectory($HOME."/.local/state/nvim/backup")
    try
      silent call mkdir ($HOME."/.local/state/nvim/backup", "p")
    catch
    endtry
  endif
]]

-- Default location of swap files (echo &directory) is ~/.local/state/nvim/swap
vim.opt.swapfile = true
vim.opt.updatecount = 100

-- Viminfo stores the state of your previous editing session
vim.opt.viminfo = { "!,'1000,<1000,s200,h" } -- Increasing the buffer size
vim.opt.viminfo:append("n" .. vim.fn.stdpath "data" .. "/nviminfo")
-- vim.opt.sessionoptions:remove { "folds" } -- don't keep folds between sessions
-- vim.opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize" }

-- Save undo history of edited files.
-- Default files location: ~/.local/state/nvim/undo
vim.opt.undofile = true
vim.opt.undolevels = 2048
-- Default location of viewdir is ~/.local/state/nvim/view
vim.opt.viewoptions:remove { "folds" }
-- }}}

-- {{{ spell check
-- vim.opt.spelllang = "en_us"
-- vim.opt.spell = true
-- vim.opt.spellfile:append(os.getenv("HOME") .. "/.config/nvim/spell/nvim-config.en.utf-8.add")

-- re-create spl files for additional vocabularies
vim.cmd [[
for d in glob('~/.config/nvim/spell/*.add', 1, 1)
  if filereadable(d) && (!filereadable(d . '.spl') || getftime(d) >
  \ getftime(d . '.spl'))
    exec 'mkspell! ' . fnameescape(d)
  endif
endfor
]]
-- }}}

-- {{{ tabs (indentation) settings
-- tabs & indentation
vim.opt.tabstop = 2 -- 2 spaces for tabs (prettier default)
vim.opt.shiftwidth = 2 -- 2 spaces for indent width
vim.opt.expandtab = true -- expand tab to spaces
vim.opt.autoindent = true -- copy indent from current line when starting new one

vim.cmd [[
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
  autocmd BufRead,BufNewFile *.tf,*.hcl,*.tfvars,.terraformrc,terraform.rc set ft=terraform
  autocmd BufRead,BufNewFile *.tfstate,*.json.tpl* set ft=json
  autocmd FileType bash,sh,json*,dockerfile,python,cmake
    \ setlocal tabstop=4 softtabstop=4 shiftwidth=4 expandtab
  autocmd FileType javascript,c,make,cpp,**/cpp.snippets,gitignore,gitconfig
    \ setlocal tabstop=4 softtabstop=4 shiftwidth=4 noexpandtab
  autocmd FileType vim,zsh,tmux,conf,nginx,ruby,gitcommit,yaml,yaml.ansible,helm,lua,hcl,terraform
    \ setlocal tabstop=2 softtabstop=2 shiftwidth=2 expandtab
augroup END
]]
-- }}}

-- {{{ Tabs navigation
vim.opt.switchbuf = "usetab,newtab"

-- Smart buffers/tabs switch
local tab_switcher_mode = "buffers"
function ToggleTabSwitcherMode()
  if tab_switcher_mode == "buffers" then
    vim.keymap.set("n", "<M-S-l>", "<Cmd>tabnext<CR>")
    vim.keymap.set("n", "<M-S-h>", "<Cmd>tabprevious<CR>")
    tab_switcher_mode = "tabs"
    print "Switch tabs"
  else
    vim.keymap.set("n", "<M-S-l>", "<Cmd>bnext<CR>")
    vim.keymap.set("n", "<M-S-h>", "<Cmd>bprevious<CR>")
    tab_switcher_mode = "buffers"
    print "Switch buffers"
  end
end
-- this keymap is defined in config/keymaps.lua
-- vim.keymap.set(
--   "n",
--   "<leader><Tab>",
--   "<Cmd>lua ToggleTabSwitcherMode()<CR>",
--   { desc = "Toggle Tab switcher mode." }
-- )
-- }}}

-- {{{ toggle relativenumber
vim.cmd [[
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
]]
-- this keymap is defined in config/keymaps.lua
-- vim.keymap.set(
--   "n",
--   "<leader><leader>rn",
--   "<Cmd>call ToggleSmartRelativenumbers()<CR>",
--   { desc = "Toggle smart relative numbers." }
-- )
-- }}}

-- {{{ Word wrap
vim.opt.textwidth = 99
vim.opt.wrapmargin = 0
vim.opt.colorcolumn = "+1"
vim.opt.wrap = true
vim.opt.linebreak = false
vim.cmd [[
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
]]
-- Toggle word wrap for current buffer
-- vim.keymap.set( -- this keymap is defined in config/keymaps.lua
--   "n",
--   "<leader>ww",
--   "<Cmd>setlocal wrap!<CR> <bar> <Cmd>echo 'wordwrap!'<CR>",
--   { desc = "Toggle visual wrapping of long lines." }
-- )
-- Toggle wrap at textwidth column
-- vim.keymap.set( -- this keymap is defined in config/keymaps.lua
--   "n",
--   "<leader>aw",
--   "<Cmd>call AutoWrapToggle()<CR> <bar> <Cmd>echo 'autowrap!'<CR>",
--   { desc = "Toggle automatic wrapping of long lines." }
-- )
-- }}}

-- {{{ Auto save/load view
-- List of filenames to skip mkview
vim.g.skipview_files =
  { "EXAMPLE", "PLUGIN", "BUFFER", "COMMIT_EDITMSG", "git-rebase-todo", "DiffviewFilePanel" }
vim.cmd [[
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
]]
-- }}}

-- Change cursor view:
vim.opt.guicursor = "n-v-c-sm:block,i-ci-ve:ver25-Cursor,r-cr-o:hor20,a:blinkon1"

-- Folding settings
-- zc fold block
-- zo unfold block
-- zM fold all blocks
-- zR unfold all blocks
-- za toggle folding
-- zf create manual fold, check :set foldmethod=manual
vim.opt.foldmethod = "manual" -- "manual" for manual folds; "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()" -- use treesitter to generate folds
vim.opt.foldcolumn = "1"
vim.opt.foldlevel = 2 -- fold levels opened at file opens
vim.opt.foldlevelstart = 99
-- vim.opt.foldopen = "all" -- autoopen fold when enter it
vim.opt.foldnestmax = 3 -- max level of fold

-- A way to delete 'mkview' for current file
vim.cmd [[
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
]]

-- Toggle diff view for all visible windows
local diff_view_active = false
function ToggleDiffViewMode()
  if diff_view_active then
    vim.cmd ":diffoff!"
    diff_view_active = false
    print "Diff view deactivated"
  else
    vim.cmd [[
    :NvimTreeClose
    :windo diffthis
    ]]
    diff_view_active = true
    print "Diff view activated"
  end
end
vim.keymap.set("n", "<leader><F9>", "<Cmd>lua ToggleDiffViewMode()<CR>")
vim.keymap.set("n", "<leader>dg", "<Cmd>diffget<CR> <bar> :echo 'Get chunk'<CR>")
vim.keymap.set("n", "<leader>dp", "<Cmd>diffput<CR> <bar> :echo 'Put chunk'<CR>")
-- }}}

-- Easily search and replace using quickfix window
vim.cmd [[
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
]]

-- Disable formatting when saving file (disable autocommands)
vim.cmd [[
  command! WriteNoFormat noautocmd write
  cabbrev wnf <c-r>=(getcmdtype()==':' && getcmdpos()==1 ? 'WriteNoFormat' : 'wnf')<CR>
]]

-- Copy current file name/full path/dir name/dir path
vim.cmd [[
  command! CopyFileName let @+ = expand("%:t")
  command! CopyFilePath let @+ = expand("%:p")
  command! CopyDirName let @+ = expand("%:h")
  command! CopyDirPath let @+ = expand("%:p:h")
]]

-- misc
vim.opt.showcmd = true
vim.opt.laststatus = 3
vim.opt.pastetoggle = "<F4>"
vim.opt.whichwrap:append "<,>,[,]"
vim.opt.mousemoveevent = true
vim.opt.timeoutlen = 300

vim.o.formatoptions = "jcroqlnt"
vim.opt.breakindent = true
vim.opt.cmdheight = 1
vim.opt.completeopt = "menuone,noselect"
vim.opt.conceallevel = 3
vim.opt.confirm = true
vim.opt.hidden = true
vim.opt.hlsearch = true
vim.opt.inccommand = "nosplit"
vim.opt.joinspaces = false
vim.opt.mouse = "a"
vim.opt.pumblend = 10
vim.opt.pumheight = 10
vim.opt.shiftround = true
vim.opt.showmode = false
vim.opt.smartindent = false
vim.opt.updatetime = 200

vim.g.mapleader = " "
vim.g.maplocalleader = ","
vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>")

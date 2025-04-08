-- Set options suitable for VSCode NeoVim
-- line numbers
vim.opt.number = false
vim.opt.relativenumber = false
vim.opt.wrap = false
vim.opt.clipboard = "unnamedplus" -- Use system clipboard

-- leader keys
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
-- vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>")

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
-- }}} end of Wildmenu completion

-- line wrapping
vim.opt.wrap = false -- disable line wrapping

-- search settings
vim.opt.ignorecase = true -- ignore case when searching
vim.opt.smartcase = true -- if you include mixed case in your search, assumes you want case-sensitive

-- highlight the current cursor line and column
vim.wo.cursorline = true
vim.wo.cursorcolumn = true

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
vim.opt.swapfile = false
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
-- }}} end of Backup, Undo and Swap files settings

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
-- }}} end of spell check

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

function! TabsNoExpandByTwoSpaces()
  setlocal tabstop=2
  setlocal shiftwidth=2
  setlocal softtabstop=2
  setlocal noexpandtab
endfunction
command! TabsNoExpandByTwoSpaces call TabsNoExpandByTwoSpaces()

function! TabsExpandByFourSpaces()
  setlocal tabstop=4
  setlocal shiftwidth=4
  setlocal softtabstop=4
  setlocal expandtab
endfunction
command! TabsExpandByFourSpaces call TabsExpandByFourSpaces()

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
  autocmd BufRead,BufNewFile .yamllint,.yamlfmt set ft=yaml
  autocmd BufRead,BufNewFile *.tf,*.hcl,*.tfvars,.terraformrc,terraform.rc set ft=terraform
  autocmd BufRead,BufNewFile *.tfstate,*.json.tpl* set ft=json
  autocmd FileType bash,sh,json*,dockerfile,python,cmake
    \ setlocal tabstop=4 softtabstop=4 shiftwidth=4 expandtab
  autocmd FileType c,make,cpp,**/cpp.snippets,gitignore,gitconfig
    \ setlocal tabstop=4 softtabstop=4 shiftwidth=4 noexpandtab
  autocmd FileType vim,zsh,tmux,conf,nginx,ruby,gitcommit,yaml,yaml.ansible,helm,lua,hcl,terraform,
    \toml,javascript
    \ setlocal tabstop=2 softtabstop=2 shiftwidth=2 expandtab
  autocmd FileType ps1,psm1,psd1,ps1xml
    \ setlocal tabstop=4 softtabstop=4 shiftwidth=4 expandtab textwidth=99
augroup END
]]
-- }}} end of tabs (indentation) settings

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
-- }}} end of Tabs navigation

-- {{{ Smart relativenumbers
local SmartRelativenumbers_group_name = "SmartRelativenumbers"
local SmartRelativenumbers_group =
  vim.api.nvim_create_augroup(SmartRelativenumbers_group_name, { clear = false })

function SetRelativeNumberAutocmd(events, mode)
  vim.api.nvim_create_autocmd(events, {
    group = SmartRelativenumbers_group,
    pattern = "*",
    callback = function()
      local blacklist = { "toggleterm" }
      if not vim.tbl_contains(blacklist, vim.bo.filetype) then
        if mode then
          if vim.o.number and vim.api.nvim_get_mode().mode ~= "i" then
            vim.opt.relativenumber = true
          end
        else
          if vim.o.number then
            vim.opt.relativenumber = false
            vim.cmd "redraw"
          end
        end
      end
    end,
  })
end

SetRelativeNumberAutocmd(
  { "BufLeave", "FocusLost", "InsertEnter", "CmdlineEnter", "WinLeave" },
  false
)
SetRelativeNumberAutocmd(
  { "BufEnter", "FocusGained", "InsertLeave", "CmdlineLeave", "WinEnter" },
  true
)
vim.g.SmartRelativenumbersEnabled = true

function _G.ToggleSmartRelativenumbers()
  if not vim.g.SmartRelativenumbersEnabled then
    SetRelativeNumberAutocmd(
      { "BufLeave", "FocusLost", "InsertEnter", "CmdlineEnter", "WinLeave" },
      false
    )
    SetRelativeNumberAutocmd(
      { "BufEnter", "FocusGained", "InsertLeave", "CmdlineLeave", "WinEnter" },
      true
    )
    if vim.o.number and vim.api.nvim_get_mode().mode ~= "i" then
      vim.opt.relativenumber = true
    end
    vim.g.SmartRelativenumbersEnabled = true
  else
    vim.api.nvim_create_augroup(SmartRelativenumbers_group_name, { clear = true })
    if vim.o.number then
      vim.opt.relativenumber = false
      vim.cmd "redraw"
    end
    vim.g.SmartRelativenumbersEnabled = false
  end
end
-- this keymap is defined in config/keymaps.lua
-- vim.keymap.set("n", "<leader><leader>rn", function()
--   ToggleSmartRelativenumbers()
-- end, { desc = "Toggle smart relative numbers." })
-- }}} end of Smart relativenumbers

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
-- }}} end of Word wrap

-- Change cursor view:
vim.opt.guicursor = "n-v-c-sm:block,i-ci-ve:ver25-Cursor,r-cr-o:hor20,a:blinkon1"

-- Folding settings
-- zc close fold
-- zo open fold
-- zm close folds of lowest level
-- zM close all open folds
-- zr open folds of lowest level
-- zR open all folds
-- za toggles the fold at the cursor
-- zf create manual fold, check :set foldmethod=manual
vim.opt.foldmethod = "expr" -- "manual" for manual folds; "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()" -- use treesitter to generate folds
vim.opt.foldtext = ""
vim.opt.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]
vim.opt.foldcolumn = "1"
vim.opt.foldlevel = 99 -- fold levels opened at file opens
vim.opt.foldlevelstart = 4
-- vim.opt.foldopen = "all" -- autoopen fold when enter it
vim.opt.foldnestmax = 4 -- max level of fold

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

-- Disable formatting when saving file (disable autocommands)
vim.cmd [[
  command! WriteNoFormat noautocmd write
  cabbrev wnf <c-r>=(getcmdtype()==':' && getcmdpos()==1 ? 'WriteNoFormat' : 'wnf')<CR>
]]

-- misc
vim.opt.showcmd = true
vim.opt.laststatus = 3
vim.opt.whichwrap:append "<,>,[,]"
vim.opt.mousemoveevent = true
vim.opt.timeoutlen = 300

vim.o.formatoptions = "jcroqlnt"
vim.opt.breakindent = true
vim.opt.cmdheight = 1
vim.opt.completeopt = "menuone,noselect"
vim.opt.conceallevel = 0
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
vim.opt.startofline = true

vim.diagnostic.config { virtual_lines = false }

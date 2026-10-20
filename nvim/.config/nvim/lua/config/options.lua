-- leader keys
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.keymap.set({ "n", "x" }, "<Space>", "<Nop>") -- not Select mode, where Space must insert

-- line numbers
vim.opt.relativenumber = true -- show relative line numbers
vim.opt.number = true -- shows absolute line number on cursor line (when relative number is on)

-- always show minimum n lines after current line
vim.opt.scrolloff = 5
-- The minimal number of screen columns to keep to the left and to the right of the cursor if
-- 'nowrap' is set
vim.opt.sidescrolloff = 8

-- {{{ Wildmenu completion
vim.opt.wildmenu = true
vim.opt.wildmode = "longest:full,full"

vim.opt.wildignore:append(".hg,.git,.svn") -- Version control
vim.opt.wildignore:append("*.aux,*.out,*.toc") -- LaTeX intermediate files
vim.opt.wildignore:append("*.jpg,*.bmp,*.gif,*.png,*.jpeg") -- binary images
vim.opt.wildignore:append("*.o,*.obj,*.exe,*.dll,*.manifest") -- compiled object files
vim.opt.wildignore:append("*.spl") -- compiled spelling word list
vim.opt.wildignore:append("*.sw?") -- Vim swap files
vim.opt.wildignore:append("*.DS_Store") -- OSX bullshit
vim.opt.wildignore:append("*.luac") -- Lua byte code
vim.opt.wildignore:append("migrations") -- Django migrations
vim.opt.wildignore:append("go/pkg") -- Go static files
vim.opt.wildignore:append("go/bin") -- Go bin files
vim.opt.wildignore:append("go/bin-vagrant") -- Go bin-vagrant files
vim.opt.wildignore:append("*.pyc") -- Python byte code
vim.opt.wildignore:append("*.orig") -- Merge resolution files
-- }}} end of Wildmenu completion

-- search settings
vim.opt.ignorecase = true -- ignore case when searching
vim.opt.smartcase = true -- if you include mixed case in your search, assumes you want case-sensitive

-- highlight the current cursor line and column
vim.wo.cursorline = true
vim.wo.cursorcolumn = false

-- appearance

-- turn on termguicolors for colorscheme to work
-- (have to use iterm2 or any other true color terminal)
vim.opt.termguicolors = true
vim.opt.background = "dark" -- colorschemes that can be light or dark will be made dark
vim.opt.signcolumn = "yes:1" -- Always show signcolumn; git signs handled separately by snacks statuscolumn

-- encoding detection: check BOM first so UTF-16 LE files (e.g. Windows Task
-- Scheduler XML exports) are opened and saved back in their original encoding
vim.opt.fileencodings = { "ucs-bom", "utf-8", "default", "latin1" }

-- backspace
vim.opt.backspace = "indent,eol,start" -- allow backspace on indent, end of line or insert mode start position

-- clipboard
vim.opt.clipboard:append("unnamedplus") -- use system clipboard as default register

-- split windows
vim.opt.splitright = true -- split vertical window to the right
vim.opt.splitbelow = true -- split horizontal window to the bottom

-- Show non-visible white spaces
vim.opt.list = true
vim.opt.listchars:append("eol:¬,tab:▸—,trail:~,extends:»,precedes:«,space:·")

-- {{{ Backup, Undo and Swap files settings
-- Save your backup files to a less annoying place than the current directory.
-- Default location of backup files is ~/.local/state/nvim/backup
vim.opt.backup = true
vim.opt.backupdir = { vim.fn.expand("~/.local/state/nvim/backup"), "." }
-- Try to create a backup directory in the default location if it doesn't exist
if vim.fn.isdirectory(vim.opt.backupdir:get()[1]) == 0 then
  pcall(vim.fn.mkdir, vim.opt.backupdir:get()[1], "p")
end

-- Default location of swap files (echo &directory) is ~/.local/state/nvim/swap
vim.opt.swapfile = false
vim.opt.updatecount = 100

-- ShaDa stores the state of your previous editing session
vim.opt.shada = { "!", "'1000", "<1000", "s200", "h" } -- Increasing the buffer size
vim.opt.shada:append("n" .. vim.fn.stdpath("data") .. "/nviminfo")

-- Save undo history of edited files.
-- Default files location: ~/.local/state/nvim/undo
vim.opt.undofile = true
vim.opt.undolevels = 2048
-- Default location of viewdir is ~/.local/state/nvim/view
-- "curdir" is left out: loadview would run :lcd and override the per-buffer
-- cwd restored in config/autocmds.lua
-- (one item per call: a list becomes "-=folds,curdir", which matches nothing)
vim.opt.viewoptions:remove("folds")
vim.opt.viewoptions:remove("curdir")
-- }}} end of Backup, Undo and Swap files settings

-- {{{ spell check

-- re-create spl files for additional vocabularies
for _, add in ipairs(vim.fn.glob(vim.fn.stdpath("config") .. "/spell/*.add", true, true)) do
  local spl = add .. ".spl"
  if vim.fn.filereadable(spl) == 0 or vim.fn.getftime(add) > vim.fn.getftime(spl) then
    vim.cmd.mkspell({ add, bang = true })
  end
end
-- }}} end of spell check

-- {{{ tabs (indentation) settings
-- tabs & indentation
vim.opt.tabstop = 2 -- 2 spaces for tabs (prettier default)
vim.opt.shiftwidth = 2 -- 2 spaces for indent width
vim.opt.expandtab = true -- expand tab to spaces, unless a FileType rule below says otherwise
vim.opt.autoindent = true -- copy indent from current line when starting new one

---Set the indentation of the current buffer.
---@param width integer
---@param expand boolean
local function set_indent(width, expand)
  vim.bo.tabstop = width
  vim.bo.shiftwidth = width
  vim.bo.softtabstop = width
  vim.bo.expandtab = expand
end

for name, args in pairs({
  TabsNoExpandByFourSpaces = { 4, false },
  TabsNoExpandByTwoSpaces = { 2, false },
  TabsExpandByFourSpaces = { 4, true },
  TabsExpandByTwoSpaces = { 2, true },
}) do
  vim.api.nvim_create_user_command(name, function()
    set_indent(args[1], args[2])
  end, {})
end

vim.filetype.add({
  extension = {
    tf = "terraform",
    hcl = "terraform",
    tfvars = "terraform",
    tfstate = "json",
  },
  filename = {
    ["Chart.yaml"] = "helm",
    [".yamllint"] = "yaml",
    [".yamlfmt"] = "yaml",
    [".terraformrc"] = "terraform",
    ["terraform.rc"] = "terraform",
  },
  pattern = {
    [".*%.json%.tpl.*"] = "json",
  },
})

local indent_group = vim.api.nvim_create_augroup("filetypeRelatedSettings", { clear = true })
for _, rule in ipairs({
  {
    { "bash", "sh", "json*", "dockerfile", "python", "cmake" },
    function()
      set_indent(4, true)
    end,
  },
  {
    { "c", "make", "cpp", "gitignore", "gitconfig" },
    function()
      set_indent(4, false)
    end,
  },
  {
    -- stylua: ignore
    {
      "vim", "zsh", "tmux", "conf", "nginx", "ruby", "gitcommit", "yaml", "yaml.ansible", "helm",
      "lua", "hcl", "terraform", "toml", "javascript",
    },
    function()
      set_indent(2, true)
    end,
  },
  {
    { "ps1", "psm1", "psd1", "ps1xml" },
    function()
      set_indent(4, true)
      vim.bo.textwidth = 99
    end,
  },
}) do
  vim.api.nvim_create_autocmd(
    "FileType",
    { group = indent_group, pattern = rule[1], callback = rule[2] }
  )
end
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
    print("Switch tabs")
  else
    vim.keymap.set("n", "<M-S-l>", "<Cmd>bnext<CR>")
    vim.keymap.set("n", "<M-S-h>", "<Cmd>bprevious<CR>")
    tab_switcher_mode = "buffers"
    print("Switch buffers")
  end
end
-- the related keymap is defined in config/keymaps.lua
-- }}} end of Tabs navigation

-- {{{ Smart relativenumbers
local SmartRelativenumbers_group_name = "SmartRelativenumbers"
local SmartRelativenumbers_group =
  vim.api.nvim_create_augroup(SmartRelativenumbers_group_name, { clear = false })

-- Events after which Neovim does not redraw by itself, so the absolute
-- numbers would not show up (e.g. while typing a :{lnum} command)
local redraw_on = { CmdlineEnter = true, FocusLost = true }

local function SetRelativeNumberAutocmd(events, mode)
  vim.api.nvim_create_autocmd(events, {
    group = SmartRelativenumbers_group,
    pattern = "*",
    callback = function(ev)
      local blacklist = { "snacks_terminal" }
      if not vim.tbl_contains(blacklist, vim.bo.filetype) then
        if mode then
          if vim.wo.number and vim.api.nvim_get_mode().mode ~= "i" then
            vim.wo.relativenumber = true
          end
        else
          if vim.wo.number and vim.wo.relativenumber then
            vim.wo.relativenumber = false
            if redraw_on[ev.event] then
              vim.cmd.redraw()
            end
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
    if vim.wo.number and vim.api.nvim_get_mode().mode ~= "i" then
      vim.wo.relativenumber = true
    end
    vim.g.SmartRelativenumbersEnabled = true
  else
    vim.api.nvim_create_augroup(SmartRelativenumbers_group_name, { clear = true })
    if vim.wo.number then
      vim.wo.relativenumber = false
      vim.cmd.redraw()
    end
    vim.g.SmartRelativenumbersEnabled = false
  end
end
-- the related keymap is defined in config/keymaps.lua
-- }}} end of Smart relativenumbers

-- {{{ Toggle snacks/fzf-lua/telescope keymaps
vim.g.FuzzySearchKeymaps = "snacks" -- snacks|fzf-lua|telescope
function _G.ToggleFuzzySearchKeymaps()
  local cycle = {
    snacks = { next = "fzf-lua", mod = "plugins.fzf-lua.keymaps" },
    ["fzf-lua"] = { next = "telescope", mod = "plugins.telescope.keymaps" },
    telescope = { next = "snacks", mod = "plugins.snacks.keymaps" },
  }
  local from = vim.g.FuzzySearchKeymaps
  local entry = cycle[from]
  if not entry then
    vim.notify("Invalid picker: " .. tostring(from), vim.log.levels.ERROR)
    return
  end
  require(entry.mod).setup()
  vim.g.FuzzySearchKeymaps = entry.next
  vim.notify("Fuzzy picker: " .. entry.next, vim.log.levels.INFO)
end
vim.keymap.set("n", "<leader>fT", function()
  ToggleFuzzySearchKeymaps()
end, { desc = "Toggle snacks/fzf-lua/telescope keymaps" })
-- }}} end of Toggle snacks/fzf-lua/telescope keymaps

-- {{{ Word wrap
vim.opt.textwidth = 99
vim.opt.wrapmargin = 0
vim.opt.colorcolumn = "+1"
vim.opt.wrap = true
vim.opt.linebreak = false
function _G.AutoWrapToggle()
  if vim.bo.formatoptions:find("t", 1, true) then
    vim.bo.textwidth = 0
    vim.opt_local.formatoptions:remove("t")
    vim.wo.colorcolumn = ""
  else
    vim.bo.textwidth = 99
    vim.opt_local.formatoptions:append("t")
    vim.wo.colorcolumn = "+1"
  end
end
-- the related keymaps are defined in config/keymaps.lua
-- }}} end of Word wrap

-- {{{ Auto save/load view
-- List of filenames to skip mkview
vim.g.skipview_files =
  { "EXAMPLE", "PLUGIN", "BUFFER", "COMMIT_EDITMSG", "git-rebase-todo", "DiffviewFilePanel" }
local function make_view_check(buf)
  if vim.bo[buf].buftype:find("nofile", 1, true) then
    -- Buffer is marked as not a file
    return false
  end
  local path = vim.api.nvim_buf_get_name(buf)
  if path == "" or not vim.uv.fs_stat(path) then
    -- File does not exist on disk
    return false
  end
  local dir = vim.fn.fnamemodify(path, ":h")
  if dir == "/tmp" or dir == "/var/tmp" then
    -- We're in a temp dir
    return false
  end
  -- Skip files from the skip list
  return not vim.tbl_contains(vim.g.skipview_files, vim.fn.fnamemodify(path, ":t"))
end

local view_group = vim.api.nvim_create_augroup("vimrcAutoView", { clear = true })
-- Autosave & Load Views. Saved when the buffer leaves its window, not on
-- every BufLeave/WinLeave: each save writes a file
vim.api.nvim_create_autocmd({ "BufWritePost", "BufWinLeave" }, {
  group = view_group,
  pattern = "?*",
  callback = function(ev)
    -- mkview saves the current window, which must show this buffer
    if ev.buf == vim.api.nvim_get_current_buf() and make_view_check(ev.buf) then
      pcall(vim.cmd.mkview)
    end
  end,
})
vim.api.nvim_create_autocmd("BufWinEnter", {
  group = view_group,
  pattern = "?*",
  callback = function(ev)
    if make_view_check(ev.buf) then
      pcall(vim.cmd, "silent! loadview")
    end
  end,
})
-- }}} end of Auto save/load view

-- Change cursor view:
vim.opt.guicursor =
  "n-v-c-sm:block,i-ci-ve:ver25-Cursor,r-cr-o:hor20,a:blinkwait700-blinkon500-blinkoff500"

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
vim.opt.foldcolumn = "0" -- fold icons rendered by snacks statuscolumn
vim.opt.foldlevel = 99 -- fold levels opened at file opens
vim.opt.foldlevelstart = 4
vim.opt.foldnestmax = 4 -- max level of fold

---Replace a command-line abbreviation with a user command, only when it is
---the whole command typed so far (e.g. "delview" -> "Delview").
---@param lhs string
---@param cmd string
local function cmd_alias(lhs, cmd)
  vim.keymap.set("ca", lhs, function()
    return (vim.fn.getcmdtype() == ":" and vim.fn.getcmdline() == lhs) and cmd or lhs
  end, { expr = true })
end

-- A way to delete 'mkview' for current file
vim.api.nvim_create_user_command("Delview", function()
  local path = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":p")
  -- the view file name is the path with "=" doubled, $HOME replaced with "~"
  -- and "/" replaced with "=+"
  path = path:gsub("=", "==")
  local home = vim.env.HOME
  if home and home ~= "" and vim.startswith(path, home) then
    path = "~" .. path:sub(#home + 1)
  end
  path = vim.o.viewdir .. "/" .. path:gsub("/", "=+") .. "="
  vim.fn.delete(path)
  print("Deleted: " .. path)
  -- re-open current file
  vim.cmd.edit("%")
end, {})
cmd_alias("delview", "Delview")

-- Toggle diff view for all visible windows
local diff_view_active = false
_G.ToggleDiffViewMode = function()
  if diff_view_active then
    vim.cmd.diffoff({ bang = true })
    diff_view_active = false
    print("Diff view deactivated")
  else
    for _, explorer in ipairs(Snacks.picker.get({ source = "explorer" })) do
      explorer:close()
    end
    vim.cmd.windo("diffthis")
    diff_view_active = true
    print("Diff view activated")
  end
end
vim.keymap.set("n", "<localleader><F9>", ToggleDiffViewMode, { desc = "Toggle Diff view" })
vim.keymap.set("n", "<localleader>dg", function()
  vim.cmd.diffget()
  print("Get chunk")
end, { desc = "Pull a chunk from another version" })
vim.keymap.set("n", "<localleader>dp", function()
  vim.cmd.diffput()
  print("Put chunk")
end, { desc = "Push a chunk to another version" })
-- }}}

-- {{{ Toggle QuickFix window
_G.QFToggle = function()
  local qf_exists = false
  for _, win in pairs(vim.fn.getwininfo()) do
    if win["quickfix"] == 1 then
      qf_exists = true
    end
  end
  if qf_exists == true then
    vim.cmd.cclose()
    return
  end
  if not vim.tbl_isempty(vim.fn.getqflist()) then
    vim.cmd.copen()
  end
end
vim.keymap.set("n", "<leader>qf", function()
  return QFToggle()
end, { desc = "Toggle QuickFix" })
-- }}} end of Toggle QuickFix window

-- Easily search and replace using quickfix window
vim.api.nvim_create_autocmd("BufWinEnter", {
  group = vim.api.nvim_create_augroup("quickfix_group", { clear = true }),
  pattern = "quickfix",
  callback = function(ev)
    -- Make the quickfix list modifiable and set errorformat
    vim.opt_local.errorformat:append("%f|%l col %c|%m")
    vim.bo[ev.buf].modifiable = true
    local function map(mode, lhs, rhs)
      vim.keymap.set(mode, lhs, rhs, { buffer = ev.buf })
    end
    -- Go to the previous location and stay in the quickfix window
    map("n", "K", ":cprev<CR>zz:cclose<CR>:botright copen<CR>")
    -- Go to the next location and stay in the quickfix window
    map("n", "J", ":cnext<CR>zz:cclose<CR>:botright copen<CR>")
    -- Save the changes in the quickfix window
    map("c", "w", ":cgetbuffer<CR>:cclose<CR>:botright copen<CR>")
    -- Begin the search and replace for each item in QF
    map("n", "<leader>r", ":cdo s/// | update<C-Left><C-Left><Left><Left><Left>")
    -- Begin the search and replace for each filie in QF
    map("n", "<leader>R", ":cfdo s/// | update<C-Left><C-Left><Left><Left><Left>")
    -- Open location and re-open quickfix window
    map("n", "<CR>", "<CR>zz:cclose<CR>:botright copen<CR>")
  end,
})

-- Disable formatting when saving file (disable autocommands)
vim.api.nvim_create_user_command("WriteNoFormat", "noautocmd write", {})
cmd_alias("wnf", "WriteNoFormat")

-- Delete current file
vim.api.nvim_create_user_command("DeleteCurrentFile", function()
  require("utils").delete_current_file()
end, {})

-- misc
vim.opt.showcmd = true
vim.opt.laststatus = 3
vim.opt.whichwrap:append("<,>,[,]")
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

vim.diagnostic.config({ virtual_lines = false })

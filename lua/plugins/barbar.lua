-- import plugin safely
local setup, barbar = pcall(require, "bufferline")
if not setup then
  return
end

barbar.setup({
  icons = "numbers",
  closable = false,
  animation = false,
  maximum_padding = 1,
  minimum_padding = 0,
  maximum_length = 30,
  icon_separator_active = "",
  icon_separator_inactive = "",
  icon_close_tab = "",
  icon_close_tab_modified = "●",
  icon_pinned = "",
  hide = { extensions = false, inactive = false },
  diagnostics = {
    -- you can use a list
    { enabled = true, icon = "×" }, -- ERROR
    { enabled = false }, -- WARN
    { enabled = false }, -- INFO
    { enabled = true }, -- HINT
  },
})

-- keymaps
local keymap = vim.keymap
local opts = { silent = true, noremap = true }
-- Move to previous/next
keymap.set("n", "]b", "<Cmd>BufferNext<CR>", opts)
keymap.set("n", "[b", "<Cmd>BufferPrevious<CR>", opts)
keymap.set("n", "<M-S-l>", "<Cmd>BufferNext<CR>", opts)
keymap.set("n", "<M-S-h>", "<Cmd>BufferPrevious<CR>", opts)
-- Re-order to previous/next
keymap.set("n", "<leader>]b", "<Cmd>BufferMoveNext<CR>", opts)
keymap.set("n", "<leader>[b", "<Cmd>BufferMovePrevious<CR>", opts)
keymap.set("n", "<C-M-S-l>", "<Cmd>BufferMoveNext<CR>", opts)
keymap.set("n", "<C-M-S-h>", "<Cmd>BufferMovePrevious<CR>", opts)
-- Goto buffer in position...
keymap.set("n", "<leader>1", "<Cmd>BufferGoto 1<CR>", opts)
keymap.set("n", "<leader>2", "<Cmd>BufferGoto 2<CR>", opts)
keymap.set("n", "<leader>3", "<Cmd>BufferGoto 3<CR>", opts)
keymap.set("n", "<leader>4", "<Cmd>BufferGoto 4<CR>", opts)
keymap.set("n", "<leader>5", "<Cmd>BufferGoto 5<CR>", opts)
keymap.set("n", "<leader>6", "<Cmd>BufferGoto 6<CR>", opts)
keymap.set("n", "<leader>7", "<Cmd>BufferGoto 7<CR>", opts)
keymap.set("n", "<leader>8", "<Cmd>BufferGoto 8<CR>", opts)
keymap.set("n", "<leader>9", "<Cmd>BufferGoto 9<CR>", opts)
keymap.set("n", "<leader>0", "<Cmd>BufferLast<CR>", opts)
-- Pin/unpin buffer
keymap.set("n", "<leader><leader><C-p>", "<Cmd>BufferPin<CR>", opts)
-- Close buffer
keymap.set("n", "gz", "<Cmd>BufferClose<CR>", opts) -- close active buffer
-- Wipeout buffer
--                 :BufferWipeout
-- Close commands
--                 :BufferCloseAllButCurrent
--                 :BufferCloseAllButPinned
--                 :BufferCloseAllButCurrentOrPinned
--                 :BufferCloseBuffersLeft
--                 :BufferCloseBuffersRight
-- Magic buffer-picking mode
keymap.set("n", "<leader><leader>p", "<Cmd>BufferPick<CR>", opts)
-- Sort automatically by...
keymap.set("n", "<leader>bb", "<Cmd>BufferOrderByBufferNumber<CR>", opts)
keymap.set("n", "<leader>bd", "<Cmd>BufferOrderByDirectory<CR>", opts)
keymap.set("n", "<leader>bl", "<Cmd>BufferOrderByLanguage<CR>", opts)
keymap.set("n", "<leader>bw", "<Cmd>BufferOrderByWindowNumber<CR>", opts)

-- {{{ Smart buffers/tabs switch
local tab_switcher_mode = "buffers"
function ToggleTabSwitcherMode()
  if tab_switcher_mode == "buffers" then
    keymap.set("n", "<M-S-l>", "<Cmd>tabnext<CR>", opts)
    keymap.set("n", "<M-S-h>", "<Cmd>tabprevious<CR>", opts)
    tab_switcher_mode = "tabs"
    print("Switch tabs")
  else
    keymap.set("n", "<M-S-l>", "<Cmd>BufferNext<CR>", opts)
    keymap.set("n", "<M-S-h>", "<Cmd>BufferPrevious<CR>", opts)
    tab_switcher_mode = "buffers"
    print("Switch buffers")
  end
end
keymap.set("n", "<leader><Tab>", "<Cmd>lua ToggleTabSwitcherMode()<CR>", opts)
-- }}}

-- {{{ nvim-tree integration
local load, nvim_tree_events = pcall(require, "nvim-tree.events")
if not load then
  return
end

local bufferline_api = require("bufferline.api")

local function get_tree_size()
  return require("nvim-tree.view").View.width
end

nvim_tree_events.subscribe("TreeOpen", function()
  bufferline_api.set_offset(get_tree_size())
end)

nvim_tree_events.subscribe("Resize", function()
  bufferline_api.set_offset(get_tree_size())
end)

nvim_tree_events.subscribe("TreeClose", function()
  bufferline_api.set_offset(0)
end)
-- }}}

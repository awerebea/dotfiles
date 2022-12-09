local setup, hop = pcall(require, "hop")
if not setup then
  return
end

hop.setup({})

local nvim_command = vim.api.nvim_command
nvim_command("highlight HopNextKey cterm=bold gui=bold guifg=#ff0000")
nvim_command("highlight HopNextKey1 cterm=bold gui=bold guifg=#ffb400")
nvim_command("highlight HopNextKey2 cterm=bold gui=bold guifg=#b98300")

local directions = require("hop.hint").HintDirection
local keymap = vim.keymap

keymap.set("", "<leader><leader>W", ":HopWordMW<CR>")
keymap.set("", "<leader><leader>w", ":HopWordAC<CR>")
keymap.set("", "<leader><leader>b", ":HopWordBC<CR>")
keymap.set("", "<leader><leader>f", ":HopChar1AC<CR>")
keymap.set("", "<leader><leader>F", ":HopChar1BC<CR>")
keymap.set("", "<leader><leader>t", function()
  hop.hint_char1({
    direction = directions.AFTER_CURSOR,
    current_line_only = false,
    hint_offset = -1,
  })
end, { remap = true })
keymap.set("", "<leader><leader>T", function()
  hop.hint_char1({
    direction = directions.BEFORE_CURSOR,
    current_line_only = false,
    hint_offset = 1,
  })
end, { remap = true })
keymap.set("", "<leader><leader>s", ":HopChar1<CR>")
keymap.set("", "<leader><leader>S", ":HopChar2<CR>")
keymap.set("", "<leader><leader>2s", ":HopChar2<CR>")
keymap.set("", "<leader><leader>d", ":HopChar2<CR>")
keymap.set("", "<leader><leader>j", ":HopLineAC<CR>")
keymap.set("", "<leader><leader>k", ":HopLineBC<CR>")
keymap.set("", "<leader><leader>/", ":HopPattern<CR>")

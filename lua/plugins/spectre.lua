-- import plugin safely
local setup, spectre = pcall(require, "spectre")
if not setup then
  return
end

spectre.setup()

local keymap = vim.keymap
local opts = { silent = true, noremap = true }
keymap.set("n", "<leader>S", "<Cmd>lua require('spectre').open()<CR>", opts)
-- search current word
keymap.set(
  "n",
  "<leader>sw",
  "<Cmd>lua require('spectre').open_visual({select_word=true})<CR>",
  opts
)
keymap.set("v", "<leader>s", "<Esc><Cmd>lua require('spectre').open_visual()<CR>", opts)
-- search in current file
keymap.set("n", "<leader>sf", "<Cmd>lua require('spectre').open_file_search()<CR>", opts)

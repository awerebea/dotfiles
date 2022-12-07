-- import plugin safely
local setup, spectre = pcall(require, "spectre")
if not setup then
  return
end

spectre.setup()

local keymap = vim.keymap
local opts = { silent = true, noremap = true }
keymap.set("n", "<leader>S", ":lua require('spectre').open()<cr>", opts)
-- search current word
keymap.set("n", "<leader>sw", ":lua require('spectre').open_visual({select_word=true})<cr>", opts)
keymap.set("v", "<leader>s", "<esc>:lua require('spectre').open_visual()<cr>", opts)
-- search in current file
keymap.set("n", "<leader>sp", ":lua require('spectre').open_file_search()<cr>", opts)

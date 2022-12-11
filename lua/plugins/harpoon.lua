local setup, harpoon = pcall(require, "harpoon")
if not setup then
  return
end

harpoon.setup()

local keymap = vim.keymap
keymap.set("n", "<leader>m", '<Cmd>lua require("harpoon.mark").add_file()<CR>')
keymap.set("n", "]m", '<Cmd>lua require("harpoon.ui").nav_next()<CR>')
keymap.set("n", "[m", '<Cmd>lua require("harpoon.ui").nav_prev()<CR>')
keymap.set("n", "<leader><leader>m", '<Cmd>lua require("harpoon.ui").toggle_quick_menu()<CR>')
keymap.set("n", "<leader>fm", "<Cmd>Telescope harpoon marks<CR>")

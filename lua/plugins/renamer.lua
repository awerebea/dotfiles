local setup, renamer = pcall(require, "renamer")
if not setup then
  return
end

renamer.setup()
local otps = { noremap = true, silent = true }
vim.keymap.set("i", "<F2>", '<Cmd>lua require("renamer").rename()<CR>', otps)
vim.keymap.set("n", "<leader>rn", '<Cmd>lua require("renamer").rename()<CR>', otps)
vim.keymap.set("v", "<leader>rn", '<Cmd>lua require("renamer").rename()<CR>', otps)

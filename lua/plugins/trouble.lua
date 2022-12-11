-- import plugin safely
local setup, trouble = pcall(require, "trouble")
if not setup then
  return
end

trouble.setup()

local opts = { silent = true, noremap = true }
vim.keymap.set("n", "<leader>xx", "<Cmd>TroubleToggle<CR>", opts)
vim.keymap.set("n", "<leader>xw", "<Cmd>TroubleToggle workspace_diagnostics<CR>", opts)
vim.keymap.set("n", "<leader>xd", "<Cmd>TroubleToggle document_diagnostics<CR>", opts)
vim.keymap.set("n", "<leader>xl", "<Cmd>TroubleToggle loclist<CR>", opts)
vim.keymap.set("n", "<leader>xq", "<Cmd>TroubleToggle quickfix<CR>", opts)
vim.keymap.set("n", "gR", "<Cmd>TroubleToggle lsp_references<CR>", opts)

return {
  "adoyle-h/lsp-toggle.nvim",
  event = "VeryLazy",
  config = function()
    require("lsp-toggle").setup()
    vim.keymap.set("n", "<leader>tgl", "<Cmd>ToggleLSP<CR>", { desc = "Toggle LSP" })
    vim.keymap.set("n", "<leader>tgn", "<Cmd>ToggleNullLSP<CR>", { desc = "Toggle Null LSP" })
  end,
}

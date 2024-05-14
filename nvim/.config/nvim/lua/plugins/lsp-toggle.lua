return {
  "adoyle-h/lsp-toggle.nvim",
  lazy = true,
  keys = {
    { "<leader>tgl", "<Cmd>ToggleLSP<CR>", desc = "Toggle LSP" },
    { "<leader>tgn", "<Cmd>ToggleNullLSP<CR>", desc = "Toggle Null LSP" },
  },
  config = true,
}

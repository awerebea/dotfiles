return {
  "SmiteshP/nvim-navbuddy",
  keys = {
    { "<leader>nb", "<Cmd>Navbuddy<CR>", desc = "Navbuddy" },
  },
  dependencies = {
    "neovim/nvim-lspconfig",
    "SmiteshP/nvim-navic",
    "MunifTanjim/nui.nvim",
    "numToStr/Comment.nvim",
    "nvim-telescope/telescope.nvim",
  },
  opts = {
    lsp = {
      auto_attach = true,
      preference = { "pyright" },
    },
  },
  config = true,
}

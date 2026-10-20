return {
  "Wansmer/treesj",
  dependencies = { "nvim-treesitter" },
  opts = {
    use_default_keymaps = false,
    max_join_length = 120,
  },
  keys = {
    { "gS", "<Cmd>TSJToggle<CR>", desc = "Split/join (TreeSJ)" },
    { "<leader>gS", "<Cmd>TSJSplit<CR>", desc = "TreeSJ Split" },
    { "<leader>gJ", "<Cmd>TSJJoin<CR>", desc = "TreeSJ Join" },
    { "<leader>gT", "<Cmd>TSJToggle<CR>", desc = "TreeSJ Toggle" },
  },
  config = function(_, opts)
    require("treesj").setup(opts)
  end,
}

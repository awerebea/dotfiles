return {
  "kylechui/nvim-surround",
  version = "*", -- Use for stability; omit to use `main` branch for the latest features
  event = "VeryLazy",
  opts = {
    keymaps = {
      -- override default mapping to avoid conflict with mini.splitjoin plugin
      visual_line = "<leader>gS",
    },
  },
  config = function(_, opts)
    require("nvim-surround").setup(opts)
  end,
}

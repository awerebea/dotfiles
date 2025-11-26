return {
  "A7Lavinraj/fyler.nvim",
  keys = { { "<leader>fy", "<Cmd>Fyler<CR>", desc = "Open Fyler View" } },
  dependencies = { "nvim-mini/mini.icons" },
  branch = "stable", -- Use stable branch for production
  lazy = false, -- Necessary for `default_explorer` to work properly
  opts = {},
}

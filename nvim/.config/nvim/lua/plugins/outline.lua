return {
  "hedyhli/outline.nvim",
  lazy = true,
  -- event = "VeryLazy",
  cmd = { "Outline", "OutlineOpen" },
  keys = { { "<leader>o", "<cmd>Outline<CR>", desc = "Toggle outline" } },
  opts = {
    outline_window = {
      -- open_cmd = "30vnew",
      -- close_cmd = "q",
      -- toggle_cmd = "30vnew",
      position = "right",
      auto_close = false,
      show_numbers = true,
      show_relative_numbers = true,
      show_cursorline = true,
      hide_cursor = true,
    },
    outline_items = {
      -- Show corresponding line numbers of each symbol on the left column as
      -- virtual text, for quick navigation when not focused on outline.
      -- Why? See this comment:
      -- https://github.com/simrat39/symbols-outline.nvim/issues/212#issuecomment-1793503563
      show_symbol_lineno = true,
    },
  },
}

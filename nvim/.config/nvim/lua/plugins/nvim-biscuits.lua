return {
  "code-biscuits/nvim-biscuits",
  event = "VeryLazy",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
  },
  opts = {
    toggle_keybind = "<leader>cb",
    show_on_start = true, -- defaults to false
    cursor_line_only = false,
    max_file_size = "200kb",
  },
}

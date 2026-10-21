return {
  "code-biscuits/nvim-biscuits",
  event = "VeryLazy",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
  },
  opts = {
    toggle_keybind = "<leader>cb",
    show_on_start = true, -- defaults to false
    cursor_line_only = true, -- all lines re-decorates the whole buffer on every edit
    max_file_size = "200kb",
  },
}

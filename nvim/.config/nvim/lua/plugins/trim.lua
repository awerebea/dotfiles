return {
  "cappyzawa/trim.nvim",
  event = "VeryLazy",
  opts = {
    ft_blocklist = {
      -- "markdown",
    },
    patterns = {
      -- [[%s/\(\n\n\)\n\+/\1/]], -- replace multiple blank lines with a single line
    },
    trim_on_write = false,
    trim_trailing = true,
    trim_last_line = false,
    trim_first_line = false,
    highlight = false,
    highlight_bg = "#ff0000", -- or 'red'
    highlight_ctermbg = "red",
    notifications = true,
  },
}

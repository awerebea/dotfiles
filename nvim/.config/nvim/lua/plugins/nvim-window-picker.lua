return {
  "s1n7ax/nvim-window-picker",
  enabled = true,
  version = "2.*",
  keys = { "<leader>w" },
  opts = {
    highlights = {
      statusline = {
        focused = {
          fg = "#ededed",
          bg = "#1abc9c",
          bold = true,
        },
        unfocused = {
          fg = "#ededed",
          bg = "#e35e4f",
          bold = true,
        },
      },
      winbar = {
        focused = {
          fg = "#ededed",
          bg = "#1abc9c",
          bold = true,
        },
        unfocused = {
          fg = "#ededed",
          bg = "#e35e4f",
          bold = true,
        },
      },
    },
    hint = "floating-big-letter", -- 'statusline-winbar' | 'floating-big-letter'
    show_prompt = false,
    picker_config = { floating_big_letter = { font = "ansi-shadow" } },
    filter_rules = {
      autoselect_one = true,
      include_current_win = false,
      bo = {
        filetype = { "NvimTree", "neo-tree", "neo-tree-popup", "notify", "incline", "fidget" },
        buftype = { "terminal", "quickfix", "nofile" },
      },
    },
  },
  config = function(_, opts)
    local picker = require "window-picker"
    picker.setup(opts)
    vim.keymap.set("n", "<leader>w", function()
      local picked_window_id = picker.pick_window() or vim.api.nvim_get_current_win()
      vim.api.nvim_set_current_win(picked_window_id)
    end, { desc = "Pick a window" })
  end,
}

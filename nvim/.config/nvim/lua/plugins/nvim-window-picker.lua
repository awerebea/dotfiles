return {
  "s1n7ax/nvim-window-picker",
  enabled = true,
  version = "2.0.1",
  keys = { "<leader>w" },
  opts = {
    fg_color = "#000000",
    other_win_hl_color = "#1abc9c",
    hint = "floating-big-letter",
    show_prompt = false,
    picker_config = { floating_big_letter = { font = "ansi-shadow" } },
    filter_rules = {
      autoselect_one = true,
      include_current_win = false,
      bo = {
        filetype = { "NvimTree", "neo-tree", "neo-tree-popup", "notify", "incline", "fidget" },
        buftype = { "terminal", "quickfix" },
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

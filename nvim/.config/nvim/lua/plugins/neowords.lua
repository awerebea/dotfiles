return {
  "backdround/neowords.nvim",
  enabled = false, -- not require("utils").is_windows(),
  event = "VeryLazy",
  config = function()
    local neowords = require "neowords"
    local presets = neowords.pattern_presets

    local hops = neowords.get_word_hops(
      "\\v,+",
      "\\v\\.+",
      "\\v['\"]+", -- '"
      "\\v[\\(\\)\\{\\}\\[\\]]+", -- (){}[]
      -- "\\v[\\(\\)]+", -- ()
      -- "\\v[\\[\\]]+", -- []
      -- "\\v[\\{\\}]+", -- {}
      presets.camel_case,
      presets.hex_color,
      presets.number,
      presets.snake_case,
      presets.upper_case
    )

    vim.keymap.set({ "n", "x", "o" }, "w", hops.forward_start)
    vim.keymap.set({ "n", "x", "o" }, "e", hops.forward_end)
    vim.keymap.set({ "n", "x", "o" }, "b", hops.backward_start)
    vim.keymap.set({ "n", "x", "o" }, "ge", hops.backward_end)
  end,
}

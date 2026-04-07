return {
  "kylechui/nvim-surround",
  enabled = true,
  version = "*", -- Use for stability; omit to use `main` branch for the latest features
  event = "VeryLazy",
  init = function()
    -- Must be set before the plugin loads so it doesn't register the default gS visual mapping
    vim.g.nvim_surround_no_visual_mappings = true
  end,
  config = function()
    require("nvim-surround").setup()
    -- Restore visual surround on S; move visual-line off gS so mini.splitjoin owns it
    vim.keymap.set("x", "S", "<Plug>(nvim-surround-visual)", {
      desc = "Add a surrounding pair around a visual selection",
    })
    vim.keymap.set("x", "<leader>gS", "<Plug>(nvim-surround-visual-line)", {
      desc = "Add a surrounding pair around a visual selection, on new lines",
    })
  end,
}

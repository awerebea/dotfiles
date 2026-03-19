return {
  "kylechui/nvim-surround",
  enabled = true,
  version = "*", -- Use for stability; omit to use `main` branch for the latest features
  event = "VeryLazy",
  config = function()
    vim.keymap.del("v", "gS")
    vim.keymap.set("v", "<leader>gS", "<Plug>(nvim-surround-visual-line)", {
      desc = "Add a surrounding pair around a visual selection, on new lines",
    })
  end,
}

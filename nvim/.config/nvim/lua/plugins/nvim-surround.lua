return {
  "kylechui/nvim-surround",
  version = "*", -- Use for stability; omit to use `main` branch for the latest features
  event = "VeryLazy",
  config = function()
    vim.keymap.set("x", "<leader>gS", "<Plug>(nvim-surround-visual-line)", {
      desc = "Add a surrounding pair around a visual selection, on new lines",
    })
  end,
}

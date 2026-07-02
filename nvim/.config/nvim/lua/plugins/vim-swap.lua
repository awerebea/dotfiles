return {
  "machakann/vim-swap",
  event = "VeryLazy",
  config = function()
    vim.api.nvim_del_keymap("n", "gs")
    vim.keymap.set(
      "n",
      "<leader>si",
      "<Plug>(swap-interactive)",
      { noremap = false, desc = "Swap interactive" }
    )
  end,
}

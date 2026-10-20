return {
  "machakann/vim-swap",
  keys = {
    { "g<", desc = "Swap with previous item" },
    { "g>", desc = "Swap with next item" },
    { "<leader>si", desc = "Swap interactive" },
  },
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

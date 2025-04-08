return {
  { "tpope/vim-eunuch", event = "VeryLazy" },
  {
    "tpope/vim-abolish",
    event = "VeryLazy",
    config = function()
      vim.keymap.del("n", "cr")
    end,
  },
  {
    "tpope/vim-fugitive",
    cmd = { "Git", "GBrowse", "Gdiffsplit", "Gvdiffsplit" },
    dependencies = {
      "tpope/vim-rhubarb",
    },
  },
}

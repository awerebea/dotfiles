return {
  { "tpope/vim-repeat", event = "VeryLazy" },
  { "tpope/vim-eunuch", event = "VeryLazy" },
  {
    "tpope/vim-abolish",
    cmd = { "Abolish", "Subvert", "S" },
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

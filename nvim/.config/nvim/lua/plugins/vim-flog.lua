return {
  "rbong/vim-flog",
  lazy = true,
  keys = {
    { "<leader>gff", "<Cmd>Flog<CR>", desc = "Flog" },
    { "<leader>gfs", "<Cmd>Flogsplit<CR>", desc = "Flog Split" },
    { "<leader>gfg", "<Cmd>Floggit<CR>", desc = "Flog Git" },
  },
  cmd = { "Flog", "Flogsplit", "Floggit" },
  dependencies = { "tpope/vim-fugitive" },
}

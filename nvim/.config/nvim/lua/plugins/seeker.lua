return {
  "2kabhishek/seeker.nvim",
  dependencies = { "folke/snacks.nvim", "nvim-telescope/telescope.nvim" },
  cmd = { "Seeker" },
  keys = {
    { "<leader>sa", ":Seeker files<CR>", desc = "Seek Files" },
    { "<leader>sf", ":Seeker git_files<CR>", desc = "Seek Git Files" },
    { "<leader>sg", ":Seeker grep<CR>", desc = "Seek Grep" },
    { "<leader>sw", ":Seeker grep_word<CR>", desc = "Seek Grep Word" },
  },
  opts = {
    -- picker_provider = "telescope",
  },
}

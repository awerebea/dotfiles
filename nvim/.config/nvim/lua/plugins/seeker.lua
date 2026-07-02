return {
  "2kabhishek/seeker.nvim",
  dependencies = { "folke/snacks.nvim", "nvim-telescope/telescope.nvim" },
  cmd = { "Seeker" },
  keys = {
    { "<leader>fa", ":Seeker files<CR>", desc = "Seek Files" },
    { "<leader>sf", ":Seeker files<CR>", desc = "Seek Files" },
    { "<leader>sG", ":Seeker git_files<CR>", desc = "Seek Git Files" },
    { "<leader>sg", ":Seeker grep<CR>", desc = "Seek Grep (fuzzy)" },
    { "<leader>s/", ":Seeker grep<CR>", desc = "Seek Grep (live)" },
    {
      "<leader>sw",
      function()
        require("seeker").seek({ mode = "grep_word" })
      end,
      mode = { "n", "x" },
      desc = "Seek Grep Word / Selection",
    },
  },
  opts = {
    -- picker_provider = "telescope",
  },
}

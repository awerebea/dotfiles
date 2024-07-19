return {
  "windwp/nvim-spectre",
  cmd = { "Spectre" },
  keys = {
    { "<leader>Ss", "<Cmd>Spectre<CR>", desc = "Replace in workplace" },
    -- search current word
    {
      "<leader>Sw",
      "<Cmd>lua require('spectre').open_visual({select_word=true})<CR>",
      desc = "Replace word under curson in workplace",
    },
    -- search in current file
    {
      "<leader>Sf",
      "<Cmd>lua require('spectre').open_file_search()<CR>",
      desc = "Replace in current file",
    },
  },
  config = true,
}

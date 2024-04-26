return {
  "windwp/nvim-spectre",
  cmd = { "Spectre" },
  keys = {
    { "<leader>Ss", "<Cmd>Spectre<CR>" },
    -- search current word
    { "<leader>Sw", "<Cmd>lua require('spectre').open_visual({select_word=true})<CR>" },
    -- search in current file
    { "<leader>Sf", "<Cmd>lua require('spectre').open_file_search()<CR>" },
  },
  config = true,
}

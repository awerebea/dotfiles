return {
  "AckslD/nvim-neoclip.lua",
  enabled = false,
  keys = {
    {
      "<leader>fc",
      function()
        require("telescope").extensions.neoclip.default()
      end,
      desc = "Clipboard",
    },
  },
  dependencies = { "kkharji/sqlite.lua" },
  event = "VeryLazy",
  opts = {
    enable_persistent_history = true,
    continuous_sync = true,
    db_path = vim.fn.stdpath "data" .. "/databases/neoclip.sqlite3",
    default_register = "+",
    keys = {
      telescope = {
        i = {
          select = "<CR>",
          paste = "<C-p>",
          paste_behind = "<C-M-p>",
          replay = "<C-q>", -- replay a macro
          delete = "<C-d>", -- delete an entry
        },
        n = {
          select = "<CR>",
          paste = { "p", "<C-p>" },
          paste_behind = { "P", "<C-M-p>" },
          replay = "q",
          delete = "d",
        },
      },
    },
  },
  config = true,
  init = function()
    require("telescope").load_extension "neoclip"
  end,
}

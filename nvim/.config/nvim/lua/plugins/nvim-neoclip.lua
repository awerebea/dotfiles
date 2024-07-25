return {
  "AckslD/nvim-neoclip.lua",
  enabled = true,
  keys = {
    {
      "<leader>fcc",
      function()
        require("telescope").extensions.neoclip.default()
      end,
      desc = "Clipboard",
    },
    {
      "<leader>fcl",
      function()
        require("neoclip").db_pull()
      end,
      desc = "Pull database",
    },
    {
      "<leader>fcp",
      function()
        require("neoclip").db_push()
      end,
      desc = "Push database",
    },
  },
  dependencies = { "kkharji/sqlite.lua" },
  event = "VeryLazy",
  opts = {
    enable_persistent_history = true,
    continuous_sync = false,
    db_path = vim.fn.stdpath "data" .. "/databases/neoclip.sqlite3",
    default_register = "+",
    content_spec_column = true,
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
    on_select = { move_to_front = true },
    on_paste = { move_to_front = true },
  },
  config = true,
  init = function()
    require("telescope").load_extension "neoclip"
  end,
}

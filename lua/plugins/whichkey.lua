return {
  {
    "mrjones2014/legendary.nvim",
    keys = {
      { "<S-M-p>", "<Cmd>Legendary<CR>", desc = "Legendary" },
      { "<leader>hc", "<Cmd>Legendary commands<CR>", desc = "Command Palette" },
    },
    opts = {
      which_key = { auto_register = true },
    },
  },
  {
    "folke/which-key.nvim",
    dependencies = {
      "mrjones2014/legendary.nvim",
    },
    event = "VeryLazy",
    config = function()
      local wk = require "which-key"
      wk.setup {
        show_help = true,
        plugins = { spelling = false },
        key_labels = { ["<leader>"] = "Leader" },
        triggers = "auto",
        window = {
          border = "single", -- none, single, double, shadow
          position = "bottom", -- bottom, top
        },
        triggers_blacklist = {
          n = { "y" },
          i = { "<leader>" },
          c = { "w" },
        },
      }
      wk.register({
        q = { "<cmd>lua require('utils').quit()<CR>", "Quit" },
        b = { name = "+Buffer" },
        d = { name = "+Debug" },
        f = { name = "+File" },
        h = { name = "+Help" },
        g = { name = "+Git" },
        p = { name = "+Project" },
        t = { name = "+Test", N = { name = "Neotest" } },
        v = { name = "+View" },
        ["sn"] = { name = "+Noice" },
        s = {
          name = "+Search",
          c = {
            function()
              require("utils.cht").cht()
            end,
            "Cheatsheets",
          },
          s = {
            function()
              require("utils.cht").stack_overflow()
            end,
            "Stack Overflow",
          },
        },
        c = {
          name = "+Code",
          x = {
            name = "Swap Next",
            f = "Function",
            p = "Parameter",
            c = "Class",
          },
          X = {
            name = "Swap Previous",
            f = "Function",
            p = "Parameter",
            c = "Class",
          },
        },
      }, { prefix = "<leader>" })
    end,
  },
}

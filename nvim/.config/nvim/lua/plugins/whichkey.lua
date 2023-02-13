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
          n = { "y", ">", "<" },
          i = { "<leader>" },
          c = { "w" },
        },
      }
      wk.register({
        -- q = {
        --   name = "Quit",
        --   q = {
        --     function()
        --       require("utils").quit()
        --     end,
        --     "Quit",
        --   },
        --   t = { "<cmd>tabclose<cr>", "Close Tab" },
        -- },
        b = { name = "Buffer" },
        d = { name = "Debug" },
        f = { name = "File" },
        h = { name = "Help" },
        g = { name = "Git" },
        p = { name = "Project" },
        t = { name = "Test", N = { name = "Neotest" }, o = { "Overseer" } },
        v = { name = "View" },
        c = {
          name = "Code",
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
        S = {
          name = "Spectre",
          s = "Replace in workplace",
          w = "Replace word under curson in workplace",
          f = "Replace in current file",
        },
        s = { name = "spellcheck, neoscope", c = "+Spellcheck" },
      }, { prefix = "<leader>" })
    end,
  },
}

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

      local bufnr = vim.api.nvim_get_current_buf()
      local ft = vim.api.nvim_buf_get_option(bufnr, "filetype")
      local chatgpt = require "chatgpt"
      wk.register({
        b = { name = "Buffer" },
        d = { name = "Debug" },
        f = { name = "Telescope" },
        g = {
          name = "Git, ChatGPT",
          c = {
            name = "Conflicts, Advanced Git search",
            r = "Conflicts refresh",
            q = "Conflicts to quickfix list",
          },
          p = { name = "ChatGPT", r = "Run command" },
        },
        h = { name = "Help" },
        p = { name = "Project" },
        t = { name = "Test", N = { name = "Neotest" }, o = { "Overseer" } },
        v = { name = "View" },
        q = { name = "Session manager" },
        m = "Select Harpoon mark",
        u = "Toggle Undo-tree",
        w = "Pick a window",
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
          r = {
            name = "refurb",
            i = {
              "<cmd>cexpr system('refurb --quiet ' . shellescape(expand('%'))) | copen<cr>",
              "Inspect",
            },
          },
        },
        S = {
          name = "Spectre",
          s = "Replace in workplace",
          w = "Replace word under curson in workplace",
          f = "Replace in current file",
        },
        s = { name = "Spellcheck, Neoscope", c = "+Spellcheck" },
        ["<space>"] = {
          name = "Hop, Harpoon",
          m = "Add Harpoon mark",
          ["2"] = { name = "Hop" },
        },
        ["["] = {
          name = "Harpoon, Bufferline, ToDo-comments",
          b = "Move Bufferline tab left",
          h = "Go to prev Harpoon mark",
        },
        ["]"] = {
          name = "Harpoon, Bufferline, ToDo-comments",
          b = "Move Bufferline tab right",
          h = "Go to next Harpoon mark",
        },
      }, { prefix = "<leader>" })
      wk.register({
        g = {
          name = "Git, ChatGPT",
          c = { name = "Advanced Git search" },
          p = { name = "ChatGPT", r = "Run command" },
        },
      }, { mode = "v", prefix = "<leader>" })
    end,
  },
}

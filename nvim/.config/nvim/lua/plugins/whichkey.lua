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
        key_labels = { ["<leader>"] = "Leader", ["<localleader>"] = "Local Leader" },
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
        a = "AI",
        b = "Buffer",
        d = "Debug",
        f = { "Telescope", a = "Additional" },
        g = {
          "Git, ChatGPT",
          c = {
            "Conflicts, Advanced Git search",
            r = "Conflicts refresh",
            q = "Conflicts to quickfix list",
          },
          d = "DiffView",
          m = "Git messenger",
          l = "Telescope git_commits",
          p = { "ChatGPT", r = "Run command" },
          s = "Git status",
          w = "Git Worktree",
        },
        h = "Help, Harpoon",
        k = { "Open from quickfix, Macrothis", k = "Macrothis" },
        l = "Toggle non-printable symbols",
        M = "Multiple Renamer (muren)",
        T = {
          "Test",
          n = "Neotest",
          o = "Overseer",
          t = "vim-test",
        },
        t = {
          "Tabs, Toggle LSP",
          g = "Toglle LSP",
          N = "Neotest",
          o = "Overseer",
        },
        v = {
          "VGit, View",
          g = { "VGit", l = "All hunks in the repo" },
        },
        q = "Session manager",
        m = "Select Harpoon mark",
        n = "Navbuddy",
        u = "Toggle Undo-tree",
        w = "Pick a window",
        c = {
          "Code, Copy path",
          g = "neogen",
          p = {
            "Copy path to clipboard",
            f = "File",
            d = "Directory",
          },
          x = {
            "Swap Next",
            f = "Function",
            p = "Parameter",
            c = "Class",
          },
          X = {
            "Swap Previous",
            f = "Function",
            p = "Parameter",
            c = "Class",
          },
          r = {
            "refurb",
            i = {
              "<cmd>cexpr system('refurb --quiet ' . shellescape(expand('%'))) | copen<cr>",
              "Inspect",
            },
          },
        },
        S = {
          "Spectre",
          s = "Replace in workplace",
          w = "Replace word under curson in workplace",
          f = "Replace in current file",
        },
        r = "Remove duplicates, Restart LSP, rename symbol",
        s = "Spellcheck, Neoscope",
        x = "Trouble, diagnostics",
        ["<space>"] = {
          "Hop, Harpoon",
          m = "Add Harpoon mark",
          ["2"] = { "Hop" },
        },
        ["["] = {
          "Harpoon, ToDo-comments",
          b = "Move Bufferline tab left",
          h = "Go to prev Harpoon mark",
        },
        ["]"] = {
          "Harpoon, ToDo-comments",
          b = "Move Bufferline tab right",
          h = "Go to next Harpoon mark",
        },
      }, { prefix = "<leader>" })
      wk.register({
        g = {
          "Git, ChatGPT",
          c = "Advanced Git search",
          p = { "ChatGPT", r = "Run command" },
        },
      }, { mode = "v", prefix = "<leader>" })
      wk.register({
        d = "Diff actions",
      }, { prefix = "<localleader>" })
    end,
  },
}

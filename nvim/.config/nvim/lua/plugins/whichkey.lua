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
    event = "VeryLazy",
    dependencies = { "echasnovski/mini.icons", "nvim-tree/nvim-web-devicons" },
    opts = {
      plugins = { spelling = { enabled = false } },
      win = { border = "single" },
      triggers = { "<auto>", mode = "nxsotc" },
    },
    keys = {
      {
        "<leader>?",
        function()
          require("which-key").show { global = false }
        end,
        desc = "Buffer Local Keymaps (which-key)",
      },
    },
    config = function(_, opts)
      local wk = require "which-key"
      wk.setup(opts)
      wk.add {
        -- stylua: ignore
        {
          mode = { "n", "v" },
          { "<leader><space>", group = "Hop, Harpoon" },
          { "<leader><space>2", group = "Hop" },
          { "<leader>M", group = "Multiple Renamer (muren)" },
          { "<leader>S", group = "Spectre" },
          { "<leader>T", group = "Test" },
          { "<leader>Tn", group = "Neotest" },
          { "<leader>To", group = "Overseer" },
          { "<leader>Tt", group = "vim-test" },
          { "<leader>a", group = "AI" },
          { "<leader>b", group = "Buffer" },
          { "<leader>c", group = "Code, Copy path, CopilotChat" },
          { "<leader>cX", group = "Swap Previous" },
          { "<leader>cXc", group = "Class" },
          { "<leader>cXf", group = "Function" },
          { "<leader>cXp", group = "Parameter" },
          { "<leader>cc", group = "CopilotChat" },
          { "<leader>cch", group = "Help actions" },
          { "<leader>ccp", group = "Prompt actions" },
          { "<leader>cg", group = "neogen" },
          { "<leader>cp", group = "Copy path to clipboard" },
          { "<leader>cpd", group = "Directory" },
          { "<leader>cpf", group = "File" },
          { "<leader>cr", group = "refurb" },
          { "<leader>cri", "<cmd>cexpr system('refurb --quiet ' . shellescape(expand('%'))) | copen<cr>", desc = "Inspect" },
          { "<leader>cx", group = "Swap Next" },
          { "<leader>cxc", group = "Class" },
          { "<leader>cxf", group = "Function" },
          { "<leader>cxp", group = "Parameter" },
          { "<leader>d", group = "Debug" },
          { "<leader>f", group = "Telescope" },
          { "<leader>fa", group = "Additional" },
          { "<leader>fc", group = "Neoclip" },
          { "<leader>g", group = "Git, ChatGPT" },
          { "<leader>g", group = "Git, ChatGPT" },
          { "<leader>gc", group = "Conflicts, Advanced Git search" },
          { "<leader>gcq", group = "Conflicts to quickfix list" },
          { "<leader>gcr", group = "Conflicts refresh" },
          { "<leader>gd", group = "DiffView" },
          { "<leader>gl", group = "Telescope git_commits" },
          { "<leader>gp", group = "ChatGPT" },
          { "<leader>gpr", group = "Run command" },
          { "<leader>gs", group = "Git status" },
          { "<leader>gw", group = "Git Worktree" },
          { "<leader>h", group = "Help, Harpoon" },
          { "<leader>k", group = "Open from quickfix, Macrothis" },
          { "<leader>kk", group = "Macrothis" },
          { "<leader>l", group = "Toggle non-printable symbols" },
          { "<leader>m", group = "Select Harpoon mark" },
          { "<leader>n", group = "Navbuddy" },
          { "<leader>q", group = "Session manager" },
          { "<leader>r", group = "Remove duplicates, Restart LSP, rename symbol" },
          { "<leader>s", group = "Spellcheck, Neoscope" },
          { "<leader>t", group = "Tabs, Toggle LSP" },
          { "<leader>tN", group = "Neotest" },
          { "<leader>tg", group = "Toglle LSP" },
          { "<leader>to", group = "Overseer" },
          { "<leader>u", group = "Toggle Undo-tree" },
          { "<leader>w", group = "Pick a window" },
          { "<leader>x", group = "Trouble, diagnostics" },
          { "<leader>/", group = "Fuzzy grep" },
          { "<localleader>d", group = "Diff actions" },
        },
      }
    end,
  },
}

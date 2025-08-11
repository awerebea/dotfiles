return {
  "CopilotC-Nvim/CopilotChat.nvim",
  enabled = true,
  branch = "main",
  dependencies = {
    { "zbirenbaum/copilot.lua" }, -- or github/copilot.vim
    { "nvim-lua/plenary.nvim" }, -- for curl, log wrapper
  },
  keys = { "<leader>cch", "<leader>ccp" },
  cmd = {
    "CopilotChat",
    "CopilotChatOpen",
    "CopilotChatClose",
    "CopilotChatToggle",
    "CopilotChatStop",
    "CopilotChatReset",
    "CopilotChatSave",
    "CopilotChatLoad",
    "CopilotChatDebugInfo",
  },
  opts = {
    debug = false, -- Enable debug logging
    -- default mappings
    mappings = {
      complete = {
        detail = "Use @<Tab> or /<Tab> for options.",
        insert = "<Tab>",
      },
      close = {
        normal = "q",
        insert = "<C-c>",
      },
      reset = {
        normal = "<C-l>",
        insert = "<C-l>",
      },
      submit_prompt = {
        normal = "<CR>",
        insert = "<C-m>",
      },
      accept_diff = {
        normal = "<C-y>",
        insert = "<C-y>",
      },
      yank_diff = {
        normal = "gy",
      },
      show_diff = {
        normal = "gd",
      },
      show_info = {
        normal = "gp",
      },
      show_context = {
        normal = "gs",
      },
    },
    prompts = {
      Commit = {
        prompt = "Write commit message for the change with commitizen convention. Keep the title under 50 characters and wrap message at 72 characters. Describe all changes made using the imperative mood. Format as a gitcommit code block.",
        context = "git:staged",
      },
    },
  },
  config = function(_, opts)
    require("CopilotChat").setup(opts)

    vim.keymap.set("n", "<leader>ccp", function()
      local chat = require "CopilotChat"
      require("CopilotChat").select_prompt()
    end, { desc = "Prompt actions" })
  end,
}

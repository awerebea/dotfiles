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
    model = "gpt-4.1",
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
        prompt = "Write a commit message for the change using the Commitizen convention.\n"
          .. "Keep the title under 50 characters and wrap the message at 72 characters.\n"
          .. "Describe all changes using the imperative mood.\n"
          .. "Format the output as a gitcommit code block.\n\n"
          .. "Extract a Jira ticket key from the current branch name using the "
          .. "pattern AA-DDDD (two uppercase letters, a hyphen, and four digits).\n"
          .. "If the branch name starts with a string matching this pattern, "
          .. "start the commit title with <JIRA_KEY>: followed by a space.",
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

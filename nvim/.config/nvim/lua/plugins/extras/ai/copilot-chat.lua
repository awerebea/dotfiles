return {
  "CopilotC-Nvim/CopilotChat.nvim",
  enabled = true,
  branch = "canary",
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
      show_system_prompt = {
        normal = "gp",
      },
      show_user_selection = {
        normal = "gs",
      },
    },
  },
  config = function(_, opts)
    require("CopilotChat").setup(opts)

    -- Show help actions with telescope
    vim.keymap.set("n", "<leader>cch", function()
      local actions = require "CopilotChat.actions"
      require("CopilotChat.integrations.telescope").pick(actions.help_actions())
    end, { desc = "Help actions" })
    -- Show prompts actions with telescope
    vim.keymap.set("n", "<leader>ccp", function()
      local actions = require "CopilotChat.actions"
      require("CopilotChat.integrations.telescope").pick(actions.prompt_actions())
    end, { desc = "Prompt actions" })
  end,
}

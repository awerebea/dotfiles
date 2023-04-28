return {
  "Bryley/neoai.nvim",
  dependencies = {
    "MunifTanjim/nui.nvim",
  },
  cmd = {
    "NeoAI",
    "NeoAIOpen",
    "NeoAIClose",
    "NeoAIToggle",
    "NeoAIContext",
    "NeoAIContextOpen",
    "NeoAIContextClose",
    "NeoAIInject",
    "NeoAIInjectCode",
    "NeoAIInjectContext",
    "NeoAIInjectContextCode",
  },
  keys = {
    { "<leader>ao", "<Cmd>NeoAI<CR>", desc = "NeoAI Open" },
    { "<leader>ax", "<Cmd>NeoAIClose<CR>", desc = "NeoAI Close" },
    { "<leader>ac", "<Cmd>NeoAIContext<CR>", mode = { "n", "v" }, desc = "NeoAI Context" },
    { "<leader>as", desc = "Summarize Text" },
    { "<leader>ag", desc = "Generate Git Message" },
  },
  config = function()
    require("neoai").setup {
      -- Options go here
    }
  end,
}

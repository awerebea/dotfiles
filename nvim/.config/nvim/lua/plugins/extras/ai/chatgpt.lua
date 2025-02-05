return {
  "jackMort/ChatGPT.nvim",
  enabled = true,
  event = "VeryLazy",
  opts = {
    popup_input = {
      prompt = "  ",
      border = {
        highlight = "FloatBorder",
        style = "rounded",
        text = {
          top_align = "center",
          top = " Prompt ",
        },
      },
      win_options = {
        winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
      },
      submit = "<A-CR>",
    },
  },
  keys = {
    {
      "<leader>gpe",
      "<Cmd>ChatGPTEditWithInstructions<CR>",
      mode = { "n", "v" },
      desc = "Edit with instructions",
    },
    {
      "<leader>gpra",
      "<Cmd>ChatGPTRun code_readability_analysis<CR>",
      mode = { "v" },
      desc = "ChatGPT Code readability analysis",
    },
    { "<leader>gprc", ":ChatGPTRun ", mode = { "n", "v" }, desc = "ChatGPT Run ..." },
    {
      "<leader>gprd",
      "<Cmd>ChatGPTRun docstring<CR>",
      mode = { "v" },
      desc = "ChatGPT Docstring",
    },
    {
      "<leader>gpre",
      "<Cmd>ChatGPTRun explain_code<CR>",
      mode = { "v" },
      desc = "ChatGPT Explain code",
    },
    {
      "<leader>gprf",
      "<Cmd>ChatGPTRun fix_bugs<CR>",
      mode = { "v" },
      desc = "ChatGPT Fix bugs",
    },
    {
      "<leader>gprg",
      "<Cmd>ChatGPTRun grammar_correction<CR>",
      mode = { "v" },
      desc = "ChatGPT Grammar correction",
    },
    {
      "<leader>gpro",
      "<Cmd>ChatGPTRun optimize_code<CR>",
      mode = { "v" },
      desc = "ChatGPT Optimize code",
    },
    {
      "<leader>gprr",
      "<Cmd>ChatGPTRun roxygen_edit<CR>",
      mode = { "v" },
      desc = "ChatGPT Roxygen edit",
    },
    {
      "<leader>gprt",
      "<Cmd>ChatGPTRun translate<CR>",
      mode = { "v" },
      desc = "ChatGPT Translate",
    },
    { "<leader>gpt", "<Cmd>ChatGPT<CR>", desc = "ChatGPT Open" },
  },
  config = function(_, opts)
    require("chatgpt").setup(opts)
  end,
  dependencies = {
    "MunifTanjim/nui.nvim",
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
  },
}

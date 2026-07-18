return {
  "Bryley/neoai.nvim",
  enabled = false,
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
    { "<leader>as", desc = "NeoAI: summarize text" },
    { "<leader>aG", desc = "NeoAI: generate git message" },
  },
  config = function()
    require("neoai").setup({
      shortcuts = {
        {
          name = "textToChat",
          key = "<leader>as",
          desc = "NeoAI: summarize text",
          use_context = true,
          prompt = [[Please summarize the following text:
```
{{text}}
```
]],
          modes = { "n", "v" },
          strip_function = nil,
        },
        {
          name = "gitCommit",
          key = "<leader>aG",
          desc = "NeoAI: generate git message",
          use_context = false,
          prompt = function()
            return [[Using the following git diff, generate a concise git commit message
following the Conventional Commits specification (feat/fix/docs/refactor/etc):

]] .. vim.fn.system("git diff --cached")
          end,
          modes = { "n" },
          strip_function = nil,
        },
      },
    })
  end,
}

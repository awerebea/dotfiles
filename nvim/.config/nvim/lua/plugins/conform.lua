return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  opts = {
    formatters_by_ft = {
      -- stylua: ignore start
      css             = { "prettierd" },
      graphql         = { "prettierd" },
      html            = { "prettierd" },
      javascript      = { "prettierd" },
      javascriptreact = { "prettierd" },
      json            = { "prettierd" },
      less            = { "prettierd" },
      markdown        = { "prettierd" },
      scss            = { "prettierd" },
      typescript      = { "prettierd" },
      typescriptreact = { "prettierd" },
      -- stylua: ignore end
      yaml = { "yamlfmt" },
      lua = { "stylua" },
      python = { "isort", "black" },
      terraform = { "terraform_fmt" },
      ["terraform-vars"] = { "terraform_fmt" },
      sh = { "shfmt" },
      bash = { "shfmt" },
      zsh = { "beautysh" },
    },
    formatters = {
      shfmt = { prepend_args = { "-i", "4" } },
      black = { prepend_args = { "--line-length=88" } },
      -- stylua: to enable column width add: prepend_args = { "--column-width", "99" }
    },
    format_on_save = function(bufnr)
      if vim.b[bufnr].disable_autoformat or not require("plugins.lsp.format").autoformat then
        return
      end
      return { timeout_ms = 5000, lsp_format = "fallback" }
    end,
  },
}

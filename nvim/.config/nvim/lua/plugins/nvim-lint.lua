return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local lint = require("lint")

    lint.linters_by_ft = {
      python = { "mypy", "refurb" },
    }

    lint.linters.mypy.args = {
      "--show-column-numbers",
      "--ignore-missing-imports",
      "--follow-imports=silent",
      "--allow-untyped-defs",
      "--allow-subclassing-any",
      "--allow-untyped-calls",
      "--strict",
    }

    lint.linters.refurb = {
      name = "refurb",
      cmd = "refurb",
      stdin = false,
      append_fname = true,
      args = { "--quiet" },
      stream = "stdout",
      ignore_exitcode = true,
      parser = require("lint.parser").from_pattern(
        "[^:]+:(%d+):(%d+) (.*)",
        { "lnum", "col", "message" },
        nil,
        { source = "refurb", severity = vim.diagnostic.severity.HINT }
      ),
    }

    vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
      callback = function()
        lint.try_lint()
      end,
    })
  end,
}

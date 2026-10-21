return {
  "mfussenegger/nvim-lint",
  -- linters are configured for Python only
  ft = "python",
  config = function()
    local lint = require("lint")

    lint.linters_by_ft = {
      python = { "mypy", "refurb" },
    }

    -- added to nvim-lint's default args, which the output parser relies on
    -- (e.g. --show-error-end); replacing them made every mypy message unparsable
    vim.list_extend(lint.linters.mypy.args, {
      "--ignore-missing-imports",
      "--follow-imports=silent",
      "--allow-untyped-defs",
      "--allow-subclassing-any",
      "--allow-untyped-calls",
      "--strict",
    })

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

    -- mypy and refurb check the file on disk (no stdin), so lint when it is
    -- read or saved; linting on InsertLeave re-checked the stale saved file
    vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost" }, {
      group = vim.api.nvim_create_augroup("nvim_lint", { clear = true }),
      callback = function()
        lint.try_lint()
      end,
    })
    -- the buffer whose FileType loaded this plugin was read already
    lint.try_lint()
  end,
}

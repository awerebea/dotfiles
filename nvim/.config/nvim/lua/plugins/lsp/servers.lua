local M = {}

local lsp_utils = require("plugins.lsp.utils")
local icons = require("config.icons")

-- hover and signature help floats (and their borders) come from noice.nvim;
-- since nvim 0.11 vim.lsp.buf.hover() no longer goes through vim.lsp.handlers
local function diagnostics_init()
  local config = {
    diagnostic = {
      -- virtual_text = false,
      -- virtual_text = { spacing = 4, prefix = "●" },
      virtual_text = {
        severity = { min = vim.diagnostic.severity.ERROR },
      },
      signs = {
        text = {
          [vim.diagnostic.severity.ERROR] = icons.diagnostics.Error,
          [vim.diagnostic.severity.WARN] = icons.diagnostics.Warning,
          [vim.diagnostic.severity.HINT] = icons.diagnostics.Hint,
          [vim.diagnostic.severity.INFO] = icons.diagnostics.Info,
        },
      },
      underline = false,
      update_in_insert = false,
      severity_sort = true,
      float = {
        focusable = true,
        style = "minimal",
        border = "rounded",
        -- source = "always",
        header = "",
        prefix = "",
        format = function(diagnostic)
          return string.format(
            "%s\n%s: %s",
            diagnostic.message,
            diagnostic.source,
            diagnostic.code
          )
        end,
      },
      -- virtual_lines = true,
      virtual_lines = false,
    },
  }

  vim.diagnostic.config(config.diagnostic)
end

function M.setup(_, opts)
  lsp_utils.on_attach(function(client, bufnr)
    require("plugins.lsp.format").on_attach(client, bufnr)
    require("plugins.lsp.keymaps").on_attach(client, bufnr)
  end)

  diagnostics_init()

  -- merged under every server's own config
  vim.lsp.config("*", { capabilities = lsp_utils.capabilities() })

  -- servers whose binary is not installed are enabled too; vim.lsp skips them
  -- until the binary is on PATH (`:checkhealth vim.lsp` lists missing ones)
  for server, server_opts in pairs(opts.servers) do
    if server_opts then
      server_opts = server_opts == true and {} or server_opts
      local handler = opts.setup[server] or opts.setup["*"]
      -- a setup handler returning true takes over starting the server
      if not (handler and handler(server, server_opts)) then
        vim.lsp.config(server, server_opts)
        vim.lsp.enable(server)
      end
    end
  end
end

return M

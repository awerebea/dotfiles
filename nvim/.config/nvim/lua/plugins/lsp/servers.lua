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

local mason_root = vim.fn.stdpath("data") .. "/mason"

local function add_mason_to_path()
  local bin = mason_root .. "/bin"
  if not vim.env.PATH:find(bin, 1, true) then
    vim.env.PATH = bin .. ":" .. vim.env.PATH
  end
end

function M.setup(_, opts)
  lsp_utils.on_attach(function(client, bufnr)
    require("plugins.lsp.format").on_attach(client, bufnr)
    require("plugins.lsp.keymaps").on_attach(client, bufnr)
  end)

  diagnostics_init()

  -- merged under every server's own config
  vim.lsp.config("*", { capabilities = lsp_utils.capabilities() })

  -- servers whose binary is not installed yet are enabled too; vim.lsp skips
  -- them until the binary exists
  local servers = opts.servers
  for server, server_opts in pairs(servers) do
    if server_opts then
      server_opts = server_opts == true and {} or vim.deepcopy(server_opts)
      server_opts.mason = nil -- our own key, see the mason spec
      local handler = opts.setup[server] or opts.setup["*"]
      -- a setup handler returning true takes over starting the server
      if not (handler and handler(server, server_opts)) then
        vim.lsp.config(server, server_opts)
        vim.lsp.enable(server)
      end
    end
  end

  -- loading mason costs ~20ms per file open and servers only need its bin dir
  -- on PATH, so load it (to install) only when something is missing
  add_mason_to_path()
  vim.schedule(function()
    if M.has_missing(servers) then
      require("lazy").load({ plugins = { "mason.nvim" } })
    end
  end)
end

---whether a mason tool or the binary of a configured server is not installed
---@param servers table<string, table|boolean>
function M.has_missing(servers)
  for _, tool in ipairs(lsp_utils.opts("mason.nvim").ensure_installed or {}) do
    if not vim.uv.fs_stat(mason_root .. "/packages/" .. tool) then
      return true
    end
  end
  for server, server_opts in pairs(servers) do
    local cmd = type(server_opts) == "table" and server_opts.mason and (vim.lsp.config[server] or {}).cmd
    -- cmd can also be a function (e.g. an RPC client); assume those are fine
    if type(cmd) == "table" and vim.fn.executable(cmd[1]) == 0 then
      return true
    end
  end
  return false
end

return M

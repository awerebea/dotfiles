local M = {}

function M.list_formatters(_)
  local ok, conform = pcall(require, "conform")
  if not ok then
    return {}
  end
  return vim.tbl_map(function(f)
    return f.name
  end, conform.list_formatters(0))
end

function M.list_linters(ft)
  local ok, lint = pcall(require, "lint")
  if not ok then
    return {}
  end
  return lint.linters_by_ft[ft] or {}
end

function M.list_completions(_)
  return {}
end

function M.list_code_actions(_)
  return {}
end

function M.list_hovers(_)
  return {}
end

function M.capabilities()
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities.textDocument.foldingRange = {
    dynamicRegistration = false,
    lineFoldingOnly = true,
  }
  -- What blink.cmp's get_lsp_capabilities() adds, written out: requiring
  -- blink.cmp here would load it (and its fuzzy matcher) on every file open
  -- instead of on InsertEnter
  capabilities.textDocument.completion =
    vim.tbl_deep_extend("force", capabilities.textDocument.completion or {}, {
      completionItem = {
        snippetSupport = true,
        commitCharactersSupport = false,
        documentationFormat = { "markdown", "plaintext" },
        deprecatedSupport = true,
        preselectSupport = false,
        tagSupport = { valueSet = { 1 } },
        insertReplaceSupport = true,
        resolveSupport = {
          properties = { "documentation", "detail", "additionalTextEdits", "command", "data" },
        },
        insertTextModeSupport = { valueSet = { 1 } },
        labelDetailsSupport = true,
      },
      completionList = {
        itemDefaults = {
          "commitCharacters",
          "editRange",
          "insertTextFormat",
          "insertTextMode",
          "data",
        },
      },
      contextSupport = true,
      insertTextMode = 1,
    })
  return capabilities
end

function M.on_attach(on_attach)
  vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
      local bufnr = args.buf
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      on_attach(client, bufnr)
    end,
  })
end

local diagnostics_active = false

function M.show_diagnostics()
  return diagnostics_active
end

function M.toggle_diagnostics()
  diagnostics_active = not diagnostics_active
  if diagnostics_active then
    vim.diagnostic.show()
  else
    vim.diagnostic.hide()
  end
end

function M.opts(name)
  local plugin = require("lazy.core.config").plugins[name]
  if not plugin then
    return {}
  end
  local Plugin = require("lazy.core.plugin")
  return Plugin.values(plugin, "opts", false)
end

return M

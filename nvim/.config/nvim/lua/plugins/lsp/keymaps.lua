local M = {}

function M.on_attach(client, buffer)
  local self = M.new(client, buffer)

  self:map("<leader>rs", "LspRestart", { desc = "Restart LSP server" })
  self:map("gd", vim.lsp.buf.definition, { desc = "Goto Definition" })
  self:map("gD", vim.lsp.buf.declaration, { desc = "Peek Definition" })
  self:map("gr", vim.lsp.buf.references, { desc = "References" })
  self:map("gf", "Telescope lsp_references", { desc = "Telescope References" })
  self:map("gI", vim.lsp.buf.implementation, { desc = "Implementations" })
  self:map("gy", function()
    require("telescope.builtin").lsp_type_definitions { reuse_win = true }
  end, { desc = "Goto Type Definition" })
  self:map("gY", function()
    require("telescope.builtin").lsp_implementations { reuse_win = true }
  end, { desc = "Goto Implementation" })
  self:map("K", vim.lsp.buf.hover, { desc = "Hover" })
  self:map("gK", vim.lsp.buf.signature_help, { desc = "Signature Help", has = "signatureHelp" })
  self:map("]d", vim.diagnostic.goto_next, { desc = "Next Diagnostic" })
  self:map("[d", vim.diagnostic.goto_prev, { desc = "Prev Diagnostic" })
  self:map("]e", function()
    vim.diagnostic.goto_next { severity = vim.diagnostic.severity.ERROR }
  end, { desc = "Next Error" })
  self:map("[e", function()
    vim.diagnostic.goto_prev { severity = vim.diagnostic.severity.ERROR }
  end, { desc = "Prev Error" })
  self:map("]w", function()
    vim.diagnostic.goto_next { severity = vim.diagnostic.severity.WARN }
  end, { desc = "Next Warning" })
  self:map("[w", function()
    vim.diagnostic.goto_prev { severity = vim.diagnostic.severity.WARN }
  end, { desc = "Prev Warning" })
  self:map(
    "<leader>ca",
    vim.lsp.buf.code_action,
    { desc = "Code Action", mode = { "n", "v" }, has = "codeAction" }
  )

  local format = require("plugins.lsp.format").format
  self:map("<leader>cf", format, { desc = "Format Document", has = "documentFormatting" })
  self:map(
    "<leader>cf",
    format,
    { desc = "Format Range", mode = "v", has = "documentRangeFormatting" }
  )
  -- self:map("<leader>rn", vim.lsp.buf.rename, { expr = true, desc = "Rename", has = "rename" })
  self:map("<leader>rn", function()
    return ":IncRename " .. vim.fn.expand "<cword>"
  end, { expr = true, desc = "Rename", has = "rename" })

  self:map(
    "<leader>cs",
    require("telescope.builtin").lsp_document_symbols,
    { desc = "Document Symbols" }
  )
  self:map(
    "<leader>cS",
    require("telescope.builtin").lsp_dynamic_workspace_symbols,
    { desc = "Workspace Symbols" }
  )
  self:map("<leader>wla", vim.lsp.buf.add_workspace_folder, { desc = "Add Workspace folder" })
  self:map(
    "<leader>wlr",
    vim.lsp.buf.remove_workspace_folder,
    { desc = "Remove Workspace folder" }
  )
  self:map("<leader>wll", function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, { desc = "Print Workspace folders" })
  self:map(
    "<leader>lw",
    require("plugins.lsp.utils").toggle_diagnostics,
    { desc = "Toggle Inline Diagnostics" }
  )
end

function M.new(client, buffer)
  return setmetatable({ client = client, buffer = buffer }, { __index = M })
end

function M:has(cap)
  return self.client.server_capabilities[cap .. "Provider"]
end

function M:map(lhs, rhs, opts)
  opts = opts or {}
  if opts.has and not self:has(opts.has) then
    return
  end
  vim.keymap.set(
    opts.mode or "n",
    lhs,
    type(rhs) == "string" and ("<cmd>%s<cr>"):format(rhs) or rhs,
    ---@diagnostic disable-next-line: no-unknown
    { silent = true, buffer = self.buffer, expr = opts.expr, desc = opts.desc }
  )
end

return M

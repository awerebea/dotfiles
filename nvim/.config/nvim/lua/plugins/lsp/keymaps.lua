local M = {}

function M.on_attach(client, buffer)
  local self = M.new(client, buffer)

  self:map("<leader>rs", "LspRestart", { desc = "Restart LSP server" })

  self:map("gd", "Lspsaga goto_definition", { desc = "Goto Definition" })
  self:map("gD", "Lspsaga peek_definition", { desc = "Peek Definition" })
  self:map("gf", "Lspsaga finder", { desc = "References" })
  self:map("gr", "Telescope lsp_references", { desc = "References" })
  self:map("gI", "Lspsaga incoming_calls", { desc = "Call hierarchy, incoming calls" })
  self:map("gO", "Lspsaga outgoing_calls", { desc = "Call hierarchy, outgoing calls" })
  -- self:map("K", "Lspsaga hover_doc ++keep", { desc = "Hover" }) -- keybind is defined in nvim-ufo settings
  self:map("gK", vim.lsp.buf.signature_help, { desc = "Signature Help", has = "signatureHelp" })
  self:map("]d", M.diagnostic_goto(true), { desc = "Next Diagnostic" })
  self:map("[d", M.diagnostic_goto(false), { desc = "Prev Diagnostic" })
  self:map("]e", M.diagnostic_goto(true, "ERROR"), { desc = "Next Error" })
  self:map("[e", M.diagnostic_goto(false, "ERROR"), { desc = "Prev Error" })
  self:map("]w", M.diagnostic_goto(true, "WARNING"), { desc = "Next Warning" })
  -- self:map("[w", M.diagnostic_goto(false, "WARNING"), { desc = "Prev Warning" })
  self:map(
    "<leader>ca",
    "Lspsaga code_action",
    { desc = "Code Action", mode = { "n", "v" }, has = "codeAction" }
  )

  local format = require("plugins.lsp.format").format
  self:map("<leader>cf", format, { desc = "Format Document", has = "documentFormatting" })
  self:map(
    "<leader>cf",
    format,
    { desc = "Format Range", mode = "v", has = "documentRangeFormatting" }
  )
  self:map("<leader>rn", M.rename, { expr = true, desc = "Rename", has = "rename" })

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
    { buffer = self.buffer, expr = opts.expr, desc = opts.desc }
  )
end

function M.rename()
  if pcall(require, "lspsaga") then
    return "<Cmd>Lspsaga rename<CR>"
  else
    return "<Cmd>lua vim.lsp.buf.rename()<CR>"
  end
end

function M.diagnostic_goto(next, severity)
  severity = severity and vim.diagnostic.severity[severity] or nil
  return function()
    if next then
      require("lspsaga.diagnostic"):goto_next { severity = severity }
    else
      require("lspsaga.diagnostic"):goto_prev { severity = severity }
    end
  end
end

return M

local M = {}

M.autoformat = true

function M.toggle()
  M.autoformat = not M.autoformat
  vim.notify(M.autoformat and "Enabled format on save" or "Disabled format on save")
end

function M.toggle_buf()
  vim.b.disable_autoformat = not vim.b.disable_autoformat
  vim.notify(
    not vim.b.disable_autoformat and "Enabled format on save (buffer)"
      or "Disabled format on save (buffer)"
  )
end

function M.format(opts)
  local buf = vim.api.nvim_get_current_buf()
  require("conform").format(vim.tbl_deep_extend("force", {
    bufnr = buf,
    timeout_ms = 5000,
    lsp_format = "fallback",
  }, opts or {}))
end

function M.on_attach(_, _)
  -- format-on-save is handled by conform.nvim's format_on_save option
end

return M

-- trigger a highlight in the appropriate direction when pressing these keys:
vim.g.qs_highlight_on_keys = { "f", "F", "t", "T" }
vim.g.qs_buftype_blacklist = { "terminal", "nofile" }
vim.g.qs_filetype_blacklist = { "dashboard", "startify" }
vim.api.nvim_set_hl(0, "QuickScopePrimary", { fg = "#ff0000", bold = true })
vim.api.nvim_set_hl(0, "QuickScopeSecondary", { fg = "#ff0000", bold = true })

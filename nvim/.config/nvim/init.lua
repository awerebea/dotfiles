if vim.g.vscode then
  require "config.vscode_options"
  require "config.vscode_lazy"
  require "config.vscode_keymaps"
else
  require "config.options"
  require "config.lazy"
  vim.api.nvim_create_autocmd("User", {
    pattern = "VeryLazy",
    callback = function()
      require "config.autocmds"
      require "config.keymaps"
    end,
  })
end

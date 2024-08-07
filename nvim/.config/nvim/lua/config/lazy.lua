--- Install lazy.nvim
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

-- Configure lazy.nvim
require("lazy").setup {
  spec = {
    { import = "plugins" },
    { import = "plugins.extras.lang" },
    { import = "plugins.extras.ui" },
    { import = "plugins.extras.ai" },
  },
  defaults = { lazy = true, version = nil },
  install = { missing = true, colorscheme = { "catppuccin" } },
  checker = {
    enabled = true,
    notify = false,
    frequency = 3600,
    check_pinned = false,
  },
  performance = {
    cache = {
      enabled = true,
    },
    rtp = {
      disabled_plugins = {
        "gzip",
        "matchit",
        "matchparen",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
}
vim.keymap.set("n", "<leader><leader>z", "<cmd>:Lazy<cr>", { desc = "Plugin Manager" })

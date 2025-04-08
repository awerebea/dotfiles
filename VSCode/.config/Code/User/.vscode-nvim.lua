-- Define a custom path for VSCode NeoVim
local vscode_nvim_path = vim.fn.stdpath "config" .. "/vscode-nvim"

-- Set runtimepath for VSCode NeoVim
vim.opt.runtimepath:prepend(vscode_nvim_path)

-- Override standard paths
vim.env.XDG_CONFIG_HOME = vscode_nvim_path
vim.env.XDG_DATA_HOME = vscode_nvim_path .. "/data"
vim.env.XDG_CACHE_HOME = vscode_nvim_path .. "/cache"

-- Bootstrap Lazy.nvim plugin manager
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

-- Use Lazy.nvim to load plugins
require("lazy").setup {
  -- VSCode specific plugins
  { "tpope/vim-surround", event = "VeryLazy" }, -- Surround text objects easily
  { "tpope/vim-commentary", event = "VeryLazy" }, -- Toggle comments easily
  { "tpope/vim-repeat", event = "VeryLazy" }, -- Enable `.` for plugin commands
  { "windwp/nvim-autopairs", event = "InsertEnter", opts = {} }, -- Auto-close brackets
  { "hrsh7th/nvim-cmp", event = "InsertEnter", opts = {} }, -- Autocompletion engine
  { "hrsh7th/cmp-nvim-lsp", event = "InsertEnter", opts = {} }, -- LSP completion
  { "hrsh7th/cmp-buffer", event = "InsertEnter", opts = {} }, -- Buffer words completion
  { "neovim/nvim-lspconfig", event = "VeryLazy" }, -- LSP support
}

-- Set options suitable for VSCode NeoVim
vim.opt.number = false
vim.opt.relativenumber = false
vim.opt.wrap = false
vim.opt.clipboard = "unnamedplus" -- Use system clipboard

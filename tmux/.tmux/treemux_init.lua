-- Neovim init.lua
-- nvim-tree recommends disabling netrw, VIM's built-in file explorer
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Remove the white status bar below
vim.o.laststatus = 0

-- True colour support
vim.o.termguicolors = true

-- lazy.nvim plugin manager
local lazypath = vim.fn.stdpath "data" .. "/lazy-treemux/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup {
  root = vim.fn.stdpath "data" .. "/lazy-treemux",
  spec = {
    {
      "kiyoon/tmuxsend.vim",
      keys = {
        { "-", "<Plug>(tmuxsend-smart)", mode = { "n", "x" } },
        { "_", "<Plug>(tmuxsend-plain)", mode = { "n", "x" } },
        { "<space>-", "<Plug>(tmuxsend-uid-smart)", mode = { "n", "x" } },
        { "<space>_", "<Plug>(tmuxsend-uid-plain)", mode = { "n", "x" } },
        { "<C-_>", "<Plug>(tmuxsend-tmuxbuffer)", mode = { "n", "x" } },
      },
    },
    "kiyoon/nvim-tree-remote.nvim",
    "folke/tokyonight.nvim",
    "nvim-tree/nvim-web-devicons",
    {
      "nvim-tree/nvim-tree.lua",
      config = function()
        local nvim_tree = require "nvim-tree"
        local nt_remote = require "nvim_tree_remote"

        nvim_tree.setup {
          update_focused_file = {
            enable = true,
            update_cwd = true,
          },
          renderer = {
            --root_folder_modifier = ":t",
            icons = {
              glyphs = {
                default = "",
                symlink = "",
                folder = {
                  arrow_open = "",
                  arrow_closed = "",
                  default = "",
                  open = "",
                  empty = "",
                  empty_open = "",
                  symlink = "",
                  symlink_open = "",
                },
                git = {
                  unstaged = "",
                  staged = "S",
                  unmerged = "",
                  renamed = "➜",
                  untracked = "U",
                  deleted = "",
                  ignored = "◌",
                },
              },
            },
          },
          diagnostics = {
            enable = true,
            show_on_dirs = true,
            icons = {
              hint = "",
              info = "",
              warning = "",
              error = "",
            },
          },
          view = {
            number = true,
            relativenumber = true,
            width = 30,
            side = "left",
            mappings = {
              list = {
                { key = "u", action = "dir_up" },
                { key = "<F1>", action = "toggle_file_info" },
                {
                  key = { "l", "<CR>", "<C-t>", "<2-LeftMouse>" },
                  action = "remote_tabnew",
                  action_cb = nt_remote.tabnew,
                },
                { key = "h", action = "close_node" },
                {
                  key = { "v", "<C-v>" },
                  action = "remote_vsplit",
                  action_cb = nt_remote.vsplit,
                },
                {
                  key = "<C-x>",
                  action = "remote_split",
                  action_cb = nt_remote.split,
                },
                {
                  key = "o",
                  action = "remote_tabnew_main_pane",
                  action_cb = nt_remote.tabnew_main_pane,
                },
              },
            },
          },
          remove_keymaps = {
            "-",
            "<C-k>",
            "O",
          },
          filters = {
            custom = { ".git" },
          },
        }
      end,
    },
    {
      "aserowy/tmux.nvim",
      config = function()
        -- Navigate tmux, and nvim splits.
        -- Sync nvim buffer with tmux buffer.
        require("tmux").setup {
          copy_sync = {
            enable = true,
            sync_clipboard = false,
            sync_registers = true,
          },
          resize = {
            enable_default_keybindings = false,
          },
        }
      end,
    },
  },
}

vim.cmd [[ colorscheme tokyonight-night ]]
vim.o.cursorline = true

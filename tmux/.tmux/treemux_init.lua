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

        local function my_on_attach(bufnr)
          local api = require "nvim-tree.api"
          local function opts(desc)
            return {
              desc = "nvim-tree: " .. desc,
              buffer = bufnr,
              noremap = true,
              silent = true,
              nowait = true,
            }
          end

          api.config.mappings.default_on_attach(bufnr)

          -- remove a default
          vim.keymap.del("n", "-", { buffer = bufnr })
          vim.keymap.del("n", "<C-k>", { buffer = bufnr })
          vim.keymap.del("n", "O", { buffer = bufnr })

          -- override a default
          vim.keymap.set("n", "<S-r>", api.tree.reload, opts "Refresh")
          vim.keymap.set("n", "u", api.tree.change_root_to_parent, opts "Up")
          vim.keymap.set("n", "<F1>", api.node.show_info_popup, opts "Info")
          vim.keymap.set("n", "h", api.node.navigate.parent_close, opts "Close Directory")
          vim.keymap.set("n", "l", api.node.open.edit, opts "Open")
          vim.keymap.set("n", "L", nt_remote.tabnew, opts "Open in remote Nvim")
          vim.keymap.set("n", "v", nt_remote.vsplit, opts "Open in vertical split in remote Nvim")
          vim.keymap.set("n", "<C-x>", nt_remote.split, opts "Open in split in remote Nvim")
          -- stylua: ignore
          vim.keymap.set("n", "o", nt_remote.tabnew_main_pane, opts "Open in new tab in remote Nvim")

          -- add your mappings
          vim.keymap.set("n", "?", api.tree.toggle_help, opts "Help")
        end

        nvim_tree.setup {
          on_attach = my_on_attach,
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

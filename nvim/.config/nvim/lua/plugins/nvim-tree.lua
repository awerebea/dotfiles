return {
  {
    "nvim-tree/nvim-tree.lua",
    cmd = { "NvimTreeToggle", "NvimTreeFindFileToggle" },
    keys = {
      { "<F2>", "<Cmd>NvimTreeToggle<CR><bar><Cmd>NvimTreeRefresh<CR>", desc = "Explorer" },
      {
        "<leader><leader><F2>",
        "<Cmd>:NvimTreeFocus<CR><bar><Cmd>NvimTreeRefresh<CR>",
        desc = "Explorer",
      },
      {
        "<leader><F2>",
        "<Cmd>NvimTreeFindFile<CR><bar><Cmd>NvimTreeRefresh<CR>",
        desc = "Explorer",
      },
    },
    opts = {
      on_attach = function(bufnr)
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
        -- use all default mappings
        api.config.mappings.default_on_attach(bufnr)
        -- remove a default
        vim.keymap.del("n", "-", { buffer = bufnr })
        -- override a default
        vim.keymap.set("n", "<C-e>", api.tree.reload, opts "Refresh")
        vim.keymap.set("n", "u", api.tree.change_root_to_parent, opts "Up")
        vim.keymap.set("n", "h", api.node.navigate.parent_close, opts "Close Directory")
        vim.keymap.set("n", "l", api.node.open.edit, opts "Open")
        vim.keymap.set("n", "F1", api.node.show_info_popup, opts "Info")
      end,
      disable_netrw = false,
      hijack_netrw = true,
      respect_buf_cwd = true,
      view = {
        side = "right",
        number = true,
        relativenumber = true,
        adaptive_size = true,
      },
      filters = {
        custom = { "^\\.git$" },
      },
      sync_root_with_cwd = true,
      prefer_startup_root = true,
      update_focused_file = {
        enable = true,
        update_root = true,
      },
      actions = {
        open_file = {
          quit_on_open = false,
          window_picker = {
            enable = true,
            picker = "default",
            chars = "FJDKSLA;EIQPWO",
            exclude = {
              filetype = { "notify", "packer", "qf", "diff", "fugitive", "fugitiveblame" },
              buftype = { "nofile", "terminal", "help" },
            },
          },
        },
      },
      renderer = {
        group_empty = true,
        icons = {
          glyphs = {
            folder = {
              arrow_closed = "", -- arrow when folder is closed
              arrow_open = "", -- arrow when folder is open
            },
          },
        },
        symlink_destination = false,
      },
      sort_by = "case_sensitive",
      --  git = {
      --    ignore = false,
      --  },
    },
    config = function(_, opts)
      -- recommended settings from nvim-tree documentation
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1
      -- change color for arrows in tree to light blue
      vim.api.nvim_command "highlight NvimTreeIndentMarker guifg=#3FC5FF"
      require("nvim-tree").setup(opts)
    end,
  },
  {
    "kiyoon/tmuxsend.vim",
    event = "VeryLazy",
    config = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "NvimTree",
        callback = function()
          vim.keymap.set({ "n", "x" }, "-", "<Plug>(tmuxsend-smart)")
          vim.keymap.set({ "n", "x" }, "_", "<Plug>(tmuxsend-plain)", { buffer = true })
          vim.keymap.set({ "n", "x" }, "<space>-", "<Plug>(tmuxsend-uid-smart)", { buffer = true })
          vim.keymap.set({ "n", "x" }, "<space>_", "<Plug>(tmuxsend-uid-plain)", { buffer = true })
          vim.keymap.set({ "n", "x" }, "<C-_>", "<Plug>(tmuxsend-tmuxbuffer)", { buffer = true })
        end,
      })
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
}

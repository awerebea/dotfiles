return {
  "gbprod/yanky.nvim",
  enabled = true,
  event = "VeryLazy",
  dependencies = {
    {
      "kkharji/sqlite.lua",
      module = "sqlite",
      config = function()
        if require("utils").is_windows() then
          vim.g.sqlite_clib_path = "C:/Program Files/sqlite/sqlite3.dll"
        end
      end,
    },
  },
  keys = {
    {
      "<leader>fc",
      function()
        require("telescope").extensions.yank_history.yank_history()
      end,
      desc = "Clipboard",
    },
  },
  config = function()
    vim.g.clipboard = {
      name = "xsel_override",
      copy = {
        ["+"] = "xsel --input --clipboard",
        ["*"] = "xsel --input --primary",
      },
      paste = {
        ["+"] = "xsel --output --clipboard",
        ["*"] = "xsel --output --primary",
      },
      cache_enabled = 1,
    }
    local utils = require "yanky.utils"
    local mapping = require "yanky.telescope.mapping"
    require("yanky").setup {
      ring = {
        history_length = 1000,
        storage = "sqlite", -- shada, sqlite or memory
        storage_path = vim.fn.stdpath "data" .. "/databases/yanky.db", -- Only for sqlite storage
        sync_with_numbered_registers = true,
        cancel_event = "update",
        ignore_registers = { "_" },
        update_register_on_cycle = false,
      },
      picker = {
        telescope = {
          mappings = {
            default = mapping.set_register(utils.get_default_register()),
            i = {
              ["<c-g>"] = mapping.put "p",
              ["<c-k>"] = mapping.put "P",
              ["<c-x>"] = mapping.delete(),
              ["<c-r>"] = mapping.set_register(utils.get_default_register()),
            },
            n = {
              p = mapping.put "p",
              P = mapping.put "P",
              d = mapping.delete(),
              r = mapping.set_register(utils.get_default_register()),
            },
          },
        },
      },
      system_clipboard = {
        sync_with_ring = true,
      },
      highlight = {
        on_put = true,
        on_yank = true,
        timer = 500,
      },
      preserve_cursor_position = {
        enabled = true,
      },
      textobj = {
        enabled = true,
      },
    }
    require("telescope").load_extension "git_worktree"
    vim.keymap.set({ "n", "x" }, "y", "<Plug>(YankyYank)")
    vim.keymap.set({ "n", "x" }, "p", "<Plug>(YankyPutAfter)")
    vim.keymap.set({ "n", "x" }, "P", "<Plug>(YankyPutBefore)")
    vim.keymap.set({ "n", "x" }, "gp", "<Plug>(YankyGPutAfter)")
    vim.keymap.set({ "n", "x" }, "gP", "<Plug>(YankyGPutBefore)")

    vim.keymap.set("n", "<c-p>", "<Plug>(YankyPreviousEntry)")
    vim.keymap.set("n", "<c-n>", "<Plug>(YankyNextEntry)")
  end,
}

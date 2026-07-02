return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    bigfile = { enabled = true },
    notifier = { enabled = true },
    quickfile = { enabled = true },
    statuscolumn = { enabled = false },
    terminal = { enabled = true },
    picker = {
      layouts = {
        default = {
          layout = {
            width = 0.999,
            height = 0.95,
            row = -1,
          },
        },
      },
      win = {
        input = {
          keys = {
            ["<M-f>"] = { "preview_scroll_down", mode = { "i", "n" } },
            ["<M-b>"] = { "preview_scroll_up", mode = { "i", "n" } },
          },
        },
      },
    },
  },
  config = function(_, opts)
    require("snacks").setup(opts)
    if vim.g.FuzzySearchKeymaps == "snacks" then
      require("plugins.snacks.keymaps").setup()
    end
    vim.api.nvim_create_user_command("Notifications", function()
      ---@diagnostic disable: undefined-global
      Snacks.notifier.show_history()
    end, { desc = "Show notification history using Snacks" })

    -- Keymaps
    vim.keymap.set("n", "gz", function()
      Snacks.bufdelete.delete()
    end, { desc = "Delete buffer" })

    vim.keymap.set("n", "gZ", function()
      Snacks.bufdelete.other()
    end, { desc = "Delete other buffers" })

    vim.keymap.set("n", "<leader>gB", function()
      Snacks.git.blame_line()
    end, { desc = "Show git log for the current line" })

    vim.keymap.set("n", "<leader>;", function()
      Snacks.terminal.toggle()
    end, { desc = "Toggle terminal" })
  end,
}

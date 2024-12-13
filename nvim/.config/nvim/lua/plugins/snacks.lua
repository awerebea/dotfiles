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
  },
  config = function(_, opts)
    require("snacks").setup(opts)
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

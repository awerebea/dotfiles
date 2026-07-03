return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    dashboard = {
      enabled = true,
      preset = {
        --stylua: ignore
        keys = {
          { icon = "", key = "f", desc = "Find file", action = ":lua Snacks.dashboard.pick('files')" },
          { icon = "", key = "n", desc = "New file", action = ":enew | startinsert" },
          { icon = "󰄉 ", key = "r", desc = "Recent files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
          { icon = "", key = "g", desc = "Find text", action = ":lua Snacks.dashboard.pick('live_grep')" },
          { icon = "", key = "c", desc = "Config", action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
          { icon = "", key = "s", desc = "Browse sessions", action = function() require("telescope").extensions.possession.list() end },
          { icon = "", key = "S", desc = "Restore session", action = ":PossessionLoadCwd" },
          { icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy", enabled = package.loaded.lazy ~= nil },
          { icon = "", key = "q", desc = "Quit", action = ":quitall" },
        },
      },
      sections = {
        function()
          return {
            header = table.concat(require("plugins.snacks.dashboard_logo")[2], "\n"),
            padding = 2,
          }
        end,
        { section = "keys", gap = 1, padding = 1 },
        { section = "startup" },
      },
    },
    bigfile = { enabled = true },
    notifier = { enabled = true },
    quickfile = { enabled = true },
    statuscolumn = { enabled = false },
    terminal = { enabled = true },
    picker = {
      sources = {
        files = { hidden = true },
        grep = { hidden = true },
        grep_word = { hidden = true },
      },
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
            ["<M-g>"] = { "toggle_live", mode = { "i", "n" } },
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

return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    dashboard = {
      enabled = true,
      preset = {
        -- stylua: ignore
        keys = {
          { icon = "", key = "f", desc = "Find file", action = ":lua Snacks.dashboard.pick('files')" },
          { icon = "", key = "n", desc = "New file", action = ":enew | startinsert" },
          { icon = "󰄉 ", key = "r", desc = "Recent files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
          { icon = "", key = "g", desc = "Find text", action = ":lua Snacks.dashboard.pick('live_grep')" },
          { icon = "", key = "c", desc = "Config", action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
          { icon = "", key = "p", desc = "Projects", action = function() require("project.extensions.snacks").pick() end },
          { icon = "", key = "s", desc = "Browse sessions", action = function() require("telescope").extensions.possession.list() end },
          { icon = "", key = "S", desc = "Restore session", action = ":PossessionLoadCwd" },
          { icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy", enabled = package.loaded.lazy ~= nil },
          { icon = "", key = "q", desc = "Quit", action = ":quitall" },
        },
      },
      sections = {
        function()
          -- stylua: ignore
          return { header = table.concat(require("plugins.snacks.dashboard_logo")[2], "\n"), padding = 0 }
        end,
        function()
          local v = vim.version()
          return {
            text = {
              { string.format("v%d.%d.%d", v.major, v.minor, v.patch), "Comment" },
            },
            align = "center",
            padding = 0,
          }
        end,
        { section = "keys", gap = 1, padding = 1 },
        { section = "startup" },
      },
    },
    bigfile = { enabled = true },
    indent = {
      enabled = true,
      indent = { hl = "Whitespace" },
      animate = {
        enabled = vim.fn.has("nvim-0.10") == 1,
        style = "out",
        easing = "linear",
        duration = {
          step = 10, -- ms per step
          total = 200, -- maximum duration
        },
      },
    },
    image = { enabled = true },
    explorer = {
      enabled = true,
      -- Keymaps (in explorer list window):
      -- l / <CR>     confirm / open
      -- h            close directory
      -- <BS>         go up to parent directory
      -- a            add file/directory
      -- d            delete
      -- r            rename
      -- c            copy
      -- m            move
      -- y            yank path (n/x)
      -- p            paste
      -- o            open with system application
      -- u            update / refresh
      -- .            focus (set as cwd)
      -- <C-c>        change tab cwd
      -- I            toggle ignored files
      -- H            toggle hidden files
      -- Z            close all directories
      -- P            toggle preview
      -- <leader>/    grep in directory
      -- <C-t>        open terminal
      -- ]g / [g      next/prev git change
      -- ]d / [d      next/prev diagnostic
      -- ]w / [w      next/prev warning
      -- ]e / [e      next/prev error
    },
    notifier = { enabled = true },
    quickfile = { enabled = true },
    statuscolumn = { enabled = true },
    terminal = {
      win = {
        height = 0.4,
      },
    },
    picker = {
      sources = {
        files = { hidden = true },
        grep = { hidden = true },
        grep_word = { hidden = true },
        explorer = {
          watch = true, -- auto-refresh tree on filesystem changes
          follow_file = true, -- reveal current buffer's file in tree on buffer switch
          git_untracked = true, -- show '?' marker for files not yet added to git
        },
        projects = {
          dev = { "~/Github" },
          max_depth = 5,
          cwd = vim.fn.expand("~"),
          -- stylua: ignore
          patterns = { ".project", ".git", "_darcs", ".hg", ".bzr", ".svn", "package.json", "Makefile" },
        },
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
    require("plugins.snacks.keymaps").setup_always()
    if vim.g.FuzzySearchKeymaps == "snacks" then
      require("plugins.snacks.keymaps").setup()
    end
    vim.api.nvim_create_user_command("Notifications", function()
      ---@diagnostic disable: undefined-global
      Snacks.notifier.show_history()
    end, { desc = "Show notification history using Snacks" })
  end,
}

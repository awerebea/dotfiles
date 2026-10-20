return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  -- <leader>gcl in visual mode uses fzf-lua (snacks has no multi-line range
  -- support for git log, so git_bcommits() with -L range is used instead);
  -- require("fzf-lua") there loads it on demand, so it is not a dependency
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
          { icon = "", key = "s", desc = "Browse sessions", action = ":PossessionPicker" },
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
    scratch = { enabled = true },
    toggle = { enabled = true },
    scope = { enabled = true },
    indent = {
      enabled = true,
      indent = { hl = "Whitespace" },
      animate = { enabled = false },
    },
    input = { enabled = true },
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
      -- Default in-picker toggle keymaps (insert and normal mode):
      --   <a-h>   toggle hidden files/dirs (show/hide dotfiles)
      --   <a-i>   toggle ignored files/dirs (respect/bypass .gitignore)
      --   <a-f>   toggle follow symlinks
      --   <a-r>   toggle regex filter
      --   <a-m>   toggle maximize layout
      --   <a-p>   toggle preview
      --   <a-w>   cycle windows (input / list / preview)
      sources = {
        files = { hidden = true },
        grep = { hidden = true },
        grep_word = { hidden = true },
        explorer = {
          watch = true, -- auto-refresh tree on filesystem changes
          follow_file = true, -- reveal current buffer's file in tree on buffer switch
          git_untracked = true, -- show '?' marker for files not yet added to git
          -- the look of the nvim-tree sidebar this explorer replaced: on the
          -- right, 50 columns, dotfiles shown except .git
          layout = { layout = { position = "right", width = 50, min_width = 50 } },
          hidden = true,
          exclude = { ".git" },
          actions = {
            -- Y: pick which form of the item's path to copy to the clipboard
            copy_path_menu = function(_, item)
              if not item then
                return
              end
              local filepath = Snacks.picker.util.path(item)
              local dirpath = vim.fs.dirname(filepath)
              local filename = vim.fs.basename(filepath)
              local modify = vim.fn.fnamemodify
              local choices = {
                { "File path absolute         ", filepath },
                { "File path relative to CWD  ", modify(filepath, ":.") },
                { "File path relative to HOME ", modify(filepath, ":~") },
                { "Dir path absolute          ", dirpath },
                { "Dir path relative to CWD   ", modify(dirpath, ":.") },
                { "Dir path relative to HOME  ", modify(dirpath, ":~") },
                { "Filename                   ", filename },
                { "File basename              ", modify(filename, ":r") },
                { "Extension of the file      ", modify(filename, ":e") },
              }
              vim.ui.select(choices, {
                prompt = "Copy to clipboard:",
                format_item = function(choice)
                  return choice[1] .. ": " .. choice[2]
                end,
              }, function(choice)
                if choice then
                  vim.fn.setreg("+", choice[2])
                  vim.notify(("Copied: `%s`"):format(choice[2]))
                end
              end)
            end,
          },
          win = {
            list = {
              keys = { ["Y"] = "copy_path_menu" },
              wo = { number = true, relativenumber = true },
            },
          },
        },
        projects = {
          dev = { "~/GitHub" },
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

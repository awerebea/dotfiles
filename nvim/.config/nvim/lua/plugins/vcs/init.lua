return {
  {
    "sindrets/diffview.nvim",
    cmd = {
      "DiffviewClose",
      "DiffviewFileHistory",
      "DiffviewFocusFiles",
      "DiffviewOpen",
      "DiffviewToggleFiles",
    },
    keys = {
      { "<leader>gdd", "<Cmd>DiffviewClose<CR>", desc = "close Diffview tab" },
      { "<leader>gdf", "<Cmd>DiffviewFileHistory %<CR>", desc = "current file history" },
      { "<leader>gdl", mode = "x", [[:DiffviewFileHistory<CR>]], desc = "selected lines history" },
      { "<leader>gdF", ":DiffviewFileHistory ", desc = "diff history repo/file/rev" },
      { "<leader>gdo", "<Cmd>DiffviewOpen<CR>", desc = "open current changes" },
      { "<leader>gdO", ":DiffviewOpen ", desc = "open changes [rev] [ -- {paths...} ]" },
    },
    config = true,
  },
  {
    "TimUntersberger/neogit",
    cmd = "Neogit",
    opts = {
      integrations = { diffview = true },
    },
    keys = {
      { "<leader>gsn", "<cmd>Neogit kind=tab<cr>", desc = "Git status (neogit)" },
    },
  },
  {
    "lewis6991/gitsigns.nvim",
    dependencies = { "petertriho/nvim-scrollbar" },
    event = "BufReadPre",
    opts = {
      signs = {
        add = {
          hl = "GitSignsAdd",
          text = "┃",
          numhl = "GitSignsAddNr",
          linehl = "GitSignsAddLn",
        },
        change = {
          hl = "GitSignsChange",
          text = "┃",
          numhl = "GitSignsChangeNr",
          linehl = "GitSignsChangeLn",
        },
        delete = {
          hl = "GitSignsDelete",
          text = "▁",
          numhl = "GitSignsDeleteNr",
          linehl = "GitSignsDeleteLn",
        },
        topdelete = {
          hl = "GitSignsDelete",
          text = "▔",
          numhl = "GitSignsDeleteNr",
          linehl = "GitSignsDeleteLn",
        },
        changedelete = {
          hl = "GitSignsChange",
          text = "~",
          numhl = "GitSignsChangeNr",
          linehl = "GitSignsChangeLn",
        },
        untracked = {
          hl = "GitSignsAdd",
          text = "┆",
          numhl = "GitSignsAddNr",
          linehl = "GitSignsAddLn",
        },
      },
      signcolumn = true, -- Toggle with `:Gitsigns toggle_signs`
      numhl = false, -- Toggle with `:Gitsigns toggle_numhl`
      linehl = false, -- Toggle with `:Gitsigns toggle_linehl`
      word_diff = false, -- Toggle with `:Gitsigns toggle_word_diff`
      watch_gitdir = {
        interval = 1000,
        follow_files = true,
      },
      attach_to_untracked = true,
      current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
      current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = "right_align", -- 'eol' | 'overlay' | 'right_align'
        delay = 1000,
        ignore_whitespace = false,
      },
      current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d> - <summary>",
      sign_priority = 6,
      update_debounce = 100,
      status_formatter = nil, -- Use default
      max_file_length = 40000, -- Disable if file is longer than this (in lines)
      preview_config = {
        -- Options passed to nvim_open_win
        border = "single",
        style = "minimal",
        relative = "cursor",
        row = 0,
        col = 1,
      },
      yadm = {
        enable = false,
      },
      -- update_debounce = 100,
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns
        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        map("n", "]c", function()
          if vim.wo.diff then
            return "]c"
          end
          vim.schedule(function()
            gs.next_hunk()
          end)
          return "<Ignore>"
        end, { expr = true })

        map("n", "[c", function()
          if vim.wo.diff then
            return "[c"
          end
          vim.schedule(function()
            gs.prev_hunk()
          end)
          return "<Ignore>"
        end, { expr = true })

        -- Actions
        map({ "n", "v" }, "ghs", ":Gitsigns stage_hunk<CR>", { desc = "Stage Hunk" })
        map({ "n", "v" }, "ghr", ":Gitsigns reset_hunk<CR>", { desc = "Reset Hunk" })
        map("n", "ghS", gs.stage_buffer, { desc = "Stage Buffer" })
        map("n", "ghu", gs.undo_stage_hunk, { desc = "Undo Stage Hunk" })
        map("n", "ghR", gs.reset_buffer, { desc = "Reset Buffer" })
        map("n", "ghp", gs.preview_hunk, { desc = "Preview Hunk" })
        map("n", "ghb", function()
          gs.blame_line { full = true }
        end, { desc = "Blame Line" })
        map("n", "ghtb", gs.toggle_current_line_blame, { desc = "Toggle Line Blame" })
        map("n", "ghd", gs.diffthis, { desc = "Diff This" })
        map("n", "ghD", function()
          gs.diffthis "~"
        end, { desc = "Diff This ~" })
        map("n", "ghtd", gs.toggle_deleted, { desc = "Toggle Delete" })

        -- Text object
        map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", { desc = "Select Hunk" })
      end,
    },
    config = function(_, opts)
      require("gitsigns").setup(opts)
      require("scrollbar.handlers.gitsigns").setup()
    end,
  },
  {
    "mattn/vim-gist",
    dependencies = { "mattn/webapi-vim" },
    cmd = { "Gist" },
    config = function()
      vim.g.gist_open_browser_after_post = 1
    end,
  },
  {
    "akinsho/git-conflict.nvim",
    cmd = {
      "GitConflictRefresh",
      "GitConflictListQf",
    },
    keys = {
      { "<leader>gcr", "<Cmd>GitConflictRefresh<CR>" },
      { "<leader>gcq", "<Cmd>GitConflictListQf<CR>" },
    },
    opts = {
      default_mappings = {
        ours = "co",
        theirs = "ct",
        none = "c0",
        both = "cb",
        next = "]x",
        prev = "[x",
      },
    },
    config = function(_, opts)
      require("git-conflict").setup(opts)
    end,
  },
  {
    "kdheepak/lazygit.nvim",
    cmd = {
      "LazyGit",
      "LazyGitConfig",
      "LazyGitCurrentFile",
      "LazyGitFilter",
      "LazyGitFilterCurrentFile",
    },
    keys = {
      { "<leader>gg", "<Cmd>LazyGit<CR>", desc = "LazyGit" },
    },
  },
  {
    "tanvirtin/vgit.nvim",
    event = "BufReadPost",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    -- stylua: ignore
    keys = {
      { "<C-k>", function() require('vgit').hunk_up() end, desc = "Moves to the previous hunk" },
      { "<C-j>", function() require('vgit').hunk_down() end, desc = "Moves to the next hunk" },
      { "<leader>vgs", function() require('vgit').buffer_hunk_stage() end, desc = "Stage the current hunk" },
      { "<leader>vgr", function() require('vgit').buffer_hunk_reset() end, desc = "Reset the current hunk" },
      { "<leader>vgp", function() require('vgit').buffer_hunk_preview() end, desc = "Preview the current hunk" },
      { "<leader>vgb", function() require('vgit').buffer_blame_preview() end, desc = "Line blame preview" },
      { "<leader>vgf", function() require('vgit').buffer_diff_preview() end, desc = "File diff preview" },
      { "<leader>vgh", function() require('vgit').buffer_history_preview() end, desc = "File history preview" },
      { "<leader>vgu", function() require('vgit').buffer_reset() end, desc = "Reset all changes in the file" },
      { "<leader>vgg", function() require('vgit').buffer_gutter_blame_preview() end, desc = "File blame preview" },
      { "<leader>vglu", function() require('vgit').project_hunks_preview() end, desc = "Preview all hunks in the repo" },
      { "<leader>vgls", function() require('vgit').project_hunks_staged_preview() end, desc = "Preview all staged hunks in the repo" },
      { "<leader>vgd", function() require('vgit').project_diff_preview() end, desc = "Git repo diff" },
      { "<leader>vgq", function() require('vgit').project_hunks_qf() end, desc = "Populate the quickfix list with hunks" },
      { "<leader>vgx", function() require('vgit').toggle_diff_preference() end, desc = 'switch between "split" and "unified" diff' },
    },
    cmd = {
      "VGit",
    },
    opts = {
      settings = {
        live_blame = {
          enabled = false,
          format = function(blame, git_config)
            local config_author = git_config["user.name"]
            local author = blame.author
            if config_author == author then
              author = "You"
            end
            local time = os.difftime(os.time(), blame.author_time) / (60 * 60 * 24 * 30 * 12)
            local time_divisions = {
              { 1, "years" },
              { 12, "months" },
              { 30, "days" },
              { 24, "hours" },
              { 60, "minutes" },
              { 60, "seconds" },
            }
            local counter = 1
            local time_division = time_divisions[counter]
            local time_boundary = time_division[1]
            local time_postfix = time_division[2]
            while time < 1 and counter ~= #time_divisions do
              time_division = time_divisions[counter]
              time_boundary = time_division[1]
              time_postfix = time_division[2]
              time = time * time_boundary
              counter = counter + 1
            end
            local commit_message = blame.commit_message
            if not blame.committed then
              author = "You"
              commit_message = "Uncommitted changes"
              return string.format(" %s • %s", author, commit_message)
            end
            local max_commit_message_length = 255
            if #commit_message > max_commit_message_length then
              commit_message = commit_message:sub(1, max_commit_message_length) .. "..."
            end
            return string.format(
              " %s, %s • %s",
              author,
              string.format(
                "%s %s ago",
                time >= 0 and math.floor(time + 0.5) or math.ceil(time - 0.5),
                time_postfix
              ),
              commit_message
            )
          end,
        },
        live_gutter = {
          enabled = false,
          edge_navigation = true, -- This allows users to navigate within a hunk
        },
        authorship_code_lens = {
          enabled = false,
        },
        scene = {
          diff_preference = "unified", -- unified or split
          keymaps = {
            quit = "q",
          },
        },
        diff_preview = {
          keymaps = {
            buffer_stage = "S",
            buffer_unstage = "U",
            buffer_hunk_stage = "s",
            buffer_hunk_unstage = "u",
            toggle_view = "t",
          },
        },
        project_diff_preview = {
          keymaps = {
            buffer_stage = "s",
            buffer_unstage = "u",
            buffer_hunk_stage = "gs",
            buffer_hunk_unstage = "gu",
            buffer_reset = "r",
            stage_all = "S",
            unstage_all = "U",
            reset_all = "R",
          },
        },
        project_commit_preview = {
          keymaps = {
            save = "S",
          },
        },
        signs = {
          priority = 10,
          definitions = {
            GitSignsAddLn = {
              linehl = "GitSignsAddLn",
              texthl = nil,
              numhl = nil,
              icon = nil,
              text = "",
            },
            GitSignsDeleteLn = {
              linehl = "GitSignsDeleteLn",
              texthl = nil,
              numhl = nil,
              icon = nil,
              text = "",
            },
            GitSignsAdd = {
              texthl = "GitSignsAdd",
              numhl = nil,
              icon = nil,
              linehl = nil,
              text = "┃",
            },
            GitSignsDelete = {
              texthl = "GitSignsDelete",
              numhl = nil,
              icon = nil,
              linehl = nil,
              text = "┃",
            },
            GitSignsChange = {
              texthl = "GitSignsChange",
              numhl = nil,
              icon = nil,
              linehl = nil,
              text = "┃",
            },
          },
          usage = {
            screen = {
              add = "GitSignsAddLn",
              remove = "GitSignsDeleteLn",
            },
            main = {
              add = "GitSignsAdd",
              remove = "GitSignsDelete",
              change = "GitSignsChange",
            },
          },
        },
        symbols = {
          void = "⣿",
        },
      },
    },
  },
}

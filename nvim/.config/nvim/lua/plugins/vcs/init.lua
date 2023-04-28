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
      { "<leader>gdc", "<Cmd>DiffviewClose<CR>", desc = "DiffviewClose" },
      { "<leader>gdf", "<Cmd>DiffviewFileHistory %<CR>", desc = "DiffviewFileHistory" },
      { "<leader>gdF", ":DiffviewFileHistory ", desc = "DiffviewFileHistory" },
      { "<leader>gdo", "<Cmd>DiffviewOpen<CR>", desc = "DiffviewOpen" },
      { "<leader>gdO", ":DiffviewOpen ", desc = "DiffviewOpen" },
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
      { "<leader>gsn", "<cmd>Neogit kind=tab<cr>", desc = "Status" },
    },
  },
  {
    "tpope/vim-fugitive",
    cmd = { "Git", "GBrowse", "Gdiffsplit", "Gvdiffsplit" },
    dependencies = {
      "tpope/vim-rhubarb",
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
    config = function()
      require("git-conflict").setup()
    end,
  },
  {
    "kdheepak/lazygit.nvim",
    keys = {
      { "<leader>gg", "<Cmd>LazyGit<CR>", desc = "LazyGit" },
    },
  },
}

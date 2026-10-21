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
      { "<leader>gdd", "<Cmd>DiffviewClose<CR>", desc = "Close Diffview tab" },
      { "<leader>gdf", "<Cmd>DiffviewFileHistory %<CR>", desc = "Current file history" },
      { "<leader>gdl", mode = "x", [[:DiffviewFileHistory<CR>]], desc = "Selected lines history" },
      { "<leader>gdF", ":DiffviewFileHistory ", desc = "Diff history repo/file/rev" },
      { "<leader>gdo", "<Cmd>DiffviewOpen<CR>", desc = "Open current changes" },
      { "<leader>gdO", ":DiffviewOpen ", desc = "Open changes [rev] [-- {paths}]" },
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
      { "<leader>gsn", "<cmd>Neogit kind=tab<cr>", desc = "Git status (Neogit)" },
    },
  },
  {
    "lewis6991/gitsigns.nvim",
    dependencies = { "petertriho/nvim-scrollbar" },
    event = "BufReadPre",
    opts = {
      watch_gitdir = {
        interval = 1000,
      },
      attach_to_untracked = true,
      current_line_blame_opts = {
        virt_text_pos = "right_align", -- 'eol' | 'overlay' | 'right_align'
      },
      sign_priority = 100,
      max_file_length = 40000, -- Disable if file is longer than this (in lines)
      -- update_debounce = 100,
      preview_config = {
        border = "rounded",
        style = "minimal",
        relative = "cursor",
        row = 0,
        col = 1,
      },
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
        map("n", "ghP", function()
          require("gitsigns.config").config.preview_config.width = math.floor(vim.o.columns * 0.99)
          gs.preview_hunk()
        end, { desc = "Preview Hunk" })
        map("n", "ghi", gs.preview_hunk_inline, { desc = "Preview Hunk Inline" })
        map("n", "ghb", function()
          gs.blame_line({ full = true })
        end, { desc = "Blame Line" })
        map("n", "ghB", "<Cmd>Gitsigns blame<CR>", { desc = "Blame File" })
        map("n", "ghtb", gs.toggle_current_line_blame, { desc = "Toggle Line Blame" })
        map("n", "ghd", gs.diffthis, { desc = "Diff This" })
        map("n", "ghD", function()
          gs.diffthis("~")
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
    -- dims gitsigns gutter cells that difftastic considers formatting-only noise
    -- requires difftastic (difft) 0.70/0.71 on PATH
    "janbuchar/difftsigns.nvim",
    dependencies = { "lewis6991/gitsigns.nvim" },
    event = "BufReadPre",
    cmd = { "DifftSigns" },
    keys = {
      {
        "ghp",
        function()
          require("difftsigns").preview()
        end,
        desc = "Preview Hunk (difftastic)",
      },
      { "ghtn", "<Cmd>DifftSigns toggle<CR>", desc = "Toggle Difft Noise Dimming" },
      { "ghn", "<Cmd>DifftSigns status<CR>", desc = "Difft Noise Status" },
      { "ghf", "<Cmd>DifftSigns refresh<CR>", desc = "Difft Refresh" },
    },
    opts = {
      -- difft's default (3M) often gives up on heavily changed files after
      -- the same time a 5M run needs to succeed; costs more peak memory
      graph_limit = 5000000,
    },
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
      { "<leader>gcr", "<Cmd>GitConflictRefresh<CR>", desc = "Refresh conflicts" },
      { "<leader>gcq", "<Cmd>GitConflictListQf<CR>", desc = "Conflicts to quickfix" },
    },
    config = true,
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
      { "<leader>glz", "<Cmd>LazyGit<CR>", desc = "LazyGit" },
    },
  },
  {
    -- only used for the file history preview below; its live features are
    -- disabled (gitsigns covers them), so it does not load with every file
    "tanvirtin/vgit.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      {
        "<leader>gh",
        function()
          require("vgit").buffer_history_preview()
        end,
        desc = "VGit file history preview",
      },
    },
    cmd = { "VGit" },
    opts = {
      settings = {
        live_blame = { enabled = false },
        live_gutter = { enabled = false },
        authorship_code_lens = { enabled = false },
      },
    },
  },
}

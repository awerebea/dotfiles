return {
  "awerebea/git-worktrees.nvim",
  -- dir = vim.fn.expand("~/Github/git-worktrees.nvim"),
  dependencies = { "folke/snacks.nvim" },

  -- Lazy-load: plugin is loaded on first keymap press or command use.
  -- No need for event = "VeryLazy" - keys/cmd already cover both entry points.
  keys = {
    {
      "<leader>gwt",
      function()
        require("git-worktrees").worktrees()
      end,
      desc = "Worktree total",
    },
    {
      "<leader>gwa",
      function()
        require("git-worktrees").worktrees_add()
      end,
      desc = "Worktree add",
    },
    {
      "<leader>gwm",
      function()
        require("git-worktrees").worktrees_manage()
      end,
      desc = "Worktree manage",
    },
    {
      "<leader>gbm",
      function()
        require("git-worktrees").branches()
      end,
      desc = "Branch management",
    },
  },
  cmd = { "GitWorktreeTotal", "GitWorktreeAdd", "GitWorktreeManage", "GitBranchManage" },

  -- config = true would also work here: Lazy derives the module name
  -- ("git-worktrees") from the dir basename and calls .setup(opts).
  -- Using the explicit form for clarity.
  opts = {
    -- Path display mode for the worktree path column.
    -- "tilde" (default) | "absolute" | "relative-cwd" | "relative-home" | "relative-repo" | "relative-wt-base" | "relative-gitdir" | "absolute-gitdir" | "tilde-gitdir"
    -- Overriding the default ("tilde") to show paths relative to the repo working tree root.
    wt_path_display = "relative-home",

    -- Template for the worktree base path. {repo_name} / {repo_name_short} expand
    -- to the repository name. Relative paths anchor to the git common directory.
    wt_base_path_bare = "./wt", -- default
    wt_base_path_regular = "./wt", -- default

    -- false: show pre-filled path prompt before creating (default)
    -- true:  silently use <base_path>/<branch_name>
    auto_worktree_path = true,

    -- Branch scope shown on picker open. Cycle with <M-g>.
    -- "local" (default) | "remote" | "all"
    branch_type = "local",

    -- Sort field for git for-each-ref.
    -- "-committerdate" (default) | "-authordate" | "refname" | "-version:refname"
    sort_by = "-committerdate",

    -- Date column format passed as committerdate:<format> to git for-each-ref.
    -- "relative" (default) | "short" | "iso" | "human" | "format:STRFTIME"
    date_format = "relative",

    -- Author column field. "name" -> committername (default), "email" -> committeremail
    author_format = "name",

    -- Buffer swap on worktree switch.
    -- false (default) | true | "ask"
    swap_current_buffer = true, -- default

    -- Vim command used to open the swapped file. nil to skip opening.
    -- "edit" (default) | "tabedit" | "vsplit" | "split" | nil
    switch_file_command = "vsplit",

    -- Timeout in ms for plugin notifications. nil (default) uses the notification handler's own default.
    notify_timeout = nil,

    -- Timeout in ms for the branch info popup opened by <C-o>. 0 = keep until dismissed.
    branch_info_timeout = 5000, -- default

    -- Timeout in ms for the git-status popup shown before a force-delete confirm. 0 = keep until dismissed (default).
    status_win_timeout = 0,

    -- Lifecycle hooks.
    hooks = {}, -- default
  },
  config = function(_, opts)
    require("git-worktrees").setup(opts)
  end,
}

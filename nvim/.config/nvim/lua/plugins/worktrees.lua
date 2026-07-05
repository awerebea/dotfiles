return {
  "Juksuu/worktrees.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  cmd = {
    "GitWorktreeCreate",
    "GitWorktreeCreateExisting",
    "GitWorktreeSwitch",
    "GitWorktreeRemove",
  },
  keys = {
    {
      "<leader>gwa",
      function()
        require("worktrees").new_worktree(true)
      end,
      desc = "Worktree for existing branch",
    },
    {
      "<leader>gwn",
      function()
        require("worktrees").new_worktree()
      end,
      desc = "New worktree (new branch)",
    },
    {
      "<leader>gwt",
      function()
        Snacks.picker.worktrees()
      end,
      desc = "Switch worktree",
    },
    {
      "<leader>gwd",
      function()
        Snacks.picker.worktrees_remove()
      end,
      desc = "Remove worktree",
    },
  },
  opts = {
    hooks = {
      on_add = function(name, path, branch)
        vim.notify("Worktree created: " .. name .. " (" .. branch .. ")", vim.log.levels.INFO)
      end,
      on_switch = function(from, to)
        vim.notify("Switched to worktree: " .. vim.fn.fnamemodify(to, ":t"), vim.log.levels.INFO)
      end,
      on_remove = function(name)
        vim.notify("Worktree removed: " .. name, vim.log.levels.WARN)
      end,
    },
  },
}

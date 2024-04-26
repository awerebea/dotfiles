return {
  "ThePrimeagen/git-worktree.nvim",
  opts = {},
  config = function()
    require("telescope").load_extension "git_worktree"
    local Worktree = require "git-worktree"
    Worktree.on_tree_change(function(op, metadata)
      if op == Worktree.Operations.Switch then
        print("Switched from " .. metadata.prev_path .. " to " .. metadata.path)
      elseif op == Worktree.Operations.Create then
        print(
          "Worktree created: "
            .. metadata.path
            .. " for branch "
            .. metadata.branch
            .. " with upstream "
            .. metadata.upstream
        )
      elseif op == Worktree.Operations.Delete then
        print("Worktree deleted: " .. metadata.path)
      end
    end)
  end,
  dependencies = {
    "nvim-telescope/telescope.nvim",
  },
  keys = {
    {
      "<leader>gwm",
      function()
        require("telescope").extensions.git_worktree.git_worktrees { path_display = {} }
      end,
      desc = "Manage",
    },
    {
      "<leader>gwa",
      function()
        require("telescope").extensions.git_worktree.create_git_worktree()
      end,
      desc = "Add",
    },
  },
}

return {
  {
    "awerebea/git-tabscopes.nvim",
    -- dir = vim.fn.expand("~/Github/git-tabscopes.nvim"),
    event = "VeryLazy",
    dependencies = { "folke/snacks.nvim" },
    -- stylua: ignore
    keys = {
      { "<leader>bw",  function() require("git-tabscopes.pickers").workspace_buffers() end,        desc = "Tabscope: workspace repo buffers" },
      { "<leader>bW",  function() require("git-tabscopes.pickers").workspace_branch_buffers() end, desc = "Tabscope: workspace repo + branch buffers" },
      { "<leader>br",  function() require("git-tabscopes.pickers").repo_buffers() end,             desc = "Tabscope: current repo buffers" },
      { "<leader>bR",  function() require("git-tabscopes.pickers").repo_branch_buffers() end,      desc = "Tabscope: current repo + branch buffers" },
      { "<leader>gto", "<Cmd>GitTabscopesOrganize<CR>",                                            desc = "Tabscope: organize workspaces" },
      { "<leader>gtc", "<Cmd>GitTabscopesClean<CR>",                                               desc = "Tabscope: clean workspaces" },
      { "<leader>gtl", function() require("git-tabscopes").lock_toggle() end,                      desc = "Tabscope: toggle workspace lock" },
    },
    cmd = {
      "GitTabscopesOrganize",
      "GitTabscopesClean",
      "GitTabscopesLock",
      "GitTabscopesUnlock",
      "GitTabscopesLockToggle",
      "GitTabscopesClearCache",
    },
    opts = {
      disable_default_keymaps = true, -- keymaps are managed above via keys = {}
    },
    config = function(_, opts)
      require("git-tabscopes").setup(opts)
    end,
  },
}

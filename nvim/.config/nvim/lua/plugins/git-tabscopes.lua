return {
  {
    "awerebea/git-tabscopes.nvim",
    -- dir = vim.fn.expand("~/Github/git-tabscopes.nvim"),
    event = "VeryLazy",
    dependencies = { "folke/snacks.nvim" },
    -- stylua: ignore
    keys = {
      { "<leader>bw",   function() require("git-tabscopes.pickers").workspace_buffers({ current = false }) end,         desc = "Tabscope: workspace repo buffers" },
      { "<leader>bW",   function() require("git-tabscopes.pickers").workspace_branch_buffers({ current = false }) end,  desc = "Tabscope: workspace repo + branch buffers" },
      { "<leader>br",   function() require("git-tabscopes.pickers").repo_buffers() end,                                 desc = "Tabscope: current repo buffers" },
      { "<leader><CR>", function() require("git-tabscopes.pickers").repo_buffers({ current = false }) end,              desc = "Tabscope: current repo buffers" },
      { "<leader>bR",   function() require("git-tabscopes.pickers").repo_branch_buffers({ current = false }) end,       desc = "Tabscope: current repo + branch buffers" },
      { "<leader>gtl",  function() require("git-tabscopes").lock_toggle() end,                                          desc = "Tabscope: toggle workspace lock" },
      { "<leader>gto",  function() require("git-tabscopes").organize() end,                                             desc = "Tabscope: organize workspaces" },
      { "<leader>gtc",  function() require("git-tabscopes").clean() end,                                                desc = "Tabscope: clean workspaces" },
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
      -- String prepended to the tab label when the workspace is locked.
      -- Default: "🔒 "
      lock_indicator = "🔒 ",

      -- Maximum characters for the repo name in the tab label (nil = no limit).
      -- When two names truncate to the same string a -1/-2 suffix disambiguates.
      -- Default: nil
      tab_name_max_length = nil,

      -- Milliseconds of event silence before the tracker re-evaluates the anchor
      -- window. Raise this if a window-layout plugin fires many rapid events.
      -- Default: 50
      debounce_ms = 50,

      -- Register the built-in keymaps when setup() is called.
      -- Keep false when keymaps are managed via lazy keys = {} (as done here).
      -- Default: false
      enable_default_keymaps = false,
    },
    config = function(_, opts)
      require("git-tabscopes").setup(opts)
    end,
  },
}

return {
  "cbochs/grapple.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  cmd = "Grapple",

  -- Lazy-load on first keymap press or command.
  keys = {
    {
      "<leader>m",
      function()
        require("grapple").toggle()
      end,
      desc = "Grapple tag toggle",
    },
    {
      "<leader><leader>m",
      function()
        require("grapple").toggle_tags()
      end,
      desc = "Grapple tags",
    },
    {
      "[g",
      function()
        require("grapple").cycle_tags("prev")
      end,
      desc = "Prev grapple tag",
    },
    {
      "]g",
      function()
        require("grapple").cycle_tags("next")
      end,
      desc = "Next grapple tag",
    },
  },

  opts = {
    -- Tags are namespaced per git repo. Switching repos gives you a fresh list.
    scope = "git",

    -- Show file paths relative to the git root (cleaner than absolute).
    style = "relative",

    -- Show the tag name (if set via R in the window) after the path.
    name_pos = "end",

    -- Press 1-9 inside the tags window to jump instantly.
    quick_select = "123456789",

    -- Requires nvim-web-devicons (already a dep above).
    icons = true,

    -- Remove save files older than 30 days automatically.
    prune = "30d",

    win_opts = {
      width = 80,
      height = 12,
      border = "rounded",
    },
  },
}

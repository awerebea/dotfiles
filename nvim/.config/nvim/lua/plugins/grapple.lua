return {
  "cbochs/grapple.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  cmd = "Grapple",

  -- Lazy-load on first keymap press or command.
  keys = (function()
    local k = {
      {
        "<leader>m",
        function()
          local grapple = require("grapple")
          if grapple.exists() then
            if vim.fn.confirm("Remove grapple tag?", "&Yes\n&No", 2) == 1 then
              grapple.untag()
            end
          else
            grapple.tag()
          end
        end,
        desc = "Grapple tag toggle",
      },
      {
        "<leader><leader>m",
        function() require("grapple").toggle_tags() end,
        desc = "Grapple tags",
      },
      {
        "[g",
        function() require("grapple").cycle_tags("prev") end,
        desc = "Prev grapple tag",
      },
      {
        "]g",
        function() require("grapple").cycle_tags("next") end,
        desc = "Next grapple tag",
      },
    }
    -- <leader><leader>1-9 jump to tags 1-9; <leader><leader>0 jumps to tag 10.
    for i = 1, 9 do
      table.insert(k, {
        "<leader><leader>" .. i,
        function() require("grapple").select({ index = i }) end,
        desc = "Grapple tag " .. i,
      })
    end
    table.insert(k, {
      "<leader><leader>0",
      function() require("grapple").select({ index = 10 }) end,
      desc = "Grapple tag 10",
    })
    return k
  end)(),

  opts = {
    -- Tags are namespaced per git repo. Switching repos gives you a fresh list.
    scope = "git",

    -- Show file paths relative to the git root (cleaner than absolute).
    style = "relative",

    -- Show the tag name (if set via R in the window) after the path.
    name_pos = "end",

    -- Press 1-9 or 0 (slot 10) inside the tags window to jump instantly.
    quick_select = "1234567890",

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

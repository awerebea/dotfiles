return {
  "domharries/foldnav.nvim",
  event = "VeryLazy",
  version = "*",
  config = function()
    vim.g.foldnav = { flash = { enabled = true } }
  end,
  -- stylua: ignore
  keys = {
    { "zh", function() require("foldnav").goto_start() end, desc = "Start of the enclosing fold" },
    { "zj", function() require("foldnav").goto_next() end, desc = "Start of next fold" },
    { "zk", function() require("foldnav").goto_prev_start() end, desc = "The most recent place that a fold started" },
    -- { "zk", function() require("foldnav").goto_prev_end() end, desc = "End of the previous fold" },
    { "zl", function() require("foldnav").goto_end() end, desc = "End of the enclosing fold" },
    { "zn", function() require("foldnav").goto_end(); require("foldnav").goto_next() end, desc = "Next fold of the same level" },
    { "zp", function() require("foldnav").goto_prev_end(); require("foldnav").goto_start() end, desc = "Previous fold of the same level" },
  },
}

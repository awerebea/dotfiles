return {
  "chentoast/marks.nvim",
  event = "VeryLazy",
  opts = {
    force_write_shada = true,
    -- re-scan marks once a second instead of every 150 ms (marks set with m
    -- show up immediately either way)
    refresh_interval = 1000,
  },
}

return {
  "petertriho/nvim-scrollbar",
  event = "BufReadPre",
  opts = { marks = { GitChange = { text = "│" } } },
  config = function(_, otps)
    require("scrollbar").setup(otps)
  end,
}

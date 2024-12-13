return {
  "petertriho/nvim-scrollbar",
  event = "BufReadPre",
  opts = { marks = { GitChange = { text = "│" } } },
}

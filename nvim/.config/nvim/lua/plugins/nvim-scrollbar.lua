return {
  "petertriho/nvim-scrollbar",
  -- v2 draws the scrollbar as a floating window, and a float over a window
  -- makes Neovim repaint the whole window on every scroll instead of using
  -- terminal scrolling (about 7x more terminal output per j)
  branch = "v1",
  event = "BufReadPre",
  opts = { marks = { GitChange = { text = "│" } } },
}

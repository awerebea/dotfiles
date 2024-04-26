return {
  "ojroques/nvim-bufdel",
  cmd = {
    "BufDel",
    "BufDelAll",
    "BufDelOthers",
  },
  keys = {
    { "gz", "<Cmd>BufDel<CR>", desc = "Delete buffer" },
    { "gZ", "<Cmd>BufDelOthers<CR>", desc = "Delete other buffers" },
  },
  opts = { next = "tabs", quit = false },
  config = true,
}

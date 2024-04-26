return {
  "simeji/winresizer",
  cmd = "WinResizerStartResize",
  keys = { "<C-e>" },
  config = function(_, _)
    vim.g.winresizer_finish_with_escape = 1
    vim.g.winresizer_vert_resize = 3
    vim.g.winresizer_horiz_resize = 3
  end,
}

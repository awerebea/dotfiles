return {
  enabled = false,
  "preservim/nerdcommenter",
  event = "VeryLazy",
  cmd = { "NERDCommenterToggle" },
  keys = {
    { "<C-_>", "<Plug>NERDCommenterToggle", desc = "Toggle comment for current line" },
    { "<leader>c<space>", "<Plug>NERDCommenterToggle", desc = "Toggle comment for current line" },
    {
      "<C-_>",
      "<Plug>NERDCommenterToggle<CR>gv",
      mode = "v",
      desc = "Toggle comment for current line",
    },
    {
      "<leader>c<space>",
      "<Plug>NERDCommenterToggle<CR>gv",
      mode = "v",
      desc = "Toggle comment for current line",
    },
  },
  config = function()
    vim.g.NERDSpaceDelims = 1
    -- custom formats or override the defaults
    vim.g.NERDCustomDelimiters = {
      c = { left = "/*", right = "*/" },
      vim = { left = '"', right = "" },
      lua = { left = "--", right = "" },
      hcl = { left = "# ", right = "" },
      cpp = { left = "/*", right = "*/" },
      Jenkinsfile = { left = "//", right = "" },
    }

    -- Align line-wise comment delimiters flush left instead of following code
    -- indentation (left/both)
    vim.g.NERDDefaultAlign = "both"
    -- Allow commenting and inverting empty lines (useful when commenting a region)
    vim.g.NERDCommentEmptyLines = 0
    -- Use compact syntax for prettified multi-line comments
    vim.g.NERDCompactSexyComs = 0
    -- Enable trimming of trailing whitespace when uncommenting
    vim.g.NERDTrimTrailingWhitespace = 1
    vim.g.NERDDisableTabsInBlockComm = 1
  end,
}

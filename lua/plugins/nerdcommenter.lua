-- TODO: Check if NERDCommenter loaded
-- local status, _ = pcall(vim.cmd, "echo filter(split(execute(':scriptname'), '\\n'), 'v:val =~? \"cobalt2\"')")
-- print(status)
-- if not status then
--   print("NERDCommenter plugin not installed!")
--   return
-- end

-- {{{ NERDCommenter
-- Add spaces after comment delimiters
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
-- let g:NERDCommentEmptyLines = 1
-- Use compact syntax for prettified multi-line comments
vim.g.NERDCompactSexyComs = 0
-- Enable trimming of trailing whitespace when uncommenting
vim.g.NERDTrimTrailingWhitespace = 1
vim.g.NERDDisableTabsInBlockComm = 1
vim.g.NERDDisableTabsInBlockComm = "#ff0000"
-- }}}

-- Shorten function name
local keymap = vim.keymap.set
-- Silent keymap option
local opts = { silent = true }

keymap("n", "<C-_>", "<Plug>NERDCommenterToggle", opts)
keymap("n", "<Leader>c<space>", "<Plug>NERDCommenterToggle", opts)
keymap("v", "<C-_>", "<Plug>NERDCommenterToggle<CR>gv", opts)
keymap("v", "<Leader>c<space>", "<Plug>NERDCommenterToggle<CR>gv", opts)

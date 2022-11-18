-- TODO Check if NERDCommenter loaded
-- local status, _ = pcall(vim.cmd, "echo filter(split(execute(':scriptname'), '\\n'), 'v:val =~? \"cobalt2\"')")
-- print(status)
-- if not status then
--   print("NERDCommenter plugin not installed!")
--   return
-- end

-- {{{ NERDCommenter
vim.cmd([[
  " Add spaces after comment delimiters
  let g:NERDSpaceDelims = 1
  " custom formats or override the defaults
  let g:NERDCustomDelimiters = { 'c': { 'left': '/*','right': '*/' } }
  let g:NERDCustomDelimiters = { 'vim': { 'left': '"','right': '' } }
  let g:NERDCustomDelimiters = { 'lua': { 'left': '-- ','right': '' } }
  " let g:NERDCustomDelimiters = { 'cpp': { 'left': '/*','right': '*/' } }
  let g:NERDCustomDelimiters = { 'Jenkinsfile': { 'left': '//','right': '' } }
  " Align line-wise comment delimiters flush left instead of following code
  " indentation (left/both)
  let g:NERDDefaultAlign = 'both'
  " Allow commenting and inverting empty lines (useful when commenting a region)
  " let g:NERDCommentEmptyLines = 1
  " Use compact syntax for prettified multi-line comments
  let g:NERDCompactSexyComs = 0
  " Enable trimming of trailing whitespace when uncommenting
  let g:NERDTrimTrailingWhitespace = 1
  let g:NERDDisableTabsInBlockComm = 1
]])
-- }}}

-- Shorten function name
local keymap = vim.keymap.set
-- Silent keymap option
local opts = { silent = true }

keymap("n", "<C-_>", "<Plug>NERDCommenterToggle", opts)
keymap("n", "<Leader>c<space>", "<Plug>NERDCommenterToggle", opts)
keymap("v", "<C-_>", "<Plug>NERDCommenterToggle<CR>gv", opts)
keymap("v", "<Leader>c<space>", "<Plug>NERDCommenterToggle<CR>gv", opts)

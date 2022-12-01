vim.keymap.set("n", "<leader>rr", ":RnvimrToggle<CR>", { silent = true })
-- Fullscreen for initial layout
vim.cmd([[
let g:rnvimr_layout = {
  \ 'relative': 'editor',
  \ 'width': &columns,
  \ 'height': &lines - 2,
  \ 'col': 0,
  \ 'row': 0,
  \ 'style': 'minimal'
  \ }
]])

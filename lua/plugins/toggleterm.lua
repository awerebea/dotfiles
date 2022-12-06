-- import plugin safely
local setup, toggleterm = pcall(require, "toggleterm")
if not setup then
  return
end

-- enable plugin
toggleterm.setup({
  open_mapping = [[<leader>;]],
  hide_numbers = true, -- hide the number column in toggleterm buffers
  autochdir = true, -- when neovim changes it current directory the terminal will change it's own when next it's opened
})

function _G.set_terminal_keymaps()
  local opts = { buffer = 0 }
  vim.keymap.set("t", "<leader><esc>", [[<C-\><C-n>]], opts)
  vim.keymap.set("t", "<leader><C-h>", [[<Cmd>wincmd h<CR>]], opts)
  vim.keymap.set("t", "<leader><C-j>", [[<Cmd>wincmd j<CR>]], opts)
  vim.keymap.set("t", "<leader><C-k>", [[<Cmd>wincmd k<CR>]], opts)
  vim.keymap.set("t", "<leader><C-l>", [[<Cmd>wincmd l<CR>]], opts)
end

-- if you only want these mappings for toggle term use term://*toggleterm#* instead
vim.cmd("autocmd! TermOpen term://* lua set_terminal_keymaps()")

-- toggle all terminals at once
vim.keymap.set(
  { "n", "t" },
  "<leader><leader>;",
  "<Cmd>ToggleTermToggleAll<CR>",
  { silent = true }
)

vim.keymap.set("t", "<C-e>", [[<Cmd>WinResizerStartResize<CR>]], { silent = true })

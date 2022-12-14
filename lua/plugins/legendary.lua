local status, legendary = pcall(require, "legendary")
if not status then
  return
end

legendary.setup({ include_builtin = true, auto_register_which_key = true })

local default_opts = { silent = true, noremap = true }
vim.keymap.set("n", "<C-p>", "<Cmd>lua require('legendary').find()<CR>", default_opts)

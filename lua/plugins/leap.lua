local setup, leap = pcall(require, "leap")
if not setup then
  return
end

leap.add_default_mappings()
vim.keymap.set("x", "ss", "<Plug>(leap-backward-to)")
vim.keymap.set("x", "xx", "<Plug>(leap-backward-till)")

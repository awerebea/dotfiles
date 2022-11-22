local status, _ = pcall(vim.cmd, "call yankstack#setup()")
if not status then
  print("yankstack plugin not installed!")
  return
end

local keymap = vim.keymap -- for conciseness

keymap.set("n", "<leader>p", "<Plug>yankstack_substitute_older_paste")
keymap.set("n", "<leader>P", "<Plug>yankstack_substitute_newer_paste")

local keymap = vim.keymap -- for conciseness

vim.g.EasyMotion_smartcase = 1
keymap.set("n", "<leader><leader>S", "<Plug>(easymotion-s2)")
keymap.set("n", "<leader><leader>2s", "<Plug>(easymotion-s2)")
keymap.set("n", "<leader><leader>d", "<Plug>(easymotion-s2)")
keymap.set("n", "<leader><leader>T", "<Plug>(easymotion-t2)")
keymap.set("n", "<leader><leader>2t", "<Plug>(easymotion-t2)")
keymap.set("", "<leader><leader>/", "<Plug>(easymotion-sn)")
keymap.set("o", "<leader><leader>/", "<Plug>(easymotion-tn)")

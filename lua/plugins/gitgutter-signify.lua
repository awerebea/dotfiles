-- TODO Check if plugin loaded
local keymap = vim.keymap -- for conciseness

vim.cmd("autocmd BufWritePost * GitGutter")
-- [c / ]c - go to previous/next hunk
keymap.set("n", "ghp", "<Plug>(GitGutterPreviewHunk)")
keymap.set("n", "ghs", "<Plug>(GitGutterStageHunk)")
keymap.set("n", "ghu", "<Plug>(GitGutterUndoHunk)")

-- disable gitgutter signs, use signify instead
vim.g.gitgutter_signs = 0

-- Use fontawesome icons as signs
vim.g.gitgutter_sign_added = "+"
vim.g.gitgutter_sign_modified = "~"
vim.g.gitgutter_sign_removed = "_"
vim.g.gitgutter_sign_removed_first_line = "^"
vim.g.gitgutter_sign_modified_removed = "~_"

-- Signify settings
-- toggle signs
keymap.set("n", "<leader>gg", ":SignifyToggle<CR>")

vim.cmd([[
" show current/total hunk when jump to it
    function! s:show_current_hunk() abort
      let h = sy#util#get_hunk_stats()
      if !empty(h)
        echo printf('[Hunk %d/%d]', h.current_hunk, h.total_hunks)
      endif
    endfunction

    autocmd User SignifyHunk call s:show_current_hunk()
]])

-- signs colors
vim.api.nvim_set_hl(0, "SignifySignAdd", { fg = "#9cf087", bg = "NONE" })
vim.api.nvim_set_hl(0, "SignifySignChange", { fg = "#ffc500", bg = "NONE" })
vim.api.nvim_set_hl(0, "SignifySignChangeDelete", { fg = "#ffc500", bg = "NONE" })
vim.api.nvim_set_hl(0, "SignifySignDelete", { fg = "#c43060", bg = "NONE" })
vim.api.nvim_set_hl(0, "SignifySignDeleteFirstLine", { fg = "#c43060", bg = "NONE" })

-- signs
vim.g.signify_sign_add = "+"
vim.g.signify_sign_change = "~"
vim.g.signify_sign_delete = "_"
vim.g.signify_sign_delete_first_line = "^"
vim.g.signify_sign_change_delete = "~_"

return {
  "andymass/vim-matchup",
  event = "BufReadPost",
  init = function()
    -- Match highlighting runs on every CursorMoved and walks the treesitter
    -- tree, which makes holding j/k laggy. Deferred mode only highlights once
    -- the cursor has stopped for `deferred_show_delay` ms.
    vim.g.matchup_matchparen_deferred = 1
    vim.g.matchup_matchparen_deferred_show_delay = 50
  end,
  config = function()
    vim.g.matchup_matchparen_offscreen = { method = "popup" }
  end,
}

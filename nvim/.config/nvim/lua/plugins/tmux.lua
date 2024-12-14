return {
  "aserowy/tmux.nvim",
  config = function()
    -- Navigate tmux, and nvim splits.
    -- Sync nvim buffer with tmux buffer.
    require("tmux").setup {
      copy_sync = {
        enable = true,
        sync_clipboard = false,
        sync_registers = true,
      },
      resize = {
        enable_default_keybindings = false,
      },
    }
  end,
}

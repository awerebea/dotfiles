return {
  "brenoprata10/nvim-highlight-colors",
  event = "VeryLazy",
  enabled = true,
  config = function()
    require("nvim-highlight-colors").setup {
      ---@usage 'background'|'foreground'|'virtual'
      render = "background",
      ---Set virtual symbol (requires render to be set to 'virtual')
      virtual_symbol = "■",
      ---Highlight named colors, e.g. 'green'
      enable_named_colors = true,
      ---Highlight tailwind colors, e.g. 'bg-blue-500'
      enable_tailwind = false,
    }
  end,
}

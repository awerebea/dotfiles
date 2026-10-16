return {
  "brenoprata10/nvim-highlight-colors",
  event = "VeryLazy",
  enabled = true,
  config = function()
    local hc = require("nvim-highlight-colors")
    hc.setup({
      ---@usage 'background'|'foreground'|'virtual'
      render = "background",
      ---Set virtual symbol (requires render to be set to 'virtual')
      virtual_symbol = "■",
      ---Highlight named colors, e.g. 'green'
      enable_named_colors = true,
      ---Highlight tailwind colors, e.g. 'bg-blue-500'
      enable_tailwind = true,
    })

    -- The plugin re-scans the visible lines and sends an LSP documentColor
    -- request on every WinScrolled, i.e. on every j/k that scrolls the view.
    -- Replace that handler with a debounced one that runs once scrolling stops.
    -- The handler is not exported, so find it by its source file.
    local delay_ms = 100
    local timer = assert(vim.uv.new_timer())
    for _, au in ipairs(vim.api.nvim_get_autocmds({ event = { "WinScrolled", "VimResized" } })) do
      local cb = au.callback
      if
        au.event == "WinScrolled"
        and type(cb) == "function"
        and debug.getinfo(cb, "S").source:find("nvim-highlight-colors", 1, true)
      then
        vim.api.nvim_del_autocmd(au.id) -- one autocmd covers both events
        vim.api.nvim_create_autocmd({ "WinScrolled", "VimResized" }, {
          group = vim.api.nvim_create_augroup("HighlightColorsDebounce", { clear = true }),
          callback = function()
            timer:stop()
            timer:start(
              delay_ms,
              0,
              vim.schedule_wrap(function()
                cb({ buf = vim.api.nvim_get_current_buf() })
              end)
            )
          end,
        })
        break
      end
    end
  end,
}

return {
  "mrjones2014/smart-splits.nvim",
  -- stylua: ignore
  keys = {
    -- Move between splits
    { "<C-h>", function() require("smart-splits").move_cursor_left() end, desc = "Move cursor left" },
    { "<C-j>", function() require("smart-splits").move_cursor_down() end, desc = "Move cursor down" },
    { "<C-k>", function() require("smart-splits").move_cursor_up() end, desc = "Move cursor up" },
    { "<C-l>", function() require("smart-splits").move_cursor_right() end, desc = "Move cursor right" },
    { "<leader><leader><leader>h", function() require("smart-splits").swap_buf_left() end, desc = "Swap buffer left" },
    { "<leader><leader><leader>j", function() require("smart-splits").swap_buf_down() end, desc = "Swap buffer down" },
    { "<leader><leader><leader>k", function() require("smart-splits").swap_buf_up() end, desc = "Swap buffer up" },
    { "<leader><leader><leader>l", function() require("smart-splits").swap_buf_right() end, desc = "Swap buffer right", },
    -- {{{ Use winresizer plugin instead
    -- { "<C-e>", function() require("smart-splits").start_resize_mode() end, desc = "Start resize mode", },
    -- The following keymaps are used by mini.move plugin
    -- { "<A-h>", function() require("smart-splits").resize_left() end, desc = "Resize left" },
    -- { "<A-j>", function() require("smart-splits").resize_down() end, desc = "Resize down" },
    -- { "<A-k>", function() require("smart-splits").resize_up() end, desc = "Resize up" },
    -- { "<A-l>", function() require("smart-splits").resize_right() end, desc = "Resize right" },
    -- }}}
  },
  opts = {
    at_edge = "wrap",
    disable_multiplexer_nav_when_zoomed = true,
    cursor_follows_swapped_bufs = true,
    -- {{{ Use winresizer plugin instead
    -- resize_mode = {
    --   silent = true,
    --   hooks = {
    --     on_enter = function()
    --       print 'Persistent resize mode enabled. Use { "h", "j", "k", "l" } to resize, and <ESC> to finish.'
    --     end,
    --     on_leave = function()
    --       print "Persistent resize mode disabled. Normal keymaps have been restored."
    --     end,
    --   },
    -- },
    -- }}}
  },
  config = function(_, opts)
    require("smart-splits").setup(opts)
  end,
}

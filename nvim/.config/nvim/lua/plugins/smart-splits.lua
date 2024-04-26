return {
  "mrjones2014/smart-splits.nvim",
  event = "VeryLazy",
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
    -- moving between splits
    vim.keymap.set("n", "<C-h>", require("smart-splits").move_cursor_left)
    vim.keymap.set("n", "<C-j>", require("smart-splits").move_cursor_down)
    vim.keymap.set("n", "<C-k>", require("smart-splits").move_cursor_up)
    vim.keymap.set("n", "<C-l>", require("smart-splits").move_cursor_right)
    -- {{{ Use winresizer plugin instead
    -- vim.keymap.set("n", "<C-e>", function()
    --   require("smart-splits").start_resize_mode()
    -- end, { desc = "Start resize mode" })
    -- The following keymaps are used by mini.move plugin
    -- vim.keymap.set("n", "<A-h>", require("smart-splits").resize_left)
    -- vim.keymap.set("n", "<A-j>", require("smart-splits").resize_down)
    -- vim.keymap.set("n", "<A-k>", require("smart-splits").resize_up)
    -- vim.keymap.set("n", "<A-l>", require("smart-splits").resize_right)
    -- }}}
    -- swapping buffers between windows
    vim.keymap.set("n", "<leader><leader><leader>h", require("smart-splits").swap_buf_left)
    vim.keymap.set("n", "<leader><leader><leader>j", require("smart-splits").swap_buf_down)
    vim.keymap.set("n", "<leader><leader><leader>k", require("smart-splits").swap_buf_up)
    vim.keymap.set("n", "<leader><leader><leader>l", require("smart-splits").swap_buf_right)
  end,
}

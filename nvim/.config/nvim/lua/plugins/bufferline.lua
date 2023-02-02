return {
  "akinsho/nvim-bufferline.lua",
  event = "VeryLazy",
  keys = {
    { "]b", "<Cmd>BufferLineCycleNext<CR>" },
    { "[b", "<Cmd>BufferLineCyclePrev<CR>" },
    { "<leader>]b", "<Cmd>BufferLineMoveNext<CR>" },
    { "<leader>[b", "<Cmd>BufferLineMovePrev<CR>" },
    { "<M-S-l>", "<Cmd>BufferLineCycleNext<CR>" },
    { "<M-S-h>", "<Cmd>BufferLineCyclePrev<CR>" },
    { "<M-S-k>", "<Cmd>BufferLineMoveNext<CR>" },
    { "<M-S-j>", "<Cmd>BufferLineMovePrev<CR>" },
    { "<leader><Tab>", "<Cmd>lua ToggleTabSwitcherMode()<CR>" },
  },
  opts = {
    options = {
      middle_mouse_command = "bdelete! %d", -- can be a string | function, see "Mouse actions"
      hover = {
        enabled = true,
        delay = 200,
        reveal = { "close" },
      },
      offsets = {
        {
          filetype = "NvimTree",
          text = "File Explorer",
          highlight = "Directory",
          separator = true, -- use a "true" to enable the default, or set your own character
        },
      },
      max_name_length = 25,
      max_prefix_length = 15, -- prefix used when a buffer is de-duplicated
      tab_size = 10,
      show_buffer_icons = false,
      enforce_regular_tabs = false,
    },
  },
  config = function(_, opts)
    require("bufferline").setup(opts)
    vim.opt.sessionoptions:append { "globals" }

    -- {{{ Smart buffers/tabs switch
    local keymap = vim.keymap.set
    local tab_switcher_mode = "buffers"
    function ToggleTabSwitcherMode()
      if tab_switcher_mode == "buffers" then
        keymap("n", "<M-S-l>", "<Cmd>tabnext<CR>")
        keymap("n", "<M-S-h>", "<Cmd>tabprevious<CR>")
        tab_switcher_mode = "tabs"
        print "Switch tabs"
      else
        keymap("n", "<M-S-l>", "<Cmd>BufferLineCycleNext<CR>")
        keymap("n", "<M-S-h>", "<Cmd>BufferLineCyclePrev<CR>")
        tab_switcher_mode = "buffers"
        print "Switch buffers"
      end
    end
    -- }}}
  end,
}

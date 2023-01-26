return {
  "akinsho/nvim-bufferline.lua",
  event = "VeryLazy",
  keys = {
    { "]b", "<Cmd>BufferLineCycleNext<CR>", { silent = true } },
    { "[b", "<Cmd>BufferLineCyclePrev<CR>", { silent = true } },
    { "<leader>]b", "<Cmd>BufferLineMoveNext<CR>", { silent = true } },
    { "<leader>[b", "<Cmd>BufferLineMovePrev<CR>", { silent = true } },
    { "<M-S-l>", "<Cmd>BufferLineCycleNext<CR>", { silent = true } },
    { "<M-S-h>", "<Cmd>BufferLineCyclePrev<CR>", { silent = true } },
    { "<M-S-k>", "<Cmd>BufferLineMoveNext<CR>", { silent = true } },
    { "<M-S-j>", "<Cmd>BufferLineMovePrev<CR>", { silent = true } },
    { "<leader><Tab>", "<Cmd>lua ToggleTabSwitcherMode()<CR>", { silent = true } },
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
        keymap("n", "<M-S-l>", "<Cmd>tabnext<CR>", { silent = true })
        keymap("n", "<M-S-h>", "<Cmd>tabprevious<CR>", { silent = true })
        tab_switcher_mode = "tabs"
        print "Switch tabs"
      else
        keymap("n", "<M-S-l>", "<Cmd>BufferLineCycleNext<CR>", { silent = true })
        keymap("n", "<M-S-h>", "<Cmd>BufferLineCyclePrev<CR>", { silent = true })
        tab_switcher_mode = "buffers"
        print "Switch buffers"
      end
    end
    -- }}}
  end,
}

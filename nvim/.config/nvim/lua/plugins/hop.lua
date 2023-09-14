return {
  "awerebea/hop.nvim",
  branch = "fix-cursor-on-empty-line",
  event = "VeryLazy",
  opts = { keys = "asdfghjklqwertyuiopzxcvbnm;" },
  config = function(_, opts)
    local hop = require "hop"
    hop.setup(opts)

    vim.api.nvim_command "highlight HopNextKey cterm=bold gui=bold guifg=#ff0000"
    vim.api.nvim_command "highlight HopNextKey1 cterm=bold gui=bold guifg=#ffb400"
    vim.api.nvim_command "highlight HopNextKey2 cterm=bold gui=bold guifg=#b98300"

    local directions = require("hop.hint").HintDirection
    local position = require("hop.hint").HintPosition
    -- emulation of t/T jump
    HopTFw = function()
      hop.hint_char1 {
        direction = directions.AFTER_CURSOR,
        current_line_only = false,
        hint_offset = -1,
      }
    end

    HopTBw = function()
      hop.hint_char1 {
        direction = directions.BEFORE_CURSOR,
        current_line_only = false,
        hint_offset = 1,
      }
    end

    HopToEndWordFw = function()
      hop.hint_words {
        hint_position = position.END,
        direction = directions.AFTER_CURSOR,
      }
    end

    HopToEndWordBw = function()
      hop.hint_words {
        hint_position = position.END,
        direction = directions.BEFORE_CURSOR,
      }
    end

    HopAfterEndWordFw = function()
      hop.hint_words {
        hint_position = position.END,
        direction = directions.AFTER_CURSOR,
        hint_offset = 1,
      }
    end

    HopAfterEndWordBw = function()
      hop.hint_words {
        hint_position = position.END,
        direction = directions.BEFORE_CURSOR,
        hint_offset = 1,
      }
    end

    local keymap = vim.keymap.set

    keymap("", "<leader><leader><leader>", "<Cmd>HopWord<CR>")
    keymap("", "<leader><leader>W", "<Cmd>HopWordMW<CR>")
    keymap("", "<leader><leader>w", "<Cmd>HopWordAC<CR>")
    keymap("", "<leader><leader>b", "<Cmd>HopWordBC<CR>")
    keymap("", "<leader><leader>f", "<Cmd>HopChar1AC<CR>")
    keymap("", "<leader><leader>F", "<Cmd>HopChar1BC<CR>")
    keymap("", "<leader><leader>t", "<Cmd>lua HopTFw()<CR>")
    keymap("", "<leader><leader>T", "<Cmd>lua HopTBw()<CR>")
    keymap("", "<leader><leader>e", "<Cmd>lua HopToEndWordFw()<CR>")
    keymap("", "<leader><leader>ge", "<Cmd>lua HopToEndWordBw()<CR>")
    keymap("", "<leader><leader>E", "<Cmd>lua HopAfterEndWordFw()<CR>")
    keymap("", "<leader><leader>gE", "<Cmd>lua HopAfterEndWordBw()<CR>")
    keymap("", "<leader><leader>s", "<Cmd>HopChar1<CR>")
    keymap("", "<leader><leader>S", "<Cmd>HopChar2<CR>")
    keymap("", "<C-s>", "<Cmd>HopChar2<CR>")
    keymap("", "<leader><leader>2s", "<Cmd>HopChar2<CR>")
    keymap("", "<leader><leader>d", "<Cmd>HopChar2<CR>")
    keymap("", "<leader><leader>J", "<Cmd>HopLineAC<CR>")
    keymap("", "<leader><leader>K", "<Cmd>HopLineBC<CR>")
    keymap("", "<leader><leader>j", "<Cmd>HopVerticalAC<CR>")
    keymap("", "<leader><leader>k", "<Cmd>HopVerticalBC<CR>")
    keymap("", "<leader><leader>/", "<Cmd>HopPattern<CR>")
  end,
}

return {
  "smoka7/hop.nvim",
  event = "VeryLazy",
  opts = { keys = "etovxqpdygfblzhckisuran" },
  config = function(_, opts)
    local hop = require "hop"
    hop.setup(opts)

    vim.api.nvim_set_hl(0, "HopNextKey", { fg = "Black", bg = "#ccff88" })
    vim.api.nvim_set_hl(0, "HopNextKey1", { fg = "Black", bg = "#79ab37" })
    vim.api.nvim_set_hl(0, "HopNextKey2", { fg = "Black", bg = "#a4e84a" })
    vim.api.nvim_set_hl(0, "HopUnmatched", { fg = "#6c7086" })

    local directions = require("hop.hint").HintDirection
    local position = require("hop.hint").HintPosition

    -- vim.keymap.set("", "<leader><leader><leader>", "<Cmd>HopWord<CR>")
    vim.keymap.set("", "<leader><leader>W", "<Cmd>HopWordMW<CR>")
    vim.keymap.set("", "<leader><leader>w", "<Cmd>HopWordAC<CR>")
    vim.keymap.set("", "<leader><leader>b", "<Cmd>HopWordBC<CR>")
    vim.keymap.set("", "<leader><leader>f", "<Cmd>HopChar1AC<CR>")
    vim.keymap.set("", "<leader><leader>F", "<Cmd>HopChar1BC<CR>")
    vim.keymap.set("", "<leader><leader>t", function()
      hop.hint_char1 {
        direction = directions.AFTER_CURSOR,
        current_line_only = false,
        hint_offset = -1,
      }
    end)
    vim.keymap.set("", "<leader><leader>T", function()
      hop.hint_char1 {
        direction = directions.BEFORE_CURSOR,
        current_line_only = false,
        hint_offset = 1,
      }
    end)
    -- vim.keymap.set("", "<leader><leader>e", function()
    --   hop.hint_words {
    --     hint_position = position.END,
    --     direction = directions.AFTER_CURSOR,
    --   }
    -- end)
    vim.keymap.set("", "<leader><leader>ge", function()
      hop.hint_words {
        hint_position = position.END,
        direction = directions.BEFORE_CURSOR,
      }
    end)
    vim.keymap.set("", "<leader><leader>E", function()
      hop.hint_words {
        hint_position = position.END,
        direction = directions.AFTER_CURSOR,
        hint_offset = 1,
      }
    end)
    vim.keymap.set("", "<leader><leader>gE", function()
      hop.hint_words {
        hint_position = position.END,
        direction = directions.BEFORE_CURSOR,
        hint_offset = 1,
      }
    end)
    vim.keymap.set("", "<leader><leader>s", "<Cmd>HopChar1<CR>")
    vim.keymap.set("", "<leader><leader>S", "<Cmd>HopChar2<CR>")
    vim.keymap.set("", "<C-s>", "<Cmd>HopChar2<CR>")
    vim.keymap.set("", "<leader><leader>2s", "<Cmd>HopChar2<CR>")
    vim.keymap.set("", "<leader><leader>d", "<Cmd>HopChar2<CR>")
    vim.keymap.set("", "<leader><leader>J", "<Cmd>HopLineAC<CR>")
    vim.keymap.set("", "<leader><leader>K", "<Cmd>HopLineBC<CR>")
    vim.keymap.set("", "<leader><leader>j", "<Cmd>HopVerticalAC<CR>")
    vim.keymap.set("", "<leader><leader>k", "<Cmd>HopVerticalBC<CR>")
    vim.keymap.set("", "<leader><leader>/", "<Cmd>HopPattern<CR>")
  end,
}

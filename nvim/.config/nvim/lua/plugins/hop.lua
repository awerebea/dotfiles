return {
  "smoka7/hop.nvim",
  event = "VeryLazy",
  opts = { keys = "etovxqpdygfblzhckisuran" },
  config = function(_, opts)
    local hop = require("hop")
    hop.setup(opts)

    vim.api.nvim_set_hl(0, "HopNextKey", { fg = "Black", bg = "#ccff88" })
    vim.api.nvim_set_hl(0, "HopNextKey1", { fg = "Black", bg = "#79ab37" })
    vim.api.nvim_set_hl(0, "HopNextKey2", { fg = "Black", bg = "#a4e84a" })
    vim.api.nvim_set_hl(0, "HopUnmatched", { fg = "#6c7086" })

    local directions = require("hop.hint").HintDirection
    local position = require("hop.hint").HintPosition

    --stylua: ignore
    vim.keymap.set("", "<leader><leader>W", "<Cmd>HopWordMW<CR>", { desc = "Hop word (all windows)" })
    vim.keymap.set("", "<leader><leader>w", "<Cmd>HopWordAC<CR>", { desc = "Hop word forward" })
    vim.keymap.set("", "<leader><leader>b", "<Cmd>HopWordBC<CR>", { desc = "Hop word backward" })
    vim.keymap.set("", "<leader><leader>f", "<Cmd>HopChar1AC<CR>", { desc = "Hop char forward" })
    vim.keymap.set("", "<leader><leader>F", "<Cmd>HopChar1BC<CR>", { desc = "Hop char backward" })
    vim.keymap.set("", "<leader><leader>t", function()
      hop.hint_char1({
        direction = directions.AFTER_CURSOR,
        current_line_only = false,
        hint_offset = -1,
      })
    end, { desc = "Hop till char forward" })
    vim.keymap.set("", "<leader><leader>T", function()
      hop.hint_char1({
        direction = directions.BEFORE_CURSOR,
        current_line_only = false,
        hint_offset = 1,
      })
    end, { desc = "Hop till char backward" })
    vim.keymap.set("", "<leader><leader>ge", function()
      hop.hint_words({
        hint_position = position.END,
        direction = directions.BEFORE_CURSOR,
      })
    end, { desc = "Hop word end backward" })
    vim.keymap.set("", "<leader><leader>E", function()
      hop.hint_words({
        hint_position = position.END,
        direction = directions.AFTER_CURSOR,
        hint_offset = 1,
      })
    end, { desc = "Hop word end forward" })
    vim.keymap.set("", "<leader><leader>gE", function()
      hop.hint_words({
        hint_position = position.END,
        direction = directions.BEFORE_CURSOR,
        hint_offset = 1,
      })
    end, { desc = "Hop WORD end backward" })
    vim.keymap.set("", "<leader><leader>s", "<Cmd>HopChar1<CR>", { desc = "Hop 1-char" })
    vim.keymap.set("", "<leader><leader>S", "<Cmd>HopChar2<CR>", { desc = "Hop 2-char" })
    vim.keymap.set("", "<C-s>", "<Cmd>HopChar2<CR>", { desc = "Hop 2-char" })
    vim.keymap.set("", "<leader><leader>J", "<Cmd>HopLineAC<CR>", { desc = "Hop line forward" })
    vim.keymap.set("", "<leader><leader>K", "<Cmd>HopLineBC<CR>", { desc = "Hop line backward" })
    --stylua: ignore
    vim.keymap.set("", "<leader><leader>j", "<Cmd>HopVerticalAC<CR>", { desc = "Hop vertical forward" })
    --stylua: ignore
    vim.keymap.set("", "<leader><leader>k", "<Cmd>HopVerticalBC<CR>", { desc = "Hop vertical backward" })
    vim.keymap.set("", "<leader><leader>/", "<Cmd>HopPattern<CR>", { desc = "Hop pattern" })
  end,
}

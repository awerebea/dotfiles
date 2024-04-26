return {
  "anuvyklack/windows.nvim",
  event = "VeryLazy",
  dependencies = { "anuvyklack/middleclass" },
  opts = { autowidth = { winwidth = 12 } },
  config = function(_, opts)
    vim.opt.winminwidth = 5
    vim.opt.winheight = 5
    vim.opt.winminheight = 0
    vim.opt.equalalways = false
    require("windows").setup(opts)
    local function cmd(command)
      return table.concat { "<Cmd>", command, "<CR>" }
    end
    vim.keymap.set("n", "<C-w>z", cmd "WindowsMaximize")
    vim.keymap.set("n", "<leader>z", cmd "WindowsMaximize")
    vim.keymap.set("n", "<C-w>-", cmd "WindowsMaximizeVertically")
    vim.keymap.set("n", "<C-w>\\", cmd "WindowsMaximizeHorizontally")
    vim.keymap.set("n", "<C-w>=", cmd "WindowsEqualize")
    vim.keymap.set("n", "<C-w>t", cmd "WindowsToggleAutowidth")
  end,
}

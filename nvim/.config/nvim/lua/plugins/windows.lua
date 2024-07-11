return {
  "anuvyklack/windows.nvim",
  event = "VeryLazy",
  dependencies = { "anuvyklack/middleclass" },
  cmd = {
    "WindowsMaximize",
    "WindowsMaximizeVertically",
    "WindowsMaximizeHorizontally",
    "WindowsEqualize",
    "WindowsToggleAutowidth",
  },
  keys = {
    { "<C-w>z", "<Cmd>WindowsMaximize<CR>", desc = "Maximize window" },
    { "<leader>z", "<Cmd>WindowsMaximize<CR>", desc = "Maximize window" },
    { "<C-w>-", "<Cmd>WindowsMaximizeVertically<CR>", desc = "Maximize window vertically" },
    { "<C-w>\\", "<Cmd>WindowsMaximizeHorizontally<CR>", desc = "Maximize window horizontally" },
    { "<C-w>=", "<Cmd>WindowsEqualize<CR>", desc = "Equalize windows" },
    { "<C-w>t", "<Cmd>WindowsToggleAutowidth<CR>", desc = "Toggle autowidth" },
  },
  opts = { autowidth = { winwidth = 12 } },
  config = function(_, opts)
    vim.opt.winminwidth = 0
    vim.opt.winheight = 5
    vim.opt.winminheight = 0
    vim.opt.equalalways = false
    require("windows").setup(opts)
  end,
}

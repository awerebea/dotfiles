return {
  "rcarriga/nvim-notify",
  event = "VeryLazy",
  opts = {
    timeout = 2500,
    max_height = function()
      return math.floor(vim.o.lines * 0.75)
    end,
    max_width = function()
      return math.floor(vim.o.columns * 0.75)
    end,
    render = "wrapped-compact",
    top_down = false,
  },
  config = function(_, opts)
    require("notify").setup(opts)
    vim.notify = require "notify"
  end,
}

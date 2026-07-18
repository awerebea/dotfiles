return {
  "rcarriga/nvim-notify",
  lazy = false,
  priority = 900,
  opts = {
    timeout = 3000,
    render = "compact",
    stages = "fade",
    max_height = function()
      return math.floor(vim.o.lines * 0.75)
    end,
    max_width = function()
      return math.floor(vim.o.columns * 0.4)
    end,
  },
  config = function(_, opts)
    local notify = require("notify")
    notify.setup(opts)
    vim.notify = notify
  end,
}

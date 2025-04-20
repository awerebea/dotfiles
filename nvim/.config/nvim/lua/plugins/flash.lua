return {
  "folke/flash.nvim",
  enabled = true,
  event = "VeryLazy",
  opts = {
    modes = {
      char = {
        enabled = true,
        config = function(opts)
          -- autohide flash when in operator-pending mode
          opts.autohide = opts.autohide or (vim.fn.mode(true):find "no" and vim.v.operator == "y")

          -- disable jump labels when not enabled, when using a count,
          -- or when recording/executing registers
          opts.jump_labels = opts.jump_labels
            and vim.v.count == 0
            and vim.fn.reg_executing() == ""
            and vim.fn.reg_recording() == ""

          -- Show jump labels only in operator-pending mode
          -- opts.jump_labels = vim.v.count == 0 and vim.fn.mode(true):find("o")
        end,
        -- hide after jump when not using jump labels
        autohide = true,
        -- show jump labels
        jump_labels = true,
        -- set to `false` to use the current line only
        multi_line = true,
        -- When using jump labels, don't use these keys
        -- This allows using those keys directly after the motion
        label = { exclude = "hjkliardcxsbwerRpy" },
      },
      search = { enabled = false, jump = { history = true, register = true, nohlsearch = false } },
    },
    label = {
      rainbow = {
        enabled = false,
        shade = 3, -- number between 1 and 9
      },
    },
  },
  -- stylua: ignore
  -- keys are disabled because leap plugin is used instead
  keys = {
    { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
    { "S", mode = { "n", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
    { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
    { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
    { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
  },
  config = function(_, opts)
    require("flash").setup(opts)
    -- Use tha same highlight color as LeapLabelPrimary
    vim.api.nvim_set_hl(0, "FlashLabel", { fg = "#ccff88", bg = "none", bold = true })
  end,
}

return {
  {
    "echasnovski/mini.move",
    opts = {},
    keys = { "<M-h>", "<M-l>", "<M-j>", "<M-k>" },
    config = function(_, opts)
      require("mini.move").setup(opts)
    end,
  },
  {
    "echasnovski/mini.ai",
    event = "VeryLazy",
    dependencies = {
      {
        "nvim-treesitter/nvim-treesitter-textobjects",
        init = function()
          -- no need to load the plugin, since we only need its queries
          require("lazy.core.loader").disable_rtp_plugin "nvim-treesitter-textobjects"
        end,
      },
    },
    opts = function()
      local ai = require "mini.ai"
      return {
        n_lines = 500,
        custom_textobjects = {
          o = ai.gen_spec.treesitter({
            a = { "@block.outer", "@conditional.outer", "@loop.outer" },
            i = { "@block.inner", "@conditional.inner", "@loop.inner" },
          }, {}),
          f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }, {}),
          c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }, {}),
        },
      }
    end,
    config = function(_, opts)
      local ai = require "mini.ai"
      ai.setup(opts)
    end,
  },
  {
    "echasnovski/mini.trailspace",
    event = "BufReadPost",
    config = function()
      require("mini.trailspace").setup()
    end,
  },
  {
    "echasnovski/mini.bracketed",
    event = "BufReadPost",
    opts = {},
    config = function(_, opts)
      require("mini.bracketed").setup(opts)
    end,
  },
  {
    "echasnovski/mini.operators",
    event = "VeryLazy",
    opts = {
      evaluate = { prefix = "g=" },
      exchange = { prefix = "gx", reindent_linewise = true },
      multiply = { prefix = "" },
      replace = { prefix = "" },
      sort = { prefix = "" },
    },
  },
  {
    "echasnovski/mini.splitjoin",
    event = "VeryLazy",
    version = "*",
    config = true,
  },
  -- {
  --   "echasnovski/mini.comment",
  --   event = "VeryLazy",
  --   opts = {
  --     hooks = {
  --       pre = function()
  --         require("ts_context_commentstring.internal").update_commentstring {}
  --       end,
  --     },
  --   },
  --   config = function(_, opts)
  --     require("mini.comment").setup(opts)
  --   end,
  -- },
  -- {
  --   "echasnovski/mini.pairs",
  --   event = "VeryLazy",
  --   config = function(_, opts)
  --     require("mini.pairs").setup(opts)
  --   end,
  -- },
}

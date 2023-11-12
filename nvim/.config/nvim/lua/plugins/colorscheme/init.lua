return {
  {
    "folke/styler.nvim",
    enabled = false,
    event = "VeryLazy",
    config = function()
      require("styler").setup {
        themes = {
          markdown = { colorscheme = "gruvbox" },
          help = { colorscheme = "gruvbox" },
        },
      }
    end,
  },
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      local tokyonight = require "tokyonight"
      tokyonight.setup {
        style = "night", -- The theme comes in three styles, `storm`, `moon`, a darker variant `night` and `day`
        transparent = false, -- Enable this to disable setting the background color
        styles = {
          -- Style to be applied to different syntax groups
          -- Value is any valid attr-list value for `:help nvim_set_hl`
          comments = { italic = true },
          keywords = { italic = false },
        },
        on_colors = function(colors)
          colors.comment = "#6b77ac"
          colors.fg_gutter = "#4e567f"
          colors.border = "#4e567f"
        end,
        on_highlights = function(highlights)
          highlights.Folded = {
            bg = "#15161e",
          }
        end,
      }
      tokyonight.load()

      -- {{{ Colors for words that failed spell check
      -- Word not recognized
      vim.api.nvim_set_hl(0, "SpellBad", {})
      vim.api.nvim_set_hl(0, "SpellBad", { undercurl = true, fg = "#00bfff" })
      -- Word not capitalized
      vim.api.nvim_set_hl(0, "SpellCap", {})
      vim.api.nvim_set_hl(0, "SpellCap", { undercurl = true, fg = "#ff4500" })
      -- Word is rare
      vim.api.nvim_set_hl(0, "SpellRare", {})
      vim.api.nvim_set_hl(0, "SpellRare", { undercurl = true, fg = "#32cd32" })
      -- Wrong spelling for selected region
      vim.api.nvim_set_hl(0, "SpellLocal", {})
      vim.api.nvim_set_hl(0, "SpellLocal", { undercurl = true, fg = "#ffb90f" })
      -- }}}
    end,
  },
  {
    "catppuccin/nvim",
    lazy = false,
    name = "catppuccin",
    config = function()
      local catppuccin = require "catppuccin"
      catppuccin.setup {
        flavour = "mocha", -- latte, frappe, macchiato, mocha
        dim_inactive = {
          enabled = true, -- dims the background color of inactive window
          shade = "dark",
          percentage = 0.15, -- percentage of the shade to apply to the inactive window
        },
        styles = {
          comments = { "italic" },
          conditionals = { "italic" },
          loops = {},
          functions = {},
          keywords = {},
          strings = {},
          variables = {},
          numbers = {},
          booleans = {},
          properties = {},
          types = {},
          operators = {},
        },
        integrations = {
          notify = true,
          aerial = true,
          harpoon = true,
          which_key = true,
        },
      }
      catppuccin.load()

      -- {{{ Colors for words that failed spell check
      -- Word not recognized
      vim.api.nvim_set_hl(0, "SpellBad", {})
      vim.api.nvim_set_hl(0, "SpellBad", { undercurl = true, fg = "#00bfff" })
      -- Word not capitalized
      vim.api.nvim_set_hl(0, "SpellCap", {})
      vim.api.nvim_set_hl(0, "SpellCap", { undercurl = true, fg = "#ff4500" })
      -- Word is rare
      vim.api.nvim_set_hl(0, "SpellRare", {})
      vim.api.nvim_set_hl(0, "SpellRare", { undercurl = true, fg = "#32cd32" })
      -- Wrong spelling for selected region
      vim.api.nvim_set_hl(0, "SpellLocal", {})
      vim.api.nvim_set_hl(0, "SpellLocal", { undercurl = true, fg = "#ffb90f" })
      -- }}}
    end,
  },
  {
    "ellisonleao/gruvbox.nvim",
    lazy = false,
    config = function()
      require("gruvbox").setup()
    end,
  },
}

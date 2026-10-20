-- Colors for words that failed spell check, shared by the colorschemes below.
-- Set through each colorscheme's own highlight hook, so they are applied
-- every time that colorscheme is loaded
local spell_colors = {
  SpellBad = "#00bfff", -- Word not recognized
  SpellCap = "#ff4500", -- Word not capitalized
  SpellRare = "#32cd32", -- Word is rare
  SpellLocal = "#ffb90f", -- Wrong spelling for selected region
}

return {
  {
    "folke/styler.nvim",
    enabled = false,
    event = "VeryLazy",
    config = function()
      require("styler").setup({
        themes = {
          markdown = { colorscheme = "gruvbox" },
          help = { colorscheme = "gruvbox" },
        },
      })
    end,
  },
  {
    -- not loaded at startup: lazy.nvim loads it on `:colorscheme tokyonight`
    "folke/tokyonight.nvim",
    config = function()
      local tokyonight = require("tokyonight")
      tokyonight.setup({
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
          for group, fg in pairs(spell_colors) do
            highlights[group] = { undercurl = true, fg = fg }
          end
        end,
      })
    end,
  },
  {
    -- the default colorscheme, the only one loaded at startup
    "catppuccin/nvim",
    lazy = false,
    priority = 1000,
    name = "catppuccin",
    version = "1.11.0", -- pin to this version as in later releases colors were changed
    config = function()
      local catppuccin = require("catppuccin")
      catppuccin.setup({
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
        custom_highlights = function(colors)
          local hl = {
            -- Brighter non-current line numbers (default is surface1)
            LineNr = { fg = colors.overlay1 },
            -- Set the CursorColumn bg color the same as the CursorLine
            CursorColumn = { bg = "#2a2b3c" },
          }
          for group, fg in pairs(spell_colors) do
            hl[group] = { fg = fg, style = { "undercurl" } }
          end
          return hl
        end,
        integrations = {
          notify = true,
          aerial = true,
          harpoon = true,
          which_key = true,
        },
      })
      vim.cmd.colorscheme("catppuccin")
    end,
  },
  {
    -- not loaded at startup: lazy.nvim loads it on `:colorscheme gruvbox`
    "ellisonleao/gruvbox.nvim",
    config = function()
      require("gruvbox").setup()
    end,
  },
}

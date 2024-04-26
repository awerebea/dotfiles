return {
  "monaqa/dial.nvim",
  keys = {
    "<C-a>",
    "<C-x>",
    { "<C-a>", "v" },
    { "<C-x>", "v" },
    { "g<C-a>", "v" },
    { "g<C-x>", "v" },
  },
    -- stylua: ignore
    init = function()
      local augend = require("dial.augend")
      require("dial.config").augends:register_group{
        default = {
          augend.constant.alias.bool,
          augend.integer.alias.decimal,
          augend.integer.alias.hex,
          augend.date.alias["%Y/%m/%d"],
          augend.date.alias["%Y-%m-%d"],
          augend.date.alias["%m/%d"],
          augend.date.alias["%H:%M"],
          augend.semver.alias.semver,
          augend.constant.new{
            elements = {"and", "or"},
            word = true, -- if false, "sand" is incremented into "sor", "doctor" into "doctand", etc.
            cyclic = true,  -- "or" is incremented into "and".
          },
          augend.constant.new{
            elements = {"&&", "||"},
            word = false,
            cyclic = true,
          },
          augend.constant.new{
            elements = {"False", "True"},
            word = true,
            cyclic = true,
          },
          augend.constant.new{
            elements = {"on", "off"},
            word = true,
            cyclic = true,
          },
          augend.constant.new{
            elements = {"On", "Off"},
            word = true,
            cyclic = true,
          },
          augend.constant.new{
            elements = {"left", "center", "right"},
            word = true,
            cyclic = true,
          },
          augend.constant.new{
            elements = {"Left", "Center", "Right"},
            word = true,
            cyclic = true,
          },
          augend.constant.new{
            elements = {"LEFT", "CENTER", "RIGHT"},
            word = true,
            cyclic = true,
          },
          augend.constant.new{
            elements = {"Jan", "Feb", "Mar", "Apr", "May", "Jun",
                        "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"},
            word = true,
            cyclic = true,
          },
          augend.constant.new{
            elements = {"January", "February", "March", "April", "May", "June",
                        "July", "August", "September", "October", "November", "December"},
            word = true,
            cyclic = true,
          },
        },
      }
      vim.keymap.set(
        "n", "<C-a>", require("dial.map").inc_normal(), { desc = "Increment", noremap = true })
      vim.keymap.set(
        "n", "<C-x>", require("dial.map").dec_normal(), { desc = "Decrement", noremap = true })
      vim.keymap.set(
        "v", "<C-a>", require("dial.map").inc_visual(), { desc = "Increment", noremap = true })
      vim.keymap.set(
        "v", "<C-x>", require("dial.map").dec_visual(), { desc = "Decrement", noremap = true })
      vim.keymap.set(
        "v", "g<C-a>", require("dial.map").inc_gvisual(), { desc = "Increment", noremap = true })
      vim.keymap.set(
        "v", "g<C-x>", require("dial.map").dec_gvisual(), { desc = "Decrement", noremap = true })
    end,
}

return {
  "monaqa/dial.nvim",
  -- stylua: ignore
  keys = {
    { "<C-a>", function() require("dial.map").manipulate("increment", "normal") end, desc = "Increment" },
    { "<C-x>", function() require("dial.map").manipulate("decrement", "normal") end, desc = "Decrement" },
    -- like <C-a>/<C-x>, but dot repeat adds [count] more each time (1, 2, 3, ...)
    { "g<C-a>", function() require("dial.map").manipulate("increment", "gnormal") end, desc = "Increment (cumulative repeat)" },
    { "g<C-x>", function() require("dial.map").manipulate("decrement", "gnormal") end, desc = "Decrement (cumulative repeat)" },
    -- every match in the selection changes by [count]
    { "<C-a>", function() require("dial.map").manipulate("increment", "visual") end, mode = "x", desc = "Increment" },
    { "<C-x>", function() require("dial.map").manipulate("decrement", "visual") end, mode = "x", desc = "Decrement" },
    -- line N of the selection changes by N * [count]: numbered lists, sequences
    { "g<C-a>", function() require("dial.map").manipulate("increment", "gvisual") end, mode = "x", desc = "Increment progressively" },
    { "g<C-x>", function() require("dial.map").manipulate("decrement", "gvisual") end, mode = "x", desc = "Decrement progressively" },
  },
    -- runs when one of the keys above is first pressed
    -- stylua: ignore
    config = function()
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
            elements = {"read", "write"},
            word = true,
            cyclic = true,
          },
          augend.constant.new{
            elements = {"plan", "apply"},
            word = true,
            cyclic = true,
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
            elements = {"enable", "disable"},
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
    end,
}

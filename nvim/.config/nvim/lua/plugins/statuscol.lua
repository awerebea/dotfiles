return {
  "luukvbaal/statuscol.nvim",
  event = "VeryLazy",
  config = function()
    if vim.fn.has "nvim-0.9" == 1 then
      local builtin = require "statuscol.builtin"
      require("statuscol").setup {
        relculright = true,
        segments = {
          { text = { "%s" }, click = "v:lua.ScSa" },
          { text = { builtin.lnumfunc }, click = "v:lua.ScLa" },
          { text = { " ", builtin.foldfunc, " " }, click = "v:lua.ScFa" },
        },
      }
    end
  end,
}

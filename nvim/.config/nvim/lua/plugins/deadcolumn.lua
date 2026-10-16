return {
  "Bekaboo/deadcolumn.nvim",
  event = "VeryLazy",
  opts = {
    -- scope = "visible",
    scope = (function()
      local last = 0
      return function()
        -- While j/k is held keep the colorcolumn color unchanged: recoloring
        -- it on every scroll repaints the column on every visible row
        if require("config.scroll-burst").active() then
          return last
        end
        last = 0
        for i = -0, 0 do -- number of lines before and after the current line
          local len = vim.fn.strdisplaywidth(vim.fn.getline(vim.fn.line(".") + i))
          if len > last then
            last = len
          end
        end
        return last
      end
    end)(),
    -- -@type string[]|fun(mode: string): boolean
    modes = function(mode)
      return mode:find("^[icntRss\x13]") ~= nil
    end,
  },
}

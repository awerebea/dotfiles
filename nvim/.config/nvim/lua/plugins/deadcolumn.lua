return {
  "Bekaboo/deadcolumn.nvim",
  event = "VeryLazy",
  opts = {
    -- scope = "visible",
    scope = function()
      local max = nil
      max = 0
      for i = -0, 0 do -- number of lines before and after the current line
        local len = vim.fn.strdisplaywidth(vim.fn.getline(vim.fn.line "." + i))
        if len > max then
          max = len
        end
      end
      return max
    end,
    -- -@type string[]|fun(mode: string): boolean
    modes = function(mode)
      return mode:find "^[icntRss\x13]" ~= nil
    end,
  },
}

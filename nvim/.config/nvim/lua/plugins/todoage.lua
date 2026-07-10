return {
  "harukikuri/todoage.nvim",
  event = "VeryLazy",
  opts = {
    -- keywords = { "TODO", "FIXME", "HACK" },
    format = function(age_days, info)
      -- return string.format("(%d days)", age_days)
      return string.format("(%d days, %s)", age_days, info.author)
    end,
  },
}

return {
  "stevearc/dressing.nvim",
  event = "VeryLazy",
  opts = {
    input = { relative = "editor" },
    select = {
      backend = { "telescope", "fzf", "builtin" },
    },
  },
}

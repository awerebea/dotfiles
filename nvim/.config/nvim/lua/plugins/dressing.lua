return {
  "stevearc/dressing.nvim",
  enabled = false,
  event = "VeryLazy",
  opts = {
    input = { relative = "editor" },
    select = {
      backend = { "telescope", "fzf", "builtin" },
    },
  },
}

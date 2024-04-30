return {
  "stevearc/dressing.nvim",
  enabled = true,
  event = "VeryLazy",
  opts = {
    input = {
      insert_only = false,
      start_in_insert = true,
      relative = "editor",
    },
    mappings = {
      n = {
        ["<Esc>"] = "Close",
        ["<CR>"] = "Confirm",
      },
      i = {
        ["<C-c>"] = "Close",
        ["<CR>"] = "Confirm",
        ["<Up>"] = "HistoryPrev",
        ["<Down>"] = "HistoryNext",
      },
    },
    select = {
      backend = { "telescope", "fzf", "builtin" },
    },
  },
}

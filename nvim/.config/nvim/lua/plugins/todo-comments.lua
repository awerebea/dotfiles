return {
  "folke/todo-comments.nvim",
  event = "BufReadPost",
  cmd = { "TodoTrouble", "TodoTelescope" },
  -- stylua: ignore
  keys = {
    { "<leader>]t", function() require("todo-comments").jump_next() end, desc = "Next todo comment" },
    { "<leader>[t", function() require("todo-comments").jump_prev() end, desc = "Previous todo comment" },
    { "<leader>cT", "<cmd>TodoTrouble<CR>", desc = "todo-comments (Trouble)" },
    { "<leader>ct", "<cmd>TodoTelescope<CR>", desc = "todo-comments (Telescope)" },
    { "<leader>cq", "<cmd>TodoQuickFix<CR>", desc = "todo-comments (quickfix)" },
    { "<leader>cl", "<cmd>TodoLocList<CR>", desc = "todo-comments (loclist)" },
  },
  config = true,
}

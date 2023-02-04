return {
  "folke/todo-comments.nvim",
  event = "BufReadPost",
  cmd = { "TodoTrouble", "TodoTelescope" },
  -- stylua: ignore
  keys = {
    { "<leader>]t", function() require("todo-comments").jump_next() end, desc = "Next ToDo" },
    { "<leader>[t", function() require("todo-comments").jump_prev() end, desc = "Previous ToDo" },
    { "<leader>ct", "<cmd>TodoTrouble<cr>", desc = "ToDo (Trouble)" },
    { "<leader>cT", "<cmd>TodoTelescope<cr>", desc = "ToDo" },
  },
  config = true,
}

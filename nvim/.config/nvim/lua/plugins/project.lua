return {
  "DrKJeff16/project.nvim",
  event = "VeryLazy",
  cmd = "Project",
  keys = {
    {
      "<leader>fp",
      function()
        require("project.extensions.snacks").pick()
      end,
      desc = "Projects",
    },
    {
      "<leader>pr",
      "<Cmd>Project root<CR>",
      desc = "Set CWD to the root of the project",
    },
  },
  opts = {
    manual_mode = false,
    detection_methods = { "pattern", "lsp" },
    patterns = { ".project", ".git" },
    lsp = {},
    show_hidden = true,
    silent_chdir = false,
    scope_chdir = "global",
    history = {
      save_dir = vim.fn.stdpath("data"),
    },
    snacks = {
      enabled = true,
      opts = {
        hidden = false,
        sort = "newest",
        title = "Select Project",
        layout = "select",
        show = "paths",
      },
    },
  },
}

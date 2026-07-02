local M = {}

function M.setup()
  -- Files
  vim.keymap.set("n", "<leader>ff", function()
    Snacks.picker.files()
  end, { desc = "Find files" })

  vim.keymap.set("n", "<leader>fG", function()
    Snacks.picker.git_files()
  end, { desc = "Find Git files" })

  vim.keymap.set("v", "<leader>ff", function()
    Snacks.picker.files({ pattern = require("utils").get_visual_selection_text()[1] })
  end, { desc = "Find files (with selected text)" })

  vim.keymap.set("n", "<leader>f/", function()
    Snacks.picker.grep()
  end, { desc = "Live grep" })

  vim.keymap.set("n", "<leader>fg", function()
    Snacks.picker.grep()
  end, { desc = "Fuzzy grep" })

  vim.keymap.set({ "n", "x" }, "<leader>fw", function()
    Snacks.picker.grep_word()
  end, { desc = "Find word / selection" })

  vim.keymap.set("v", "<leader>8", function()
    Snacks.picker.grep_word()
  end, { desc = "Grep selection" })

  vim.keymap.set("n", "<leader>fF", function()
    Snacks.picker.pickers()
  end, { desc = "Snacks pickers" })

  vim.keymap.set({ "n", "x" }, "<leader>ft", function()
    Snacks.picker.pickers()
  end, { desc = "Snacks pickers" })

  vim.keymap.set("n", "<leader>fr", function()
    Snacks.picker.resume()
  end, { desc = "Resume" })

  vim.keymap.set("n", "<leader>fo", function()
    Snacks.picker.recent()
  end, { desc = "Recent files" })

  vim.keymap.set("n", "<leader><CR>", function()
    Snacks.picker.buffers({ current = false })
  end, { desc = "Buffers" })

  vim.keymap.set("n", "<leader>fh", function()
    Snacks.picker.help()
  end, { desc = "Help tags" })

  vim.keymap.set("n", "<leader>//", function()
    Snacks.picker.lines()
  end, { desc = "Grep in current buffer" })

  vim.keymap.set("n", "<leader>fSd", function()
    Snacks.picker.lsp_symbols()
  end, { desc = "Document symbols" })

  vim.keymap.set("n", "<leader>fSw", function()
    Snacks.picker.lsp_workspace_symbols()
  end, { desc = "Workspace symbols" })

  vim.keymap.set("n", "<leader><leader>c", function()
    Snacks.picker.colorschemes()
  end, { desc = "Colorscheme" })

  vim.keymap.set("n", "<leader>fP", function()
    Snacks.picker.projects()
  end, { desc = "Projects" })

  vim.keymap.set("n", "<leader>fd", function()
    Snacks.picker.diagnostics()
  end, { desc = "Diagnostics" })

  vim.keymap.set("n", "<leader>fn", function()
    Snacks.picker.notifications()
  end, { desc = "Notifications" })

  -- Git
  vim.keymap.set("n", "<leader>glg", function()
    Snacks.picker.git_log()
  end, { desc = "Git log" })

  vim.keymap.set({ "n", "x" }, "<leader>gcf", function()
    Snacks.picker.git_log_file()
  end, { desc = "Current file Git history" })

  vim.keymap.set("n", "<leader>gcl", function()
    Snacks.picker.git_log_line()
  end, { desc = "Current line Git history" })

  vim.keymap.set("x", "<leader>gcl", function()
    -- snacks git_log_line only supports single cursor line; use telescope for visual range
    require("telescope").extensions.advanced_git_search.diff_commit_line()
  end, { desc = "Selected lines Git history (telescope)" })

  vim.keymap.set("n", "<leader>gb", function()
    Snacks.picker.git_branches()
  end, { desc = "Git branches" })

  vim.keymap.set("n", "<leader>gst", function()
    Snacks.picker.git_status()
  end, { desc = "Git status" })

  vim.keymap.set("n", "<leader>gss", function()
    Snacks.picker.git_diff()
  end, { desc = "Git diff (changed files)" })

  -- Other
  vim.keymap.set("n", "<leader>tu", function()
    Snacks.picker.undo()
  end, { desc = "Undo history" })
end

return M

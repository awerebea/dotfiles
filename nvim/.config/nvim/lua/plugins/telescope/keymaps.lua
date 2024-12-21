local M = {}

function M.setup()
  vim.keymap.set("n", "<leader>ff", function()
    require("telescope.builtin").find_files()
  end, { desc = "Find files" })

  vim.keymap.set("x", "<leader>ff", function()
    require("telescope.builtin").find_files {
      default_text = require("utils").get_visual_selection_text()[1],
    }
  end, { desc = "Find files" })

  vim.keymap.set("n", "<leader>f/", function()
    require("telescope.builtin").live_grep()
  end, { desc = "Live grep" })

  vim.keymap.set("n", "<leader>f?", function()
    require("telescope").extensions.live_grep_args.live_grep_args {
      shorten_path = true,
      word_match = "-w",
      only_sort_text = true,
      search = "",
    }
  end, { desc = "Find word under cursor" })

  vim.keymap.set("n", "<leader>fg", function()
    require("telescope.builtin").grep_string {
      shorten_path = true,
      word_match = "-w",
      only_sort_text = true,
      search = "",
    }
  end, { desc = "Fuzzy Grep" })

  vim.keymap.set("n", "<leader>fw", function()
    require("telescope.builtin").grep_string()
  end, { desc = "Find word under cursor" })

  vim.keymap.set("n", "<leader>ft", function()
    require("telescope.builtin").builtin()
  end, { desc = "Telescope" })

  vim.keymap.set("n", "<leader>//", function()
    require("telescope.builtin").current_buffer_fuzzy_find()
  end, { desc = "Fuzzy grep in current buffer" })

  vim.keymap.set("n", "<leader>fG", function()
    local ok = pcall(require("telescope").extensions.menufacture.git_files, {})
    if not ok then
      require("telescope").extensions.menufacture.find_files()
    end
  end, { desc = "Find Git managed files" })

  vim.keymap.set("n", "<leader><CR>", function()
    require("telescope.builtin").buffers()
  end, { desc = "Buffers" })

  vim.keymap.set("n", "<leader>fh", function()
    require("telescope.builtin").help_tags()
  end, { desc = "Help tags" })

  vim.keymap.set("n", "<leader>fSd", function()
    require("plugins.telescope.telescopePickers").prettyDocumentSymbols()
  end, { desc = "Document symbols" })

  vim.keymap.set("n", "<leader>fSw", function()
    require("plugins.telescope.telescopePickers").prettyWorkspaceSymbols()
  end, { desc = "Workspace symbols" })

  vim.keymap.set("n", "<leader><leader>c", function()
    require("telescope.builtin").colorscheme { enable_preview = true }
  end, { desc = "Colorscheme" })

  vim.keymap.set("n", "<leader>fo", function()
    require("telescope.builtin").oldfiles()
  end, { desc = "Recent files" })

  vim.keymap.set("n", "<leader>fr", function()
    require("fzf-lua").resume()
  end, { desc = "Resume" })

  vim.keymap.set("n", "<leader>far", function()
    require("telescope").extensions.repo.list()
  end, { desc = "Search Git repo" })

  vim.keymap.set("n", "<leader>fP", function()
    require("telescope").extensions.project.project { display_type = "minimal" }
  end, { desc = "Project extension" })
end

return M

-- keys = {
--   {
--     "<leader>fd",
--     function()
--       require("telescope.builtin").diagnostics()
--     end,
--     desc = "Diagnostics",
--   },

--   -- list notifications
--   {
--     "<leader>fn",
--     function()
--       require("telescope").extensions.notify.notify()
--     end,
--     desc = "Notifications",
--   },
--   -- git commands
--   -- Defined later in this file using custom previewer with delta
--   {
--     "<leader>glg",
--     function()
--       -- require("telescope.builtin").git_commits()
--       Delta_git_commits {
--         git_command = {
--           "git",
--           "log",
--           "--format=%h %ad %<(20,trunc)%an %s",
--           "--date=format:%Y-%m.%d",
--           "--",
--           ".",
--         },
--       }
--     end,
--     desc = "Commits",
--   },
--   {
--     "<leader>glf",
--     function()
--       -- require("telescope.builtin").git_bcommits()
--       Delta_git_bcommits {
--         git_command = {
--           "git",
--           "log",
--           "--format=%h %ad %<(20,trunc)%an %s",
--           "--date=format:%Y-%m.%d",
--         },
--       }
--     end,
--     desc = "Commits of current file",
--   },
--   {
--     "<leader>gb",
--     function()
--       require("telescope.builtin").git_branches()
--     end,
--     desc = "Branches",
--   },
--   {
--     "<leader>gst",
--     function()
--       -- require("telescope.builtin").git_status()
--       Delta_git_status()
--     end,
--     desc = "Git status (telescope)",
--   },
--   {
--     "<leader>gss",
--     function()
--       require("utils").git_diff_picker()
--     end,
--     desc = "Changed files names only (telescope)",
--   },
--   {
--     "<leader>gz",
--     function()
--       require("telescope").extensions.z.list {
--         cmd = { "bash", "-c", "fasd", "-d" },
--       }
--     end,
--     desc = "fasd",
--   },
--   {
--     "<leader>tu",
--     function()
--       require("telescope").extensions.undo.undo()
--     end,
--     desc = "Undo tree",
--   },
--   {
--     "<leader>gcl",
--     mode = "x",
--     [[:lua require("telescope").extensions.advanced_git_search.diff_commit_line()<CR>]],
--     desc = "selected lines Git history",
--   },
--   {
--     "<leader>gcb",
--     function()
--       require("telescope").extensions.advanced_git_search.diff_branch_file()
--     end,
--     desc = "current file diff against other branch",
--   },
--   {
--     "<leader>gcf",
--     function()
--       require("telescope").extensions.advanced_git_search.diff_commit_file()
--     end,
--     desc = "current file Git history",
--   },
--   {
--     "<leader>gclf",
--     function()
--       require("telescope").extensions.advanced_git_search.search_log_content_file()
--     end,
--     desc = "search in file log content",
--   },
--   {
--     "<leader>gclr",
--     function()
--       require("telescope").extensions.advanced_git_search.search_log_content()
--     end,
--     desc = "search in repo log content",
--   },
--   {
--     "<leader>gcs",
--     function()
--       require("telescope").extensions.advanced_git_search.show_custom_functions()
--     end,
--     desc = "show custom AdvancedGitSearch commands",
--   },
--   -- }}} advanced-git-search
-- },

local M = {}

-- Keymaps for snacks-only features (no telescope/fzf-lua equivalent).
-- Called unconditionally at startup regardless of the active picker.
function M.setup_always()
  vim.keymap.set("n", "<leader>fe", function()
    Snacks.explorer()
  end, { desc = "Explorer" })

  vim.keymap.set("n", "gz", function()
    Snacks.bufdelete.delete()
  end, { desc = "Delete buffer" })

  vim.keymap.set("n", "gZ", function()
    Snacks.bufdelete.other()
  end, { desc = "Delete other buffers" })

  vim.keymap.set("n", "<leader>gB", function()
    Snacks.git.blame_line()
  end, { desc = "Show git log for the current line" })

  vim.keymap.set("n", "<leader>;", function()
    Snacks.terminal.toggle()
  end, { desc = "Toggle terminal" })

  -- Snacks toggle menu under <leader>tt
  -- stylua: ignore start
  Snacks.toggle.diagnostics():map("<leader>ttd")
  Snacks.toggle.inlay_hints():map("<leader>tti")
  Snacks.toggle.line_number():map("<leader>ttn")
  Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>ttL")
  Snacks.toggle.treesitter():map("<leader>ttT")
  Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>ttw")
  Snacks.toggle.option("spell", { name = "Spell" }):map("<leader>tts")
  Snacks.toggle.option("conceallevel", { on = 2, off = 0, name = "Conceal Level" }):map("<leader>ttc")
  Snacks.toggle.indent():map("<leader>ttI")
  Snacks.toggle.animate():map("<leader>tta")
  Snacks.toggle.new({
    id = "autoformat_global",
    name = "Auto Format (Global)",
    get = function() return require("plugins.lsp.format").autoformat end,
    set = function(state) require("plugins.lsp.format").autoformat = state end,
  }):map("<leader>ttf")
  Snacks.toggle.new({
    id = "autoformat_buffer",
    name = "Auto Format (Buffer)",
    get = function() return not vim.b.disable_autoformat end,
    set = function(state) vim.b.disable_autoformat = not state end,
  }):map("<leader>ttF")
  Snacks.toggle.new({
    id = "autopairs",
    name = "Auto Pairs",
    get = function() return require("ultimate-autopair").isenabled() end,
    set = function(state)
      if state then require("ultimate-autopair").enable() else require("ultimate-autopair").disable() end
    end,
  }):map("<leader>ttp")
  Snacks.toggle.new({
    id = "render_markdown",
    name = "Render Markdown",
    get = function() return require("render-markdown").get() end,
    set = function(state)
      if state then require("render-markdown").enable() else require("render-markdown").disable() end
    end,
  }):map("<leader>ttm")
  -- stylua: ignore end
  vim.keymap.set("n", "<leader>ttr", function()
    vim.cmd("nohlsearch | diffupdate")
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-L>", true, false, true), "n", false)
  end, { desc = "Redraw / Clear hlsearch / Diff Update" })
  -- stylua: ignore
  vim.keymap.set("n", "<leader>ttN", function() Snacks.notifier.hide() end, { desc = "Dismiss All Notifications" })

  -- Scratch buffers
  -- stylua: ignore start
  vim.keymap.set("n", "<leader>..", function() Snacks.scratch() end, { desc = "Toggle scratch (current ft)" })
  vim.keymap.set("n", "<leader>.s", function() Snacks.scratch.select() end, { desc = "Select scratch buffer" })
  vim.keymap.set("n", "<leader>.g", function() Snacks.scratch({ name = "Notes", ft = "markdown", filekey = { cwd = false, branch = false } }) end, { desc = "Global notes" })
  vim.keymap.set("n", "<leader>.n", function() Snacks.scratch({ name = "Notes", ft = "markdown" }) end, { desc = "Project notes" })
  vim.keymap.set("n", "<leader>.N", function() Snacks.scratch({ name = "Notes", ft = "markdown", filekey = { cwd = true, branch = false } }) end, { desc = "Project notes (all branches)" })
  vim.keymap.set("n", "<leader>.l", function() Snacks.scratch({ ft = "lua" }) end, { desc = "Lua scratch (runnable)" })
  -- stylua: ignore end
end

function M.setup()
  vim.keymap.set("n", "<leader>fe", function()
    Snacks.explorer()
  end, { desc = "Explorer" })

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
  end, { desc = "Search in current buffer (fuzzy)" })

  vim.keymap.set("n", "<leader>/?", function()
    Snacks.picker.grep({ dirs = { vim.api.nvim_buf_get_name(0) } })
  end, { desc = "Grep in current buffer (exact)" })

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

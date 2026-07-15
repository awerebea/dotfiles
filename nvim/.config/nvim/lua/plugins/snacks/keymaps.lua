local M = {}

-- Open a Snacks picker that lists all directories under root (via fd) and
-- lcd to the selected one on confirm.
-- hidden = true by default (show dotdirs); toggle with <a-h>.
-- ignored = false by default (respect .gitignore); toggle with <a-i>.
local function lcd_picker(root, title)
  if not root or root == "" then
    return
  end
  Snacks.picker.pick({
    title = title,
    cwd = root,
    hidden = true,
    ignored = false,
    finder = function(opts, _)
      local cmd = { "fd", "--type", "d", "--follow", "--exclude", ".git" }
      if opts.hidden then
        cmd[#cmd + 1] = "--hidden"
      end
      if opts.ignored then
        cmd[#cmd + 1] = "--no-ignore"
      end
      cmd[#cmd + 1] = "."
      cmd[#cmd + 1] = root
      -- root itself as selectable "." entry; cwd is set so Snacks resolves the
      -- path correctly for display (normalize(root + "/" + ".") = root)
      local items = { { text = ".", file = ".", cwd = root, name = root } }
      local out = vim.fn.systemlist(cmd)
      for _, line in ipairs(out) do
        if line ~= "" then
          local rel = line:sub(#root + 2)
          if rel ~= "" then
            items[#items + 1] = { text = rel, file = rel, cwd = root, name = rel }
          end
        end
      end
      return items
    end,
    format = "file",
    confirm = function(picker, item)
      picker:close()
      if item then
        -- Resolve via Snacks so item.cwd + item.file -> absolute dir path.
        -- vim.schedule defers until after the picker float is fully closed.
        local path = Snacks.picker.util.dir(item)
        vim.schedule(function()
          local ok, err = pcall(vim.cmd, { cmd = "lcd", args = { path } })
          if not ok then
            vim.notify("lcd failed: " .. tostring(err), vim.log.levels.ERROR)
          else
            vim.notify("cwd: " .. vim.fn.getcwd(0), vim.log.levels.INFO)
          end
        end)
      end
    end,
  })
end

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

  vim.keymap.set("n", "<leader>gbl", function()
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

  for _, key in ipairs({ "<leader><CR>", "<leader>bb" }) do
    vim.keymap.set("n", key, function()
      Snacks.picker.buffers({ current = false })
    end, { desc = "Buffers" })
  end

  vim.keymap.set("n", "<leader>ba", function()
    Snacks.picker.buffers({
      hidden = true,
      filter = {
        cwd = false,
        filter = function(item)
          return item.buftype == ""
            and item.name ~= ""
            and not item.name:find("://", 1, true)
            and not item.name:find(vim.fn.stdpath("data") .. "/scratch/", 1, true)
            and (item.info.listed == 1 or vim.api.nvim_buf_is_loaded(item.buf))
        end,
      },
    })
  end, { desc = "All buffers" })

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

  vim.keymap.set("n", "<leader>gbb", function()
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

  -- lcd: picker-based directory navigation
  vim.keymap.set("n", "<leader>cdg", function()
    local dir = vim.fn.expand("%:p:h")
    local out = vim.fn.system({ "git", "-C", dir, "rev-parse", "--show-toplevel" })
    if vim.v.shell_error ~= 0 then
      vim.notify("Not in a git repo", vim.log.levels.WARN)
      return
    end
    lcd_picker(out:gsub("\n$", ""), "lcd: git root")
  end, { desc = "lcd: pick dir under git root" })

  vim.keymap.set("n", "<leader>cdf", function()
    local dir = vim.fn.expand("%:p:h")
    if dir == "" or dir == "." then
      vim.notify("No file in current buffer", vim.log.levels.WARN)
      return
    end
    lcd_picker(dir, "lcd: file dir")
  end, { desc = "lcd: pick dir under file's directory" })

  vim.keymap.set("n", "<leader>cdc", function()
    lcd_picker(vim.fn.getcwd(0), "lcd: cwd")
  end, { desc = "lcd: pick dir under current cwd" })
end

return M

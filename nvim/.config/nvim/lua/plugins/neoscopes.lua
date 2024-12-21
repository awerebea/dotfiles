return {
  "smartpde/neoscopes",
  enabled = false,
  event = "VeryLazy",
  opts = {
    scopes = {
      { name = "nvim", dirs = { vim.fn.stdpath "config" } },
      { name = "<disable>", dirs = {} },
    },
    -- diff_branches_for_scopes = { "main", "dev" }, -- use per-project settings defined in neoscopes.config.json
    -- diff_ancestors_for_scopes = { "main", "dev" }, -- use per-project settings defined in neoscopes.config.json
  },
  config = function(_, opts)
    require("neoscopes").setup(opts)
    local scopes = require "neoscopes"
    if vim.fn.filereadable(vim.fn.stdpath "config" .. "/lua/scopes.lua") == 1 then
      for _, scope in ipairs(require "scopes") do
        scopes.add(scope)
      end
    end

    local project_scopes_file = vim.fn.getcwd(-1, -1) .. "/scopes.lua"
    if vim.fn.filereadable(project_scopes_file) == 1 then
      -- Read the content of the Lua file as a string
      local file_content = table.concat(vim.fn.readfile(project_scopes_file), "\n")
      -- Load the file content as Lua code
      local load_func, err = loadstring(file_content, project_scopes_file)
      if not load_func then
        print("Error loading file:", err)
        return
      end
      -- Execute the loaded Lua code and get the returned value
      local project_scopes = load_func()
      vim.validate { project_scopes = { project_scopes, "table" } }
      for _, scope in ipairs(project_scopes) do
        scopes.add(scope)
      end
    end

    -- scopes.add_startup_scope()

    vim.keymap.set("n", "<leader>ss", function()
      require("neoscopes").select {}
    end, { desc = "Select scope" })

    local function get_search_dirs()
      if not scopes.get_current_scope() or scopes.get_current_scope() == "<disable>" then
        return nil
      end
      return scopes.get_current_paths()
    end

    vim.keymap.set("n", "<leader>ff", function()
      require("telescope.builtin").find_files {
        search_dirs = get_search_dirs(),
        temp__scrolling_limit = 999,
      }
    end, { desc = "Find files" })
    vim.keymap.set("v", "<leader>ff", function()
      require("telescope.builtin").find_files {
        search_dirs = get_search_dirs(),
        default_text = require("utils").get_visual_selection_text()[1],
      }
    end, { desc = "Find files (with selected text)" })
    vim.keymap.set("n", "<leader>f/", function()
      require("telescope.builtin").live_grep {
        search_dirs = get_search_dirs(),
      }
    end, { desc = "Live grep" })
    vim.keymap.set("n", "<leader>f?", function()
      require("telescope").extensions.live_grep_args.live_grep_args {
        search_dirs = get_search_dirs(),
        shorten_path = true,
        word_match = "-w",
        only_sort_text = true,
        search = "",
      }
    end, { desc = "Live grep (custom args)" })
    vim.keymap.set("n", "<leader>fg", function()
      require("telescope.builtin").grep_string {
        search_dirs = get_search_dirs(),
        shorten_path = true,
        word_match = "-w",
        only_sort_text = true,
        search = "",
      }
    end, { desc = "Fuzzy Grep" })
    vim.keymap.set("n", "<leader>fw", function()
      require("telescope.builtin").grep_string {
        search_dirs = get_search_dirs(),
      }
    end, { desc = "Find word under cursor" })
  end,
}

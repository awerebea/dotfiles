return {
  "smartpde/neoscopes",
  enabled = true,
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

    vim.keymap.set("n", "<leader>Sc", function()
      require("neoscopes").select {}
    end, { desc = "Select scope" })
  end,
}

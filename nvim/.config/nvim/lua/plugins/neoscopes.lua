return {
  "smartpde/neoscopes",
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

    scopes.add_startup_scope()

    vim.keymap.set("n", "<leader>ss", function()
      require("neoscopes").select {}
    end, { desc = "Select scope" })

    local function get_search_dirs()
      if scopes.get_current_scope() == "<disable>" then
        return nil
      end
      return scopes.get_current_paths()
    end

    _G.neoscopes_find_files = function()
      require("telescope.builtin").find_files {
        search_dirs = get_search_dirs(),
      }
    end
    _G.neoscopes_live_grep = function()
      require("telescope.builtin").live_grep {
        search_dirs = get_search_dirs(),
      }
    end
    _G.neoscopes_live_grep_args = function()
      require("telescope").extensions.live_grep_args.live_grep_args {
        search_dirs = get_search_dirs(),
        shorten_path = true,
        word_match = "-w",
        only_sort_text = true,
        search = "",
      }
    end
    _G.neoscopes_fuzzy_grep = function()
      require("telescope.builtin").grep_string {
        search_dirs = get_search_dirs(),
        shorten_path = true,
        word_match = "-w",
        only_sort_text = true,
        search = "",
      }
    end

    vim.keymap.set(
      "n",
      "<leader>ff",
      "<Cmd>lua neoscopes_find_files()<CR>",
      { desc = "Find files (menufacture)" }
    )
    vim.keymap.set(
      "n",
      "<leader>f/",
      "<Cmd>lua neoscopes_live_grep()<CR>",
      { desc = "Live grep (menufacture)" }
    )
    vim.keymap.set(
      "n",
      "<leader>f?",
      "<Cmd>lua neoscopes_live_grep_args()<CR>",
      { desc = "Live grep (custom args)" }
    )
    vim.keymap.set(
      "n",
      "<leader>fag",
      "<Cmd>lua neoscopes_fuzzy_grep()<CR>",
      { desc = "Fuzzy Grep (menufacture)" }
    )
  end,
}

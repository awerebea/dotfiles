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
      }
    end, { desc = "Find files (menufacture)" })
    vim.keymap.set("v", "<leader>ff", function()
      require("telescope.builtin").find_files {
        search_dirs = get_search_dirs(),
        default_text = require("utils").get_visual_selection_text()[1],
      }
    end, { desc = "Find files (menufacture)" })
    vim.keymap.set("n", "<leader>f/", function()
      require("telescope.builtin").live_grep {
        search_dirs = get_search_dirs(),
      }
    end, { desc = "Live grep (menufacture)" })
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
    end, { desc = "Fuzzy Grep (menufacture)" })
    vim.keymap.set("n", "<leader>fw", function()
      require("telescope.builtin").grep_string {
        search_dirs = get_search_dirs(),
      }
    end, { desc = "Find word under cursor (menufacture)" })
  end,
}

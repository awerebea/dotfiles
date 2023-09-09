return {
  "smartpde/neoscopes",
  event = "VeryLazy",
  opts = {
    scopes = {
      { name = "nvim", dirs = { vim.fn.stdpath "config" } },
    },
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

    vim.keymap.set(
      "n",
      "<leader>ss",
      [[<cmd>lua require("neoscopes").select()<CR>]],
      { desc = "Select scope" }
    )

    _G.neoscopes_find_files = function()
      require("telescope").extensions.menufacture.find_files {
        search_dirs = scopes.get_current_dirs(),
      }
    end
    _G.neoscopes_find_ignored = function()
      require("telescope.builtin").find_files {
        search_dirs = scopes.get_current_dirs(),
        find_command = {
          "rg",
          "--files",
          "--hidden",
          "-g",
          "!.git",
          "-g",
          "!.venv",
          "--no-ignore",
        },
      }
    end
    _G.neoscopes_grep_ignored = function()
      require("telescope.builtin").live_grep {
        search_dirs = scopes.get_current_dirs(),
        additional_args = { "--no-ignore" },
      }
    end
    _G.neoscopes_live_grep = function()
      require("telescope").extensions.menufacture.live_grep {
        search_dirs = scopes.get_current_dirs(),
      }
    end
    _G.neoscopes_fuzzy_grep = function()
      require("telescope").extensions.live_grep_args.grep_string {
        search_dirs = scopes.get_current_dirs(),
        shorten_path = true,
        word_match = "-w",
        only_sort_text = true,
        search = "",
      }
    end

    vim.keymap.set(
      "n",
      "<leader>sf",
      ":lua neoscopes_find_files()<CR>",
      { desc = "Find files in scope" }
    )
    vim.keymap.set(
      "n",
      "<leader>si",
      ":lua neoscopes_find_ignored()<CR>",
      { desc = "Find files in scope including ignored" }
    )
    vim.keymap.set(
      "n",
      "<leader>s/",
      ":lua neoscopes_live_grep()<CR>",
      { desc = "Live grep in scope" }
    )
    vim.keymap.set(
      "n",
      "<leader>s//",
      ":lua neoscopes_fuzzy_grep()<CR>",
      { desc = "Fuzzy grep in scope" }
    )
    vim.keymap.set(
      "n",
      "<leader>s?",
      ":lua neoscopes_grep_ignored()<CR>",
      { desc = "Live grep in scope including ignored" }
    )
  end,
}

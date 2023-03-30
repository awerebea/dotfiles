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

    -- stylua: ignore
    vim.keymap.set("n", "<leader>ss", [[<cmd>lua require("neoscopes").select()<CR>]], { desc = "Select scope" })

    _G.neoscopes_find_files = function()
      require("telescope.builtin").find_files { search_dirs = scopes.get_current_dirs() }
    end
    _G.neoscopes_find_files_vert = function()
      require("telescope.builtin").find_files {
        layout_strategy = "vertical",
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
    _G.neoscopes_find_ignored_vert = function()
      require("telescope.builtin").find_files {
        layout_strategy = "vertical",
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
    _G.neoscopes_grep_ignored_vert = function()
      require("telescope.builtin").live_grep {
        layout_strategy = "vertical",
        search_dirs = scopes.get_current_dirs(),
        additional_args = { "--no-ignore" },
      }
    end
    _G.neoscopes_live_grep = function()
      require("telescope").extensions.live_grep_args.live_grep_args {
        search_dirs = scopes.get_current_dirs(),
      }
    end
    _G.neoscopes_live_grep_vert = function()
      require("telescope").extensions.live_grep_args.live_grep_args {
        layout_strategy = "vertical",
        search_dirs = scopes.get_current_dirs(),
      }
    end

    -- stylua: ignore
    vim.keymap.set( "n", "<leader>sf", ":lua neoscopes_find_files()<CR>", { desc = "Find files in scope" })
    vim.keymap.set(
      "n",
      "<leader>sfv",
      ":lua neoscopes_find_files_vert()<CR>",
      { desc = "Find files in scope, vertical layout" }
    )
    -- stylua: ignore
    vim.keymap.set( "n", "<leader>si", ":lua neoscopes_find_ignored()<CR>", { desc = "Find files in scope including ignored" })
    vim.keymap.set(
      "n",
      "<leader>siv",
      ":lua neoscopes_find_ignored_vert()<CR>",
      { desc = "Find files in scope including ignored, vertical layout" }
    )
    -- stylua: ignore
    vim.keymap.set( "n", "<leader>s/", ":lua neoscopes_live_grep()<CR>", { desc = "Live grep in scope" })
    vim.keymap.set(
      "n",
      "<leader>s/v",
      ":lua neoscopes_live_grep_vert()<CR>",
      { desc = "Live grep in scope, vertical layout" }
    )
    -- stylua: ignore
    vim.keymap.set( "n", "<leader>s?", ":lua neoscopes_grep_ignored()<CR>", { desc = "Live grep in scope including ignored" })
    vim.keymap.set(
      "n",
      "<leader>s?v",
      ":lua neoscopes_grep_ignored_vert()<CR>",
      { desc = "Live grep in scope including ignored, vertical layout" }
    )
  end,
}

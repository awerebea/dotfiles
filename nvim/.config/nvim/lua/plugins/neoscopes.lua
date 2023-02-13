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
    _G.neoscopes_live_grep = function()
      require("telescope.builtin").live_grep { search_dirs = scopes.get_current_dirs() }
    end

    -- stylua: ignore
    vim.keymap.set( "n", "<leader>sf", ":lua neoscopes_find_files()<CR>", { desc = "Find files in scope" })
    -- stylua: ignore
    vim.keymap.set( "n", "<leader>s/", ":lua neoscopes_live_grep()<CR>", { desc = "Live grep in scope" })
  end,
}

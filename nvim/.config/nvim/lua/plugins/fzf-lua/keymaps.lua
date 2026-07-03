local M = {}

function M.setup()
  local fzf_lua = require("fzf-lua")
  vim.keymap.set("n", "<leader>ff", function()
    fzf_lua.files()
  end, { desc = "Find files" })

  vim.keymap.set("v", "<leader>ff", function()
    require("telescope.builtin").find_files({
      default_text = require("utils").get_visual_selection_text()[1],
    })
  end, { desc = "Find files (with selected text)" })

  vim.keymap.set("n", "<leader>fG", function()
    fzf_lua.git_files()
  end, { desc = "Find Git files" })

  vim.keymap.set("n", "<leader>f/", function()
    fzf_lua.live_grep()
  end, { desc = "Live grep" })

  vim.keymap.set("n", "<leader>fg", function()
    fzf_lua.grep({ search = "" })
  end, { desc = "Fuzzy Grep" })

  vim.keymap.set("n", "<leader>fw", function()
    fzf_lua.grep_cword()
  end, { desc = "Find word under cursor" })

  vim.keymap.set("v", "<leader>fw", function()
    fzf_lua.grep_visual()
  end, { desc = "Find selection" })

  vim.keymap.set("n", "<leader>fF", function()
    fzf_lua.builtin()
  end, { desc = "FzfLua" })

  vim.keymap.set("n", "<leader>fr", function()
    fzf_lua.resume()
  end, { desc = "Resume" })

  vim.keymap.set("n", "<leader><CR>", fzf_lua.buffers, { desc = "FZF Buffers" })

  vim.keymap.set("v", "<leader>8", fzf_lua.grep_visual, { desc = "FZF Selection" })

  vim.keymap.set("n", "<leader>fh", fzf_lua.helptags, { desc = "Help Tags" })

  vim.keymap.set("n", "<leader>//", fzf_lua.blines, { desc = "Search in current buffer (fuzzy)" })

  vim.keymap.set(
    "n",
    "<leader>/?",
    fzf_lua.lgrep_curbuf,
    { desc = "Grep in current buffer (exact)" }
  )

  vim.keymap.set(
    { "n", "x" },
    "<leader>gcf",
    fzf_lua.git_bcommits,
    { desc = "Current file Git history" }
  )

  vim.keymap.set("x", "<leader>gcl", fzf_lua.git_bcommits, { desc = "Selected lines Git history" })

  vim.keymap.set("n", "<leader>gst", fzf_lua.git_status, { desc = "Git status" })
end

return M

local M = {}

function M.setup()
  vim.keymap.set("n", "<leader>ff", function()
    require("fzf-lua").files()
  end, { desc = "Find files" })

  vim.keymap.set("v", "<leader>ff", function()
    require("telescope.builtin").find_files {
      default_text = require("utils").get_visual_selection_text()[1],
    }
  end, { desc = "Find files (with selected text)" })

  vim.keymap.set("n", "<leader>f/", function()
    require("fzf-lua").live_grep()
  end, { desc = "Live grep" })

  vim.keymap.set("n", "<leader>fg", function()
    require("fzf-lua").grep { search = "" }
  end, { desc = "Fuzzy Grep" })

  vim.keymap.set("n", "<leader>fw", function()
    require("fzf-lua").grep_cword()
  end, { desc = "Find word under cursor" })

  vim.keymap.set("n", "<leader>fF", function()
    require("fzf-lua").builtin()
  end, { desc = "FzfLua" })

  vim.keymap.set("n", "<leader>fr", function()
    require("fzf-lua").resume()
  end, { desc = "Resume" })

  -- vim.keymap.set("n", "<leader>r", require("fzf-lua").registers, { desc = "Registers" })

  -- vim.keymap.set("n", "<leader>m", require("fzf-lua").marks, { desc = "Marks" })

  -- vim.keymap.set("n", "<leader>k", require("fzf-lua").keymaps, { desc = "Keymaps" })

  vim.keymap.set("n", "<leader><CR>", require("fzf-lua").buffers, { desc = "FZF Buffers" })

  -- vim.keymap.set("v", "<leader>8", require("fzf-lua").grep_visual, { desc = "FZF Selection" })

  vim.keymap.set("n", "<leader>fw", require("fzf-lua").grep_cword, { desc = "FZF Word" })

  vim.keymap.set("n", "<leader>fh", require("fzf-lua").helptags, { desc = "Help Tags" })

  -- vim.keymap.set(
  --   "n",
  --   "<leader>gc",
  --   require("fzf-lua").git_bcommits,
  --   { desc = "Browse File Commits" }
  -- )

  -- vim.keymap.set("n", "<leader>gs", require("fzf-lua").git_status, { desc = "Git Status" })

  -- vim.keymap.set(
  --   "n",
  --   "<leader>s",
  --   require("fzf-lua").spell_suggest,
  --   { desc = "Spelling Suggestions" }
  -- )

  -- vim.keymap.set(
  --   "n",
  --   "<leader>cj",
  --   require("fzf-lua").lsp_definitions,
  --   { desc = "Jump to Definition" }
  -- )

  -- vim.keymap.set(
  --   "n",
  --   "<leader>cs",
  --   ":lua require'fzf-lua'.lsp_document_symbols({winopts = {preview={wrap='wrap'}}})<cr>",
  --   { desc = "Document Symbols" }
  -- )

  -- vim.keymap.set(
  --   "n",
  --   "<leader>cr",
  --   require("fzf-lua").lsp_references,
  --   { desc = "LSP References" }
  -- )

  -- vim.keymap.set(
  --   "n",
  --   "<leader>cd",
  --   ":lua require'fzf-lua'.diagnostics_document({fzf_opts = { ['--wrap'] = true }})<cr>",
  --   { desc = "Document Diagnostics" }
  -- )

  -- vim.keymap.set(
  --   "n",
  --   "<leader>ca",
  --   ":lua require'fzf-lua'.lsp_code_actions({ winopts = {relative='cursor',row=1.01, col=0, height=0.2, width=0.4} })<cr>",
  --   { desc = "Code Actions" }
  -- )
end

return M

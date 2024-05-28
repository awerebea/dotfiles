return {
  "ggVGc/vim-fuzzysearch",
  cmd = "FuzzySearch",
  keys = { "/", "<M-/>" },
  config = function()
    vim.g.fuzzysearch_prompt = "fuzzy /"
    vim.g.fuzzysearch_hlsearch = 1
    vim.g.fuzzysearch_ignorecase = 1
    vim.g.fuzzysearch_max_history = 30
    vim.g.fuzzysearch_match_spaces = 0
    vim.keymap.set("n", "<M-/>", "/", { noremap = true, desc = "Regex Search" })
    vim.keymap.set("n", "/", "<Cmd>FuzzySearch<CR>", { noremap = false, desc = "Fuzzy Search" })
  end,
}

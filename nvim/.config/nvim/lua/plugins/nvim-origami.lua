return {
  "chrisgrieser/nvim-origami",
  enabled = false,
  event = "VeryLazy",
  opts = {
    autoFold = {
      enabled = true,
      kinds = { "comment", "imports" }, ---@type lsp.FoldingRangeKind[]
    },
    foldKeymaps = {
      setup = true, -- modifies `h`, `l`, and `$`
      hOnlyOpensOnFirstColumn = false,
    },
  }, -- needed even when using default config

  -- recommended: disable vim's auto-folding
  init = function()
    vim.opt.foldlevel = 99
    vim.opt.foldlevelstart = 99
  end,
}

return {
  "mbbill/undotree",
  keys = { { "<leader>u", "<Cmd>UndotreeToggle<CR>" } },
  config = function()
    vim.g.undotree_SetFocusWhenToggle = 1
    vim.g.undotree_WindowLayout = 2
    vim.g.undotree_ShortIndicators = 1
    vim.g.undotree_DiffpanelHeight = 15
  end,
}

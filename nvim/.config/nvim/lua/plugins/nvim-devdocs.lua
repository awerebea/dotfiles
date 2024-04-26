return {
  "luckasRanarison/nvim-devdocs",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  opts = {},
  cmd = {
    "DevdocsFetch",
    "DevdocsInstall",
    "DevdocsUninstall",
    "DevdocsOpen",
    "DevdocsOpenFloat",
    "DevdocsOpenCurrent",
    "DevdocsOpenCurrentFloat",
    "DevdocsUpdate",
    "DevdocsUpdateAll",
  },
  config = function()
    require("nvim-devdocs").setup {
      previewer_cmd = "glow",
      cmd_args = { "-s", "dark", "-w", "80" },
      after_open = function(bufnr)
        vim.api.nvim_buf_set_keymap(bufnr, "n", "<Esc>", "<Cmd>bdelete<CR>", {})
      end,
    }
  end,
}

return {
  "kevinhwang91/nvim-bqf",
  ft = "qf",
  dependencies = { "junegunn/fzf" },
  config = function()
    require("bqf").setup { preview = { auto_preview = false } }
  end,
}

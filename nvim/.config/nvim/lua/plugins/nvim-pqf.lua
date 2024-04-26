return {
  "yorickpeterse/nvim-pqf",
  event = "VeryLazy",
  opts = {
    max_filename_length = 30,
  },
  config = function(_, opts)
    require("pqf").setup(opts)
  end,
}

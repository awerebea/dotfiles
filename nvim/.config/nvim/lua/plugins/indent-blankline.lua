return {
  "lukas-reineke/indent-blankline.nvim",
  main = "ibl",
  event = "BufReadPre",
  opts = {
    indent = {
      char = "│",
      tab_char = "│",
    },
    whitespace = { remove_blankline_trail = true },
    scope = {
      enabled = true,
      show_start = false,
      show_end = false,
      include = {
        node_type = { ["*"] = { "*" } },
      },
    },
  },
  config = function(_, opts)
    require("ibl").setup(opts)
  end,
}

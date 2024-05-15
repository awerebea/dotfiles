return {
  "b0o/incline.nvim",
  enabled = true,
  event = "BufReadPost",
  opts = {
    hide = { cursorline = "focused_win" },
    window = { margin = { vertical = 0 }, overlap = { borders = true } },
    render = function(props)
      local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t")
      local modified = vim.bo[props.buf].modified
      return {
        filename,
        modified and { " *", guifg = "#888888", gui = "bold" } or "",
        guibg = "#292e42",
      }
    end,
  },
  config = function(_, opts)
    require("incline").setup(opts)
    vim.api.nvim_set_hl(0, "InclineNormal", { bg = "#292e42" })
  end,
}

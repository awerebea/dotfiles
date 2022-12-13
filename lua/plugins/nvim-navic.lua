local navic_setup, navic = pcall(require, "nvim-navic")
if not navic_setup then
  return
end

navic.setup({
  highlight = false,
  depth_limit = 0,
  depth_limit_indicator = "..",
  safe_output = true,
})

vim.o.winbar = "%{%v:lua.require'nvim-navic'.get_location()%}"

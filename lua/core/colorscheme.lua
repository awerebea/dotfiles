-- set colorscheme with protected call in case it isn't installed
local status, _ = pcall(vim.cmd, "colorscheme nightfox")
if not status then
  print("Colorscheme not found!") -- print error if colorscheme not installed
  return
end

require("nightfox").setup({
  options = {
    transparent = true, -- Disable setting background
  },
})

vim.cmd("colorscheme nordfox")

-- Common colorschemes options
-- Transparent background
vim.api.nvim_set_hl(0, "Normal", { fg = "NONE", bg = "NONE" })
-- Transparent line number column
vim.api.nvim_set_hl(0, "LineNr", { fg = "NONE", bg = "NONE" })
-- Transparent sign (Git/mark) column
vim.api.nvim_set_hl(0, "SignColumn", { fg = "NONE", bg = "NONE" })
-- Transparent sign fold column
vim.api.nvim_set_hl(0, "FoldColumn", { fg = "NONE", bg = "NONE" })
-- Color of word-wrap column
vim.api.nvim_set_hl(0, "ColorColumn", { bg = "#444444" })
-- Color of non-printable white spaces, with transparent background
vim.api.nvim_set_hl(0, "SpecialKey", { fg = "#626262", bg = "NONE" })
vim.api.nvim_set_hl(0, "NonText", { fg = "#626262", bg = "NONE" })

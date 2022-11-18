-- set colorscheme with protected call in case it isn't installed
local status, _ = pcall(vim.cmd, "colorscheme cobalt2")
if not status then
  print("Colorscheme not found!") -- print error if colorscheme not installed
  return
end

-- Common colorschemes options
vim.cmd([[
highlight Normal          guibg=NONE ctermbg=NONE
highlight LineNr          guibg=NONE ctermbg=NONE
highlight SignColumn      guibg=NONE ctermbg=NONE
highlight FoldColumn      guibg=NONE ctermbg=NONE
highlight ColorColumn     ctermbg=238 guibg=#444444
highlight SpecialKey      term=bold ctermfg=241 guifg=#626262
                          \ ctermbg=NONE guibg=NONE
highlight NonText       term=bold ctermfg=241 guifg=#626262
]])

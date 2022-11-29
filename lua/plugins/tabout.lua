-- import plugin safely
local setup, tabout = pcall(require, "tabout")
if not setup then
  return
end

-- enable plugin
tabout.setup()

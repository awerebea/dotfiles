-- import plugin safely
local setup, nvim_colorizer = pcall(require, "colorizer")
if not setup then
  return
end

-- enable plugin
nvim_colorizer.setup()

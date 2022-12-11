local setup, whichkey = pcall(require, "which-key")
if not setup then
  return
end

whichkey.setup({
  window = {
    border = "single", -- none, single, double, shadow
    position = "bottom", -- bottom, top
  },
})

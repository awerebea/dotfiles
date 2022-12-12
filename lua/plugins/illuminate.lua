local setup, illuminate = pcall(require, "illuminate")
if not setup then
  return
end

illuminate.configure({
  -- provider used to get references in the buffer, ordered by priority
  providers = {
    "regex",
    "lsp",
    "treesitter",
  },
  filetypes_denylist = {
    "dirvish",
    "fugitive",
    "NvimTree",
  },
  delay = 100, -- delay in milliseconds
  min_count_to_highlight = 2, -- minimum number of matches required to perform highlighting
})

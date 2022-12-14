local status, neoclip = pcall(require, "neoclip")
if not status then
  return
end

neoclip.setup({
  default_register = "+",
  keys = {
    telescope = {
      i = {
        select = "<CR>",
        paste = "<C-p>",
        paste_behind = "<C-M-p>",
        replay = "<C-q>", -- replay a macro
        delete = "<C-d>", -- delete an entry
      },
      n = {
        select = "<CR>",
        paste = { "p", "<C-p>" },
        paste_behind = { "P", "<C-M-p>" },
        replay = "q",
        delete = "d",
      },
    },
  },
})

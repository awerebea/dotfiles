return {
  {
    "Exafunction/codeium.vim",
    enabled = true,
    event = "BufEnter",
    -- stylua: ignore
    config = function ()
      vim.g.codeium_manual = true
      vim.g.codeium_disable_bindings = 1
      vim.keymap.set("i", "<M-;>", function() return vim.fn["codeium#Accept"]() end, { expr = true })
      vim.keymap.set("i", "<M-j>", function() return vim.fn["codeium#CycleOrComplete"]() end, { expr = true })
      vim.keymap.set("i", "<M-k>", function() return vim.fn["codeium#CycleCompletions"](-1) end, { expr = true })
      vim.keymap.set("i", "<M-h>", function() return vim.fn["codeium#Clear"]() end, { expr = true })
      vim.keymap.set("i", "<M-w>", function() return vim.fn["codeium#AcceptNextWord"]() end, { expr = true })
      vim.keymap.set("i", "<M-l>", function() return vim.fn["codeium#AcceptNextLine"]() end, { expr = true })
    end,
  },
}

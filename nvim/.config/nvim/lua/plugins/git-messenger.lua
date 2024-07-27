return {
  "rhysd/git-messenger.vim",
  cmd = "GitMessenger",
  keys = { { "<leader>gm", "<Cmd>GitMessenger<CR>", desc = "GitMessenger" } },
  config = function()
    vim.g.git_messenger_always_into_popup = true
    vim.g.git_messenger_floating_win_opts = { border = "single" }
  end,
}

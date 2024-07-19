return {
  "rhysd/git-messenger.vim",
  cmd = "GitMessenger",
  keys = { "<leader>gm", desc = "Git messenger" },
  config = function()
    vim.g.git_messenger_always_into_popup = true
    vim.g.git_messenger_floating_win_opts = { border = "single" }
  end,
}

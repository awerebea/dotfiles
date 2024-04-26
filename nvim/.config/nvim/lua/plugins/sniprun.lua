return {
  "michaelb/sniprun",
  enabled = string.sub(string.lower(vim.loop.os_uname().sysname), 1, string.len "windows")
    ~= "windows",
  event = "VeryLazy",
  branch = "master",
  build = "sh install.sh",
  opts = {},
  config = function(_, opts)
    require("sniprun").setup(opts)
  end,
}

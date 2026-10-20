return {
  "michaelb/sniprun",
  enabled = string.sub(string.lower(vim.uv.os_uname().sysname), 1, string.len("windows"))
    ~= "windows",
  cmd = { "SnipRun", "SnipInfo", "SnipClose", "SnipReset", "SnipLive", "SnipReplMemoryClean" },
  branch = "master",
  build = "sh install.sh",
  opts = {},
  config = function(_, opts)
    require("sniprun").setup(opts)
  end,
}

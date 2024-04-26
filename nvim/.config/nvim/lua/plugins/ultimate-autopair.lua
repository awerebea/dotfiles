return {
  "altermo/ultimate-autopair.nvim",
  enabled = true,
  event = { "InsertEnter", "CmdlineEnter" },
  branch = "v0.6",
  opts = {
    tabout = {
      enable = true,
      map = "<tab>",
      cmap = "<S-tab>",
      multi = false, --use multiple configs (|ultimate-autopair-map-multi-config|)
      hopout = true, -- (|) > tabout > ()|
      do_nothing_if_fail = false, --add a module so that if close fails then a `\t` will not be inserted
    },
  },
}

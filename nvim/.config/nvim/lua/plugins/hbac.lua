return {
  "axkirillov/hbac.nvim",
  event = "VeryLazy",
  opts = {
    autoclose = false, -- set autoclose to false if you want to close manually
    telescope = {
      -- mappings = {
      --   i = {
      --     ["<M-c>"] = actions.close_unpinned,
      --     ["<M-x>"] = actions.delete_buffer,
      --     ["<M-a>"] = actions.pin_all,
      --     ["<M-u>"] = actions.unpin_all,
      --     ["<M-y>"] = actions.toggle_pin,
      --   },
      -- },
    },
  },
  config = true,
}

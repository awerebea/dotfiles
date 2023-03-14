return {
  "nvim-tree/nvim-tree.lua",
  cmd = { "NvimTreeToggle" },
  keys = {
    { "<F2>", "<Cmd>NvimTreeToggle<CR>", desc = "Explorer" },
    {
      "<leader><F2>",
      "<Cmd>NvimTreeFindFile <CR> <bar> <Cmd>NvimTreeFocus<CR>",
      desc = "Explorer",
    },
  },
  opts = {
    disable_netrw = false,
    hijack_netrw = true,
    respect_buf_cwd = true,
    view = {
      number = true,
      relativenumber = true,
      adaptive_size = true,
      mappings = {
        list = {
          { key = "u", action = "dir_up" },
          { key = "h", action = "close_node" },
          { key = "l", action = "edit" },
        },
      },
    },
    filters = {
      custom = { ".git" },
    },
    sync_root_with_cwd = true,
    prefer_startup_root = true,
    update_focused_file = {
      enable = false,
      update_root = true,
    },
    actions = {
      open_file = {
        quit_on_open = true,
        window_picker = {
          enable = false,
        },
      },
    },
    renderer = {
      icons = {
        glyphs = {
          folder = {
            arrow_closed = "", -- arrow when folder is closed
            arrow_open = "", -- arrow when folder is open
          },
        },
      },
    },
    sort_by = "case_sensitive",
    --  git = {
    --    ignore = false,
    --  },
  },
  config = function(_, opts)
    -- recommended settings from nvim-tree documentation
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1
    -- change color for arrows in tree to light blue
    vim.api.nvim_command "highlight NvimTreeIndentMarker guifg=#3FC5FF"
    require("nvim-tree").setup(opts)
  end,
}

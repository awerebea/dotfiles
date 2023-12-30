return {
  "zbirenbaum/copilot.lua",
  enabled = true,
  cmd = "Copilot",
  event = "InsertEnter",
  opts = {
    panel = {
      enabled = true,
      auto_refresh = true,
      keymap = {
        jump_prev = "[[",
        jump_next = "]]",
        accept = "<M-CR>",
        refresh = "gr",
        open = "<S-CR>",
      },
      layout = {
        position = "bottom", -- | top | left | right
        ratio = 0.4,
      },
    },
    suggestion = {
      enabled = true,
      auto_trigger = true,
      debounce = 75,
      keymap = {
        accept = "<M-l>",
        accept_word = "<M-w>",
        accept_line = "<M-a>",
        next = "<M-]>",
        prev = "<M-[>",
        dismiss = "<C-]>",
      },
    },
    filetypes = {
      yaml = true,
      markdown = true,
      help = false,
      gitcommit = true,
      gitrebase = false,
      hgcommit = false,
      svn = false,
      cvs = false,
      ["."] = false,
      sh = function()
        local buf_name = vim.api.nvim_buf_get_name(0)
        local basename = vim.fn.fnamemodify(buf_name, ":t")
        if basename and string.match(basename, "^%.env.*") then
          -- disable for .env files
          return false
        end
        return true
      end,
    },
    copilot_node_command = "node", -- Node.js version must be > 16.x
    server_opts_overrides = {},
  },
  config = function(_, opts)
    require("copilot").setup(opts)
    -- vim.keymap.set("n", "<leader>cp", "<Cmd>Copilot panel<CR>", { noremap = true, silent = true }) -- used for path copying
  end,
}

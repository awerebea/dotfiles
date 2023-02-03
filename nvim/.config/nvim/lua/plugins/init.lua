return {
  "nvim-lua/plenary.nvim",
  "MunifTanjim/nui.nvim",
  "nvim-tree/nvim-web-devicons",
  { "nacro90/numb.nvim", event = "BufReadPre", config = true },
  {
    "lukas-reineke/indent-blankline.nvim",
    event = "BufReadPre",
    opts = {
      show_current_context = true,
      show_current_context_start = false,
      show_end_of_line = true,
      space_char_blankline = " ",
    },
  },
  {
    "stevearc/dressing.nvim",
    event = "VeryLazy",
    opts = {
      input = { relative = "editor" },
      select = {
        backend = { "telescope", "fzf", "builtin" },
      },
    },
  },
  {
    "rcarriga/nvim-notify",
    event = "VeryLazy",
    opts = {
      timeout = 3000,
      max_height = function()
        return math.floor(vim.o.lines * 0.75)
      end,
      max_width = function()
        return math.floor(vim.o.columns * 0.75)
      end,
    },
    config = function(_, opts)
      require("notify").setup(opts)
      vim.notify = require "notify"
    end,
  },
  {
    "monaqa/dial.nvim",
    keys = {
      "<C-a>",
      "<C-x>",
      { "<C-a>", "v" },
      { "<C-x>", "v" },
      { "g<C-a>", "v" },
      { "g<C-x>", "v" },
    },
    -- stylua: ignore
    init = function()
      local augend = require("dial.augend")
      require("dial.config").augends:register_group{
        default = {
          augend.constant.alias.bool,
          augend.integer.alias.decimal_int,
          augend.integer.alias.hex,
          augend.date.alias["%Y/%m/%d"],
          augend.date.alias["%Y-%m-%d"],
          augend.date.alias["%m/%d"],
          augend.date.alias["%H:%M"],
          augend.semver.alias.semver,
          augend.constant.new{
            elements = {"and", "or"},
            word = true, -- if false, "sand" is incremented into "sor", "doctor" into "doctand", etc.
            cyclic = true,  -- "or" is incremented into "and".
          },
          augend.constant.new{
            elements = {"&&", "||"},
            word = false,
            cyclic = true,
          },
          augend.constant.new{
            elements = {"False", "True"},
            word = true,
            cyclic = true,
          },
        },
      }
      vim.api.nvim_set_keymap(
        "n", "<C-a>", require("dial.map").inc_normal(), { desc = "Increment", noremap = true })
      vim.api.nvim_set_keymap(
        "n", "<C-x>", require("dial.map").dec_normal(), { desc = "Decrement", noremap = true })
      vim.api.nvim_set_keymap(
        "v", "<C-a>", require("dial.map").inc_visual(), { desc = "Increment", noremap = true })
      vim.api.nvim_set_keymap(
        "v", "<C-x>", require("dial.map").dec_visual(), { desc = "Decrement", noremap = true })
      vim.api.nvim_set_keymap(
        "v", "g<C-a>", require("dial.map").inc_gvisual(), { desc = "Increment", noremap = true })
      vim.api.nvim_set_keymap(
        "v", "g<C-x>", require("dial.map").dec_gvisual(), { desc = "Decrement", noremap = true })
    end,
  },
  {
    "andymass/vim-matchup",
    event = "BufReadPost",
    config = function()
      vim.g.matchup_matchparen_offscreen = { method = "popup" }
    end,
  },
  { "tpope/vim-surround", event = "VeryLazy" },
  { "tpope/vim-repeat", event = "VeryLazy" },
  { "tpope/vim-unimpaired", event = "VeryLazy" },
  {
    "numToStr/Comment.nvim",
    dependencies = { "JoosepAlviste/nvim-ts-context-commentstring" },
    keys = { "gc", "gcc", "gbc" },
    config = function(_, _)
      local opts = {
        ignore = "^$",
        pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
      }
      require("Comment").setup(opts)
    end,
  },
  { "christoomey/vim-tmux-navigator", event = "VimEnter" },
  {
    "adoyle-h/lsp-toggle.nvim",
    cmd = { "ToggleLSP", "ToggleNullLSP" },
    config = true,
  },
  {
    "szw/vim-maximizer",
    keys = { { "<leader>z", "<Cmd>MaximizerToggle<CR>", mode = { "n", "v" } } },
  },
  {
    "simeji/winresizer",
    cmd = "WinResizerStartResize",
    keys = { "<C-e>" },
    config = function(_, _)
      vim.g.winresizer_finish_with_escape = 1
    end,
  },
  {
    "folke/todo-comments.nvim",
    event = "VeryLazy",
    config = true,
  },
  {
    "norcalli/nvim-colorizer.lua",
    event = "VeryLazy",
    config = function()
      require("colorizer").setup()
    end,
  },
  {
    "tiagovla/scope.nvim",
    event = "VeryLazy",
    config = true,
  },
  {
    "famiu/bufdelete.nvim",
    cmd = "Bdelete",
    keys = { { "gz", "<Cmd>Bdelete<CR>" } },
  },
  {
    "rhysd/git-messenger.vim",
    cmd = "GitMessenger",
    keys = { "<leader>gm" },
    config = function()
      vim.g.git_messenger_always_into_popup = true
      vim.g.git_messenger_floating_win_opts = { border = "single" }
    end,
  },
  {
    "kevinhwang91/nvim-bqf",
    ft = "qf",
    dependencies = { "junegunn/fzf" },
  },
  {
    "chentoast/marks.nvim",
    event = "VeryLazy",
    opts = { force_write_shada = true },
  },
  {
    "mbbill/undotree",
    keys = { { "<leader>u", "<Cmd>UndotreeToggle<CR>" } },
    config = function()
      vim.g.undotree_SetFocusWhenToggle = 1
    end,
  },
  {
    "windwp/nvim-spectre",
    cmd = { "Spectre" },
    keys = {
      { "<leader>S", "<Cmd>Spectre<CR>", { desc = "Find and replace with Spectre" } },
      -- search current word
      { "<leader>sw", "<Cmd>lua require('spectre').open_visual({select_word=true})<CR>" },
      { "<leader>s", "<Esc><Cmd>lua require('spectre').open_visual()<CR>", mode = "v" },
      -- search in current file
      { "<leader>sf", "<Cmd>lua require('spectre').open_file_search()<CR>" },
    },
    config = true,
  },
  {
    "ThePrimeagen/harpoon",
    keys = {
      { "<leader><leader>m", '<Cmd>lua require("harpoon.mark").add_file()<CR>' },
      { "]h", '<Cmd>lua require("harpoon.ui").nav_next()<CR>' },
      { "[h", '<Cmd>lua require("harpoon.ui").nav_prev()<CR>' },
      { "<leader>m", '<Cmd>lua require("harpoon.ui").toggle_quick_menu()<CR>' },
      { "<leader>fm", "<Cmd>Telescope harpoon marks<CR>" },
    },
    config = true,
  },
  {
    cmd = { "DiffviewOpen" },
    "sindrets/diffview.nvim",
  },
  {
    "Shatur/neovim-session-manager",
    event = "VimEnter",
    config = function()
      require("session_manager").setup {
        -- Disabled, CurrentDir, LastSession
        autoload_mode = require("session_manager.config").AutoloadMode.CurrentDir,
        path_replacer = "@_@",
        colon_replacer = "@+@",
        autosave_last_session = true,
        -- Do not save when no buffers are opened, or all of them aren't writable or listed.
        autosave_ignore_not_normal = true,
        autosave_ignore_dirs = {},
        autosave_ignore_filetypes = {
          "gitcommit",
          "gitrebase",
          "toggleterm",
        },
        autosave_ignore_buftypes = {},
        autosave_only_in_session = false,
        max_path_length = 80,
      }
      vim.keymap.set(
        "n",
        "<leader>qs",
        "<Cmd>SessionManager load_current_dir_session<CR>",
        { desc = "Restore the session for the current directory" }
      )
      vim.keymap.set(
        "n",
        "<leader>qq",
        "<Cmd>SessionManager load_session<CR>",
        { desc = "Select and restore the session" }
      )
      vim.keymap.set(
        "n",
        "<leader>ql",
        "<Cmd>SessionManager load_last_session<CR>",
        { desc = "Restore the last session" }
      )
      vim.keymap.set(
        "n",
        "<leader>qd",
        "<Cmd>SessionManager delete_session<CR>",
        { desc = "Delete session" }
      )
    end,
  },
}

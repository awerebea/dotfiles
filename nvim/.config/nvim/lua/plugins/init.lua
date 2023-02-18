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
    event = "VeryLazy",
    config = function()
      vim.keymap.set(
        { "n", "v" },
        "<leader>z",
        "<Cmd>MaximizerToggle<CR>",
        { desc = "Maximize window toggle" }
      )
    end,
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
      vim.g.undotree_WindowLayout = 2
      vim.g.undotree_ShortIndicators = 1
      vim.g.undotree_DiffpanelHeight = 15
    end,
  },
  {
    "windwp/nvim-spectre",
    cmd = { "Spectre" },
    keys = {
      { "<leader>Ss", "<Cmd>Spectre<CR>" },
      -- search current word
      { "<leader>Sw", "<Cmd>lua require('spectre').open_visual({select_word=true})<CR>" },
      -- search in current file
      { "<leader>Sf", "<Cmd>lua require('spectre').open_file_search()<CR>" },
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
    "mfussenegger/nvim-treehopper",
    event = "VeryLazy",
    config = function()
      vim.keymap.set("o", "<leader>m", [[:<C-U>lua require('tsht').nodes()<CR>]])
      vim.keymap.set("v", "m", [[:lua require("tsht").nodes()<CR>]])
    end,
  },
  {
    "petertriho/nvim-scrollbar",
    event = "BufReadPre",
    opts = { marks = { GitChange = { text = "│" } } },
    config = function(_, otps)
      require("scrollbar").setup(otps)
    end,
  },
  {
    "luukvbaal/statuscol.nvim",
    event = "VeryLazy",
    opts = {
      foldfunc = "builtin",
      setopt = true,
    },
    config = function(_, opts)
      if vim.fn.has "nvim-0.9" == 1 then
        require("statuscol").setup(opts)
      end
    end,
  },
  {
    "m4xshen/smartcolumn.nvim",
    event = "VeryLazy",
    opts = {
      colorcolumn = 100,
    },
    config = true,
  },
}

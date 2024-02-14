return {
  "nvim-lua/plenary.nvim",
  "MunifTanjim/nui.nvim",
  "nvim-tree/nvim-web-devicons",
  { "nacro90/numb.nvim", event = "BufReadPre", config = true },
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = "BufReadPre",
    opts = {
      indent = {
        char = "│",
        tab_char = "│",
      },
      whitespace = { remove_blankline_trail = true },
      scope = {
        enabled = true,
        show_start = false,
        show_end = false,
        include = {
          node_type = { ["*"] = { "*" } },
        },
      },
    },
    config = function(_, opts)
      require("ibl").setup(opts)
    end,
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
      timeout = 2500,
      max_height = function()
        return math.floor(vim.o.lines * 0.75)
      end,
      max_width = function()
        return math.floor(vim.o.columns * 0.75)
      end,
      render = "wrapped-compact",
      top_down = false,
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
          augend.integer.alias.decimal,
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
          augend.constant.new{
            elements = {"on", "off"},
            word = true,
            cyclic = true,
          },
          augend.constant.new{
            elements = {"On", "Off"},
            word = true,
            cyclic = true,
          },
          augend.constant.new{
            elements = {"left", "center", "right"},
            word = true,
            cyclic = true,
          },
          augend.constant.new{
            elements = {"Left", "Center", "Right"},
            word = true,
            cyclic = true,
          },
          augend.constant.new{
            elements = {"LEFT", "CENTER", "RIGHT"},
            word = true,
            cyclic = true,
          },
          augend.constant.new{
            elements = {"Jan", "Feb", "Mar", "Apr", "May", "Jun",
                        "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"},
            word = true,
            cyclic = true,
          },
          augend.constant.new{
            elements = {"January", "February", "March", "April", "May", "June",
                        "July", "August", "September", "October", "November", "December"},
            word = true,
            cyclic = true,
          },
        },
      }
      vim.keymap.set(
        "n", "<C-a>", require("dial.map").inc_normal(), { desc = "Increment", noremap = true })
      vim.keymap.set(
        "n", "<C-x>", require("dial.map").dec_normal(), { desc = "Decrement", noremap = true })
      vim.keymap.set(
        "v", "<C-a>", require("dial.map").inc_visual(), { desc = "Increment", noremap = true })
      vim.keymap.set(
        "v", "<C-x>", require("dial.map").dec_visual(), { desc = "Decrement", noremap = true })
      vim.keymap.set(
        "v", "g<C-a>", require("dial.map").inc_gvisual(), { desc = "Increment", noremap = true })
      vim.keymap.set(
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
  { "tpope/vim-repeat", event = "VeryLazy" },
  {
    "adoyle-h/lsp-toggle.nvim",
    event = "VeryLazy",
    config = function()
      require("lsp-toggle").setup()
      vim.keymap.set("n", "<leader>tgl", "<Cmd>ToggleLSP<CR>", { desc = "Toggle LSP" })
      vim.keymap.set("n", "<leader>tgn", "<Cmd>ToggleNullLSP<CR>", { desc = "Toggle Null LSP" })
    end,
  },
  {
    "simeji/winresizer",
    cmd = "WinResizerStartResize",
    keys = { "<C-e>" },
    config = function(_, _)
      vim.g.winresizer_finish_with_escape = 1
      vim.g.winresizer_vert_resize = 3
      vim.g.winresizer_horiz_resize = 3
    end,
  },
  {
    "mrjones2014/smart-splits.nvim",
    event = "VeryLazy",
    opts = {
      at_edge = "wrap",
      disable_multiplexer_nav_when_zoomed = true,
      cursor_follows_swapped_bufs = true,
      -- {{{ Use winresizer plugin instead
      -- resize_mode = {
      --   silent = true,
      --   hooks = {
      --     on_enter = function()
      --       print 'Persistent resize mode enabled. Use { "h", "j", "k", "l" } to resize, and <ESC> to finish.'
      --     end,
      --     on_leave = function()
      --       print "Persistent resize mode disabled. Normal keymaps have been restored."
      --     end,
      --   },
      -- },
      -- }}}
    },
    config = function(_, opts)
      require("smart-splits").setup(opts)
      -- moving between splits
      vim.keymap.set("n", "<C-h>", require("smart-splits").move_cursor_left)
      vim.keymap.set("n", "<C-j>", require("smart-splits").move_cursor_down)
      vim.keymap.set("n", "<C-k>", require("smart-splits").move_cursor_up)
      vim.keymap.set("n", "<C-l>", require("smart-splits").move_cursor_right)
      -- {{{ Use winresizer plugin instead
      -- vim.keymap.set("n", "<C-e>", function()
      --   require("smart-splits").start_resize_mode()
      -- end, { desc = "Start resize mode" })
      -- The following keymaps are used by mini.move plugin
      -- vim.keymap.set("n", "<A-h>", require("smart-splits").resize_left)
      -- vim.keymap.set("n", "<A-j>", require("smart-splits").resize_down)
      -- vim.keymap.set("n", "<A-k>", require("smart-splits").resize_up)
      -- vim.keymap.set("n", "<A-l>", require("smart-splits").resize_right)
      -- swapping buffers between windows
      -- The following keymaps are used by hop plugin
      -- vim.keymap.set("n", "<leader><leader><leader><leader>h", require("smart-splits").swap_buf_left)
      -- vim.keymap.set("n", "<leader><leader><leader><leader>j", require("smart-splits").swap_buf_down)
      -- vim.keymap.set("n", "<leader><leader><leader><leader>k", require("smart-splits").swap_buf_up)
      -- vim.keymap.set("n", "<leader><leader><leader><leader>l", require("smart-splits").swap_buf_right)
      -- }}}
    end,
  },
  {
    "anuvyklack/windows.nvim",
    event = "VeryLazy",
    dependencies = { "anuvyklack/middleclass" },
    opts = { autowidth = { winwidth = 12 } },
    config = function(_, opts)
      vim.opt.winminwidth = 5
      vim.opt.winheight = 5
      vim.opt.winminheight = 0
      vim.opt.equalalways = false
      require("windows").setup(opts)
      local function cmd(command)
        return table.concat { "<Cmd>", command, "<CR>" }
      end
      vim.keymap.set("n", "<C-w>z", cmd "WindowsMaximize")
      vim.keymap.set("n", "<leader>z", cmd "WindowsMaximize")
      vim.keymap.set("n", "<C-w>-", cmd "WindowsMaximizeVertically")
      vim.keymap.set("n", "<C-w>\\", cmd "WindowsMaximizeHorizontally")
      vim.keymap.set("n", "<C-w>=", cmd "WindowsEqualize")
      vim.keymap.set("n", "<C-w>t", cmd "WindowsToggleAutowidth")
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
    "ojroques/nvim-bufdel",
    cmd = {
      "BufDel",
      "BufDelAll",
      "BufDelOthers",
    },
    keys = {
      { "gz", "<Cmd>BufDel<CR>", desc = "Delete buffer" },
      { "gZ", "<Cmd>BufDelOthers<CR>", desc = "Delete other buffers" },
    },
    opts = { next = "tabs", quit = false },
    config = true,
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
    config = function()
      if vim.fn.has "nvim-0.9" == 1 then
        local builtin = require "statuscol.builtin"
        require("statuscol").setup {
          relculright = true,
          segments = {
            { text = { "%s" }, click = "v:lua.ScSa" },
            { text = { builtin.lnumfunc }, click = "v:lua.ScLa" },
            { text = { " ", builtin.foldfunc, " " }, click = "v:lua.ScFa" },
          },
        }
      end
    end,
  },
  {
    "s1n7ax/nvim-window-picker",
    enabled = true,
    version = "2.0.1",
    keys = { "<leader>w" },
    opts = {
      fg_color = "#000000",
      other_win_hl_color = "#1abc9c",
      hint = "floating-big-letter",
      show_prompt = false,
      picker_config = { floating_big_letter = { font = "ansi-shadow" } },
      filter_rules = {
        autoselect_one = true,
        include_current_win = false,
        bo = {
          filetype = { "NvimTree", "neo-tree", "neo-tree-popup", "notify", "incline", "fidget" },
          buftype = { "terminal", "quickfix" },
        },
      },
    },
    config = function(_, opts)
      local picker = require "window-picker"
      picker.setup(opts)
      vim.keymap.set("n", "<leader>w", function()
        local picked_window_id = picker.pick_window() or vim.api.nvim_get_current_win()
        vim.api.nvim_set_current_win(picked_window_id)
      end, { desc = "Pick a window" })
    end,
  },
  {
    "machakann/vim-swap",
    event = "VeryLazy",
    config = function()
      vim.api.nvim_del_keymap("n", "gs")
      vim.keymap.set(
        "n",
        "<leader>sw",
        "<Plug>(swap-interactive)",
        { noremap = false, desc = "Swap interactive" }
      )
    end,
  },
  {
    "Wansmer/treesj",
    dependencies = { "nvim-treesitter" },
    opts = {
      use_default_keymaps = false,
      max_join_length = 120,
    },
    keys = {
      { "<leader>gS", "<Cmd>TSJSplit<CR>", desc = "TreeSJ Split" },
      { "<leader>gJ", "<Cmd>TSJJoin<CR>", desc = "TreeSJ Join" },
      { "<leader>gT", "<Cmd>TSJToggle<CR>", desc = "TreeSJ Toggle" },
    },
    config = function(_, opts)
      require("treesj").setup(opts)
    end,
  },
  {
    "Bekaboo/deadcolumn.nvim",
    event = "VeryLazy",
    opts = {
      scope = function()
        local max = nil
        max = 0
        for i = -500, 500 do -- number of lines before and after the current line
          local len = vim.fn.strdisplaywidth(vim.fn.getline(vim.fn.line "." + i))
          if len > max then
            max = len
          end
        end
        return max
      end,
      -- -@type string[]|fun(mode: string): boolean
      modes = function(mode)
        return mode:find "^[icntRss\x13]" ~= nil
      end,
    },
  },
  {
    "SmiteshP/nvim-navbuddy",
    keys = {
      { "<leader>nb", "<Cmd>Navbuddy<CR>", desc = "Navbuddy" },
    },
    dependencies = {
      "neovim/nvim-lspconfig",
      "SmiteshP/nvim-navic",
      "MunifTanjim/nui.nvim",
      "numToStr/Comment.nvim",
      "nvim-telescope/telescope.nvim",
    },
    opts = {
      lsp = {
        auto_attach = true,
        preference = { "pyright" },
      },
    },
    config = true,
  },
  {
    "b0o/incline.nvim",
    enabled = false, -- Disabled as conflicts with vim-maximizer
    event = "VeryLazy",
    opts = { hide = { cursorline = "focused_win" } },
    config = true,
  },
  {
    "AckslD/muren.nvim",
    event = "VeryLazy",
    keys = {
      { "<leader>Mt", "<Cmd>MurenToggle<CR>" },
      { "<leader>Mo", "<Cmd>MurenOpen<CR>" },
      { "<leader>Mc", "<Cmd>MurenClose<CR>" },
      { "<leader>Mf", "<Cmd>MurenFresh<CR>" },
      { "<leader>Mu", "<Cmd>MurenUnique<CR>" },
    },
    config = true,
  },
  {
    enabled = false,
    "m4xshen/hardtime.nvim",
    event = "VeryLazy",
    dependencies = { "MunifTanjim/nui.nvim", "nvim-lua/plenary.nvim" },
    opts = { restricted_keys = { ["<CR>"] = {} } },
  },
  {
    "sustech-data/wildfire.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = true,
  },
  {
    "luckasRanarison/nvim-devdocs",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    opts = {},
    cmd = {
      "DevdocsFetch",
      "DevdocsInstall",
      "DevdocsUninstall",
      "DevdocsOpen",
      "DevdocsOpenFloat",
      "DevdocsOpenCurrent",
      "DevdocsOpenCurrentFloat",
      "DevdocsUpdate",
      "DevdocsUpdateAll",
    },
    config = function()
      require("nvim-devdocs").setup {
        previewer_cmd = "glow",
        cmd_args = { "-s", "dark", "-w", "80" },
        after_open = function(bufnr)
          vim.api.nvim_buf_set_keymap(bufnr, "n", "<Esc>", "<Cmd>bdelete<CR>", {})
        end,
      }
    end,
  },
  {
    -- "ThePrimeagen/git-worktree.nvim",
    "brandoncc/git-worktree.nvim",
    branch = "catch-and-handle-telescope-related-error",
    opts = {},
    config = function()
      require("telescope").load_extension "git_worktree"
      local Worktree = require "git-worktree"
      Worktree.on_tree_change(function(op, metadata)
        if op == Worktree.Operations.Switch then
          print("Switched from " .. metadata.prev_path .. " to " .. metadata.path)
        elseif op == Worktree.Operations.Create then
          print(
            "Worktree created: "
              .. metadata.path
              .. " for branch "
              .. metadata.branch
              .. " with upstream "
              .. metadata.upstream
          )
        elseif op == Worktree.Operations.Delete then
          print("Worktree deleted: " .. metadata.path)
        end
      end)
    end,
    dependencies = {
      "nvim-telescope/telescope.nvim",
    },
    keys = {
      {
        "<leader>gwm",
        function()
          require("telescope").extensions.git_worktree.git_worktrees()
        end,
        desc = "Manage",
      },
      {
        "<leader>gwa",
        function()
          require("telescope").extensions.git_worktree.create_git_worktree()
        end,
        desc = "Add",
      },
    },
  },
  {
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
  },
  {
    "Aasim-A/scrollEOF.nvim",
    event = "VeryLazy",
    config = true,
  },
  { "tpope/vim-eunuch", event = "VeryLazy" },
  {
    "tpope/vim-abolish",
    event = "VeryLazy",
    config = function()
      vim.keymap.del("n", "cr")
    end,
  },
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {
      modes = {
        char = { enabled = false },
        search = { enabled = false },
      },
      label = {
        rainbow = {
          enabled = false,
          shade = 3, -- number between 1 and 9
        },
      },
    },
    -- stylua: ignore
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
      { "S", mode = { "n", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
      { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
      { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
      { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
    },
  },
  {
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
  },
  {
    "stevearc/oil.nvim",
    event = "VeryLazy",
    opts = {
      default_file_explorer = false,
    },
    -- Optional dependencies
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = true,
  },
  {
    "kylechui/nvim-surround",
    version = "*", -- Use for stability; omit to use `main` branch for the latest features
    event = "VeryLazy",
    opts = {
      keymaps = {
        -- override default mapping to avoid conflict with mini.splitjoin plugin
        visual_line = "<leader>gS",
      },
    },
    config = function(_, opts)
      require("nvim-surround").setup(opts)
    end,
  },
  {
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
  },
  {
    "yorickpeterse/nvim-pqf",
    event = "VeryLazy",
    opts = {
      max_filename_length = 30,
    },
    config = function(_, opts)
      require("pqf").setup(opts)
    end,
  },
  { "wellle/targets.vim", event = "VeryLazy" },
  {
    "backdround/improved-ft.nvim",
    enabled = not require("utils").is_windows(),
    event = "VeryLazy",
    config = function()
      local ft = require "improved-ft"
      ft.setup {
        -- Maps default f/F/t/T/;/, keys, default: false
        use_default_mappings = true,
        -- Ignores case of the given characters, default: false.
        ignore_char_case = false,
        -- Takes a last jump direction into account during repetition jumps, default: false.
        use_relative_repetition = true,
      }

      local imap = function(key, fn, description)
        vim.keymap.set("i", key, fn, { desc = description })
      end

      imap("<M-f>", ft.hop_forward_to_char, "Hop forward to a given char")
      imap("<M-F>", ft.hop_backward_to_char, "Hop forward to a given char")

      imap("<M-t>", ft.hop_forward_to_pre_char, "Hop forward before a given char")
      imap("<M-T>", ft.hop_backward_to_pre_char, "Hop forward before a given char")

      imap("<M-;>", ft.repeat_forward, "Repeat hop forward to a last given char")
      imap("<M-,>", ft.repeat_backward, "Repeat hop backward to a last given char")
    end,
  },
  {
    "backdround/neowords.nvim",
    enabled = false, -- not require("utils").is_windows(),
    event = "VeryLazy",
    config = function()
      local neowords = require "neowords"
      local presets = neowords.pattern_presets

      local hops = neowords.get_word_hops(
        "\\v,+",
        "\\v\\.+",
        "\\v['\"]+", -- '"
        "\\v[\\(\\)\\{\\}\\[\\]]+", -- (){}[]
        -- "\\v[\\(\\)]+", -- ()
        -- "\\v[\\[\\]]+", -- []
        -- "\\v[\\{\\}]+", -- {}
        presets.camel_case,
        presets.hex_color,
        presets.number,
        presets.snake_case,
        presets.upper_case
      )

      vim.keymap.set({ "n", "x", "o" }, "w", hops.forward_start)
      vim.keymap.set({ "n", "x", "o" }, "e", hops.forward_end)
      vim.keymap.set({ "n", "x", "o" }, "b", hops.backward_start)
      vim.keymap.set({ "n", "x", "o" }, "ge", hops.backward_end)
    end,
  },
}

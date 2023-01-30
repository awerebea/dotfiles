return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
      "nvim-telescope/telescope-file-browser.nvim",
      "nvim-telescope/telescope-project.nvim",
      "ahmedkhalf/project.nvim",
      "cljoly/telescope-repo.nvim",
      "stevearc/aerial.nvim",
      "folke/trouble.nvim",
      "kiyoon/telescope-insert-path.nvim",
      "AckslD/nvim-neoclip.lua",
    },
    cmd = "Telescope",
    keys = {
      -- find files within current working directory, respects .gitignore
      { "<leader>fg", "<Cmd>Telescope find_files<CR>", desc = "Find Files" },
      { "<C-p>", "<Cmd>Telescope find_files<CR>", desc = "Find Files" },
      { "<leader>ff", require("utils").find_files, desc = "Find Files" },
      -- find string in current workspace as you type
      { "<leader>f/", "<Cmd>Telescope live_grep<CR>", desc = "Workspace" },
      -- find word under cursor in current working directory
      { "<leader>fw", "<Cmd>Telescope grep_string<CR>", desc = "Word under cursor" },
      -- list open buffers in current neovim instance
      { "<leader>fb", "<Cmd>Telescope buffers<cr>", desc = "Buffers" },
      { "<leader><CR>", "<Cmd>Telescope buffers<cr>", desc = "Buffers" },

      { "<leader>fh", "<Cmd>Telescope help_tags<cr>", desc = "Help tags" },

      -- repeat last telescope command and query
      { "<leader>fr", "<Cmd>Telescope resume<CR>", desc = "Resume" },
      { "<leader>fo", "<Cmd>Telescope oldfiles<cr>", desc = "Recent" },
      { "<leader>fab", "<Cmd>Telescope file_browser<cr>", desc = "File browser" },
      { "<leader>far", "<Cmd>Telescope repo list<cr>", desc = "Search" },
      {
        "<leader>fap",
        function()
          require("telescope").extensions.project.project { display_type = "minimal" }
        end,
        desc = "List",
      },
      {
        "<leader>faf",
        function()
          require("telescope.builtin").current_buffer_fuzzy_find()
        end,
        desc = "Buffer",
      },
      { "<leader>fao", "<cmd>Telescope aerial<cr>", desc = "Code Outline" },

      -- list of items copied to clipboard
      { "<leader>fc", "<Cmd>Telescope neoclip<CR>", desc = "Clipboard" },
      -- git commands
      {
        "<leader>glg",
        "<Cmd>echo 'Git commits'<CR> <Cmd>Telescope git_commits<CR>",
        desc = "Commits",
      },
      {
        "<leader>glgf",
        "<Cmd>echo 'Git commits of the current file'<CR> <Cmd>Telescope git_bcommits<CR>",
        desc = "Commits of current file",
      },
      {
        "<leader>gb",
        "<Cmd>echo 'Git branches'<CR> <Cmd>Telescope git_branches<CR>",
        desc = "Branches",
      },
      {
        "<leader>gst",
        "<Cmd>echo 'Git status'<CR> <Cmd>Telescope git_status<CR>",
        desc = "Status",
      },
    },
    config = function(_, _)
      local telescope = require "telescope"
      local icons = require "config.icons"
      local actions = require "telescope.actions"
      local actions_layout = require "telescope.actions.layout"
      local trouble = require "trouble.providers.telescope"
      local path_actions = require "telescope_insert_path"
      local mappings = {
        i = {
          ["<C-j>"] = actions.move_selection_next,
          ["<C-k>"] = actions.move_selection_previous,
          ["<C-n>"] = actions.move_selection_next,
          ["<C-p>"] = actions.move_selection_previous,
          ["<M-j>"] = actions.cycle_history_next,
          ["<M-k>"] = actions.cycle_history_prev,
          ["<M-n>"] = actions.cycle_history_next,
          ["<M-p>"] = actions.cycle_history_prev,
          ["?"] = actions_layout.toggle_preview,
          ["<C-q>"] = actions.send_to_qflist + actions.open_qflist, -- send all to quickfixlist
          ["<M-q>"] = actions.send_selected_to_qflist + actions.open_qflist, -- send selected to quickfixlist
          ["<Esc><Esc>"] = actions.close,
          ["<c-t>"] = trouble.open_with_trouble,
        },
        n = {
          ["<c-t>"] = trouble.open_with_trouble,
          ["[i"] = path_actions.insert_relpath_i_visual,
          -- ["[I"] = path_actions.insert_relpath_I_visual,
          -- ["[a"] = path_actions.insert_relpath_a_visual,
          -- ["[A"] = path_actions.insert_relpath_A_visual,
          -- ["[o"] = path_actions.insert_relpath_o_visual,
          -- ["[O"] = path_actions.insert_relpath_O_visual,
          ["]i"] = path_actions.insert_abspath_i_visual,
          -- ["]I"] = path_actions.insert_abspath_I_visual,
          -- ["]a"] = path_actions.insert_abspath_a_visual,
          -- ["]A"] = path_actions.insert_abspath_A_visual,
          -- ["]o"] = path_actions.insert_abspath_o_visual,
          -- ["]O"] = path_actions.insert_abspath_O_visual,
          -- Additionally, there's insert and normal mode mappings for the same actions:
          -- ["{i"] = path_actions.insert_relpath_i_insert,
          -- ["{I"] = path_actions.insert_relpath_I_insert,
          -- ["{a"] = path_actions.insert_relpath_a_insert,
          -- ["{A"] = path_actions.insert_relpath_A_insert,
          -- ["{o"] = path_actions.insert_relpath_o_insert,
          -- ["{O"] = path_actions.insert_relpath_O_insert,
          -- ["}i"] = path_actions.insert_abspath_i_insert,
          -- ["}I"] = path_actions.insert_abspath_I_insert,
          -- ["}a"] = path_actions.insert_abspath_a_insert,
          -- ["}A"] = path_actions.insert_abspath_A_insert,
          -- ["}o"] = path_actions.insert_abspath_o_insert,
          -- ["}O"] = path_actions.insert_abspath_O_insert,
          -- ["-i"] = path_actions.insert_relpath_i_normal,
          -- ["-I"] = path_actions.insert_relpath_I_normal,
          -- ["-a"] = path_actions.insert_relpath_a_normal,
          -- ["-A"] = path_actions.insert_relpath_A_normal,
          -- ["-o"] = path_actions.insert_relpath_o_normal,
          -- ["-O"] = path_actions.insert_relpath_O_normal,
          -- ["+i"] = path_actions.insert_abspath_i_normal,
          -- ["+I"] = path_actions.insert_abspath_I_normal,
          -- ["+a"] = path_actions.insert_abspath_a_normal,
          -- ["+A"] = path_actions.insert_abspath_A_normal,
          -- ["+o"] = path_actions.insert_abspath_o_normal,
          -- ["+O"] = path_actions.insert_abspath_O_normal,
        },
      }

      local opts = {
        defaults = {
          layout_strategy = "horizontal",
          layout_config = {
            horizontal = {
              preview_cutoff = 110,
              preview_width = { 0.5, min = 70, max = 100 },
              width = 0.999,
              height = 0.999,
            },
            vertical = {
              preview_cutoff = 25,
              preview_height = { 0.6, min = 20, max = 40 },
              width = 0.999,
              height = 0.999,
            },
          },
          file_ignore_patterns = { "^.git/", ".cache/" },
          prompt_prefix = icons.ui.Telescope .. " ",
          selection_caret = icons.ui.Forward .. " ",
          mappings = mappings,
          border = {},
          borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
          color_devicons = true,
        },
        pickers = {
          find_files = {
            hidden = true,
            find_command = { "rg", "--files", "--hidden", "-g", "!.git" },
          },
          live_grep = {
            only_sort_text = true,
          },
          git_commits = {
            layout_strategy = "vertical",
          },
          git_bcommits = {
            layout_strategy = "vertical",
          },
          git_status = {
            layout_strategy = "vertical",
          },
          git_files = {
            hidden = true,
            find_command = { "rg", "--files", "--hidden", "-g", "!.git" },
          },
          buffers = {
            ignore_current_buffer = true,
            sort_mru = true,
          },
        },
        extensions = {
          file_browser = {
            theme = "dropdown",
            previewer = false,
            hijack_netrw = true,
            mappings = mappings,
          },
          project = {
            hidden_files = false,
            theme = "dropdown",
          },
        },
      }
      telescope.setup(opts)
      telescope.load_extension "fzf"
      telescope.load_extension "file_browser"
      telescope.load_extension "project"
      telescope.load_extension "projects"
      telescope.load_extension "aerial"
      telescope.load_extension "dap"
      telescope.load_extension "neoclip"
    end,
  },
  {
    "stevearc/aerial.nvim",
    config = true,
  },
  {
    "ahmedkhalf/project.nvim",
    config = function()
      require("project_nvim").setup {
        detection_methods = { "pattern", "lsp" },
        patterns = { ".git" },
        ignore_lsp = { "null-ls" },
      }
    end,
  },
  {
    "AckslD/nvim-neoclip.lua",
    event = "VeryLazy",
    opts = {
      default_register = "+",
      keys = {
        telescope = {
          i = {
            select = "<CR>",
            paste = "<C-p>",
            paste_behind = "<C-M-p>",
            replay = "<C-q>", -- replay a macro
            delete = "<C-d>", -- delete an entry
          },
          n = {
            select = "<CR>",
            paste = { "p", "<C-p>" },
            paste_behind = { "P", "<C-M-p>" },
            replay = "q",
            delete = "d",
          },
        },
      },
    },
  },
}

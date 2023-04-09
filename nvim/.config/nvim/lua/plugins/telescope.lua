return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
      "nvim-telescope/telescope-file-browser.nvim",
      "nvim-telescope/telescope-project.nvim",
      "ahmedkhalf/project.nvim",
      "cljoly/telescope-repo.nvim",
      "stevearc/aerial.nvim",
      "folke/trouble.nvim",
      "kiyoon/telescope-insert-path.nvim",
      "AckslD/nvim-neoclip.lua",
      "nvim-telescope/telescope-hop.nvim",
      { "nvim-telescope/telescope-live-grep-args.nvim" },
      "molecule-man/telescope-menufacture",
    },
    cmd = "Telescope",
    keys = {
      -- find files within current working directory, respects .gitignore
      -- { "<leader>ff", "<Cmd>Telescope find_files<CR>", desc = "Find files" },
      {
        "<leader>ff",
        "<Cmd> lua require('telescope').extensions.menufacture.find_files()<CR>",
        desc = "Find files",
      },
      {
        "<leader>ffv",
        "<Cmd> lua require('telescope').extensions.menufacture.find_files({layout_strategy='vertical'})<CR>",
        desc = "Find files, vertical layout",
      },
      { "<leader>fi", require("utils").find_ignored_files, desc = "Find files including ignored" },
      {
        "<leader>fiv",
        require("utils").find_ignored_files_vert,
        desc = "Find files including ignored, vertical layout",
      },
      { "<C-p>", "<Cmd>Telescope find_files<CR>", desc = "Find files" },
      { "<leader>fg", require("utils").find_files, desc = "Find Git managed files" },
      -- { "<leader>f/", "<Cmd>Telescope live_grep<CR>", desc = "Live grep in workspace" },
      {
        "<leader>f/",
        "<Cmd> lua require('telescope').extensions.menufacture.live_grep()<CR>",
        { desc = "Live grep in workspace" },
      },
      {
        "<leader>f/v",
        "<Cmd> lua require('telescope').extensions.menufacture.live_grep({layout_strategy='vertical'})<CR>",
        { desc = "Live grep in workspace, vertical layout" },
      },
      {
        "<leader>f/o",
        "<Cmd> lua require('telescope').extensions.menufacture.live_grep({grep_open_files=true})<CR>",
        { desc = "Live grep in workspace" },
      },
      {
        "<leader>f/vo",
        "<Cmd> lua require('telescope').extensions.menufacture.live_grep({layout_strategy='vertical', grep_open_files=true})<CR>",
        { desc = "Live grep in workspace, vertical layout" },
      },
      {
        "<leader>f?",
        "<Cmd> lua require('telescope').extensions.live_grep_args.live_grep_args()<CR>",
        { desc = "Live grep in workspace with custom args" },
      },
      {
        "<leader>f?v",
        "<Cmd> lua require('telescope').extensions.live_grep_args.live_grep_args({layout_strategy='vertical'})<CR>",
        { desc = "Live grep in workspace with custom args, vertical layout" },
      },
      -- { "<leader>f?", require("utils").grep_ignored_files, desc = "Live grep including ignored" },
      {
        "<leader>fw",
        "<Cmd> lua require('telescope').extensions.menufacture.grep_string()<CR>",
        { desc = "Find word under cursor" },
      },
      { "<leader>fb", "<Cmd>Telescope buffers<cr>", desc = "Buffers" },
      { "<leader><CR>", "<Cmd>Telescope buffers<cr>", desc = "Buffers" },

      { "<leader>fh", "<Cmd>Telescope help_tags<cr>", desc = "Help tags" },
      {
        "<leader><leader>c",
        function()
          require("telescope.builtin").colorscheme { enable_preview = true }
        end,
        desc = "Colorscheme",
      },

      -- repeat last telescope command and query
      { "<leader>fr", "<Cmd>Telescope resume<CR>", desc = "Resume" },
      { "<leader>fo", "<Cmd>Telescope oldfiles<cr>", desc = "Recent" },
      { "<leader>fab", "<Cmd>Telescope file_browser<cr>", desc = "File browser" },
      { "<leader>far", "<Cmd>Telescope repo list<cr>", desc = "Search" },
      {
        "<leader>fp",
        function()
          require("telescope").extensions.project.project { display_type = "minimal" }
        end,
        desc = "List",
      },
      {
        "<leader>/",
        function()
          require("telescope.builtin").current_buffer_fuzzy_find()
        end,
        desc = "Buffer",
      },
      {
        "<leader>fd",
        function()
          require("telescope.builtin").diagnostics()
        end,
        desc = "Diagnostics",
      },
      { "<leader>vo", "<cmd>Telescope aerial<cr>", desc = "Code Outline" },

      -- list of items copied to clipboard
      { "<leader>fc", "<Cmd>Telescope neoclip<CR>", desc = "Clipboard" },
      -- git commands
      {
        "<leader>glg",
        "<Cmd>echo 'Git commits'<CR> <Cmd>Telescope git_commits<CR>",
        desc = "Commits",
      },
      {
        "<leader>glf",
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
      local lga_actions = require "telescope-live-grep-args.actions"

      local mappings = {
        i = {
          ["<C-x>"] = require("telescope.actions").delete_buffer,
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
          ["<C-t>"] = trouble.open_with_trouble,
          ["<C-h>"] = function(prompt_bufnr)
            telescope.extensions.hop.hop(prompt_bufnr)
          end, -- hop.hop or hop.hop_toggle_selection
          -- custom hop loop to multi selects and sending selected entries to quickfix list
          ["<C-l>"] = function(prompt_bufnr)
            local opts = {
              callback = actions.toggle_selection,
              loop_callback = actions.send_selected_to_qflist,
            }
            require("telescope").extensions.hop._hop_loop(prompt_bufnr, opts)
          end,
          ["<M-a>"] = lga_actions.quote_prompt(),
          ["<M-g>"] = lga_actions.quote_prompt { postfix = " --iglob " },
          ["<M-i>"] = lga_actions.quote_prompt { postfix = " --no-ignore " },
          ["<C-o>"] = function(prompt_bufnr)
            require("telescope.actions").select_default(prompt_bufnr)
            require("telescope.builtin").resume()
          end,
        },
        n = {
          ["dd"] = require("telescope.actions").delete_buffer,
          ["<C-t>"] = trouble.open_with_trouble,
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
            order_by = "asc",
            search_by = "title",
            sync_with_nvim_tree = true, -- default false
            hidden_files = true, -- default: false
            theme = "dropdown",
          },
          hop = {
          --stylua: ignore
            keys = {
              "a", "s", "d", "f", "g", "h", "j", "k", "l", ";",
              "q", "w", "e", "r", "t", "y", "u", "i", "o", "p",
              "z", "x", "c", "v", "b", "n", "m",
              "A", "S", "D", "F", "G", "H", "J", "K", "L", ":",
              "Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P",
              "Z", "X", "C", "V", "B", "N", "M",
            },
            -- Highlight groups to link to signs and lines; the below configuration refers to demo
            -- sign_hl typically only defines foreground to possibly be combined with line_hl
            sign_hl = { "WarningMsg", "Title" },
            -- optional, typically a table of two highlight groups that are alternated between
            line_hl = { "CursorLine", "Normal" },
            -- options specific to `hop_loop`
            -- true temporarily disables Telescope selection highlighting
            clear_selection_hl = false,
            -- highlight hopped to entry with telescope selection highlight
            -- note: mutually exclusive with `clear_selection_hl`
            trace_entry = true,
            -- jump to entry where hoop loop was started from
            reset_selection = true,
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
      telescope.load_extension "hop"
      telescope.load_extension "live_grep_args"

      vim.cmd [[
        function!   QuickFixOpenAll()
            if empty(getqflist())
                return
            endif
            let s:prev_val = ""
            for d in getqflist()
                let s:curr_val = bufname(d.bufnr)
                if (s:curr_val != s:prev_val)
                    exec "edit " . s:curr_val
                endif
                let s:prev_val = s:curr_val
            endfor
        endfunction
      ]]

      vim.keymap.set(
        "n",
        "<leader>ka",
        ":call QuickFixOpenAll()<CR>",
        { noremap = true, silent = false }
      )
    end,
  },
  {
    "stevearc/aerial.nvim",
    config = true,
  },
  {
    "ahmedkhalf/project.nvim",
    cmd = "ProjectRoot",
    config = function()
      require("project_nvim").setup {
        manual_mode = false,
        silent_chdir = true,
        detection_methods = { "pattern", "lsp" },
        patterns = { ".project", ".git" },
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
  {
    "aaronhallaert/advanced-git-search.nvim",
    event = "VeryLazy",
    config = function()
      require("telescope").load_extension "advanced_git_search"
      vim.api.nvim_create_user_command(
        "DiffCommitLine",
        "lua require('telescope').extensions.advanced_git_search.diff_commit_line()",
        { range = true }
      )

      vim.keymap.set(
        "v",
        "<leader>gcl",
        ":DiffCommitLine<CR>",
        { desc = "current line Git history", noremap = true }
      )
      vim.keymap.set(
        "n",
        "<leader>gcb",
        "<Cmd> lua require('telescope').extensions.advanced_git_search.diff_branch_file()<CR>",
        { desc = "current file diff against other branch", noremap = true }
      )
      vim.keymap.set(
        "n",
        "<leader>gcf",
        "<Cmd> lua require('telescope').extensions.advanced_git_search.diff_commit_file()<CR>",
        { desc = "current file Git history", noremap = true }
      )
    end,
    dependencies = {
      "nvim-telescope/telescope.nvim",
      "tpope/vim-fugitive",
    },
  },
}

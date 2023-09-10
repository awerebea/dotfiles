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
      "nvim-telescope/telescope-live-grep-args.nvim",
      "molecule-man/telescope-menufacture",
      "kdheepak/lazygit.nvim",
    },
    cmd = "Telescope",
    keys = {
      {
        "<leader>ff",
        function()
          require("telescope").extensions.menufacture.find_files {}
        end,
        desc = "Find files (menufacture)",
      },
      {
        "<leader>f/",
        function()
          require("telescope").extensions.menufacture.live_grep {}
        end,
        { desc = "Live grep (menufacture)" },
      },
      {
        "<leader>f//",
        function()
          require("telescope").extensions.menufacture.grep_string {
            shorten_path = true,
            word_match = "-w",
            only_sort_text = true,
            search = "",
          }
        end,
        desc = "Fuzzy Grep",
      },
      {
        "<leader>//",
        function()
          require("telescope.builtin").current_buffer_fuzzy_find {}
        end,
        desc = "Fuzzy grep in current buffer",
      },
      {
        "<leader>fg",
        function()
          local ok = pcall(require("telescope").extensions.menufacture.git_files, {})
          if not ok then
            require("telescope").extensions.menufacture.find_files {}
          end
        end,
        desc = "Find Git managed files",
      },
      {
        "<leader>f?",
        function()
          require("telescope").extensions.live_grep_args.live_grep_args {}
        end,
        { desc = "Live grep (custom args)" },
      },
      {
        "<leader>fw",
        function()
          require("telescope").extensions.menufacture.grep_string {}
        end,
        { desc = "Find word under cursor" },
      },
      {
        "<leader>fb",
        function()
          require("telescope.builtin").buffers {}
        end,
        desc = "Buffers",
      },
      {
        "<leader><CR>",
        function()
          require("telescope.builtin").buffers {}
        end,
        desc = "Buffers",
      },
      {
        "<leader>fh",
        function()
          require("telescope.builtin").help_tags {}
        end,
        desc = "Help tags",
      },
      {
        "<leader><leader>c",
        function()
          require("telescope.builtin").colorscheme { enable_preview = true }
        end,
        desc = "Colorscheme",
      },

      -- repeat last telescope command and query
      {
        "<leader>fr",
        function()
          require("telescope.builtin").resume {}
        end,
        desc = "Resume",
      },
      {
        "<leader>fo",
        function()
          require("telescope.builtin").oldfiles {}
        end,
        desc = "Recent",
      },
      {
        "<leader>fab",
        function()
          require("telescope").extensions.file_browser.file_browser {}
        end,
        desc = "File browser",
      },
      {
        "<leader>faB",
        function()
          require("telescope").extensions.file_browser.file_browser {
            path = "%:p:h",
            select_buffer = true,
          }
        end,
        desc = "File browser (find file)",
      },
      {
        "<leader>far",
        function()
          require("telescope").extensions.repo.list {}
        end,
        desc = "Search",
      },
      {
        "<leader>fp",
        function()
          require("telescope").extensions.projects.projects {}
        end,
        desc = "Projects",
      },
      {
        "<leader>fP",
        function()
          require("telescope").extensions.project.project { display_type = "minimal" }
        end,
        desc = "Project extension",
      },
      {
        "<leader>fd",
        function()
          require("telescope.builtin").diagnostics {}
        end,
        desc = "Diagnostics",
      },
      {
        "<leader>vo",
        function()
          require("telescope").extensions.aerial.aerial {}
        end,
        desc = "Code Outline",
      },

      -- list of items copied to clipboard
      {
        "<leader>fc",
        function()
          require("telescope").extensions.neoclip.default {}
        end,
        desc = "Clipboard",
      },
      -- git commands
      {
        "<leader>glg",
        function()
          require("telescope.builtin").git_commits {}
        end,
        desc = "Commits",
      },
      {
        "<leader>glf",
        function()
          require("telescope.builtin").git_bcommits {}
        end,
        desc = "Commits of current file",
      },
      {
        "<leader>gb",
        function()
          require("telescope.builtin").git_branches {}
        end,
        desc = "Branches",
      },
      {
        "<leader>gst",
        function()
          require("telescope.builtin").git_status {}
        end,
        desc = "Status",
      },
    },
    config = function(_, _)
      -- Open one or more selected entries in the current window
      local select_one_or_multi = function(prompt_bufnr)
        local picker = require("telescope.actions.state").get_current_picker(prompt_bufnr)
        local multi = picker:get_multi_selection()
        if not vim.tbl_isempty(multi) then
          require("telescope.actions").close(prompt_bufnr)
          for _, j in pairs(multi) do
            if j.path ~= nil then
              vim.cmd(string.format("%s %s", "edit", j.path))
            end
          end
        else
          require("telescope.actions").select_default(prompt_bufnr)
        end
      end

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
          ["<CR>"] = select_one_or_multi,
        },
        n = {
          ["dd"] = require("telescope.actions").delete_buffer,
          ["<C-t>"] = trouble.open_with_trouble,
          ["[i"] = path_actions.insert_relpath_i_visual,
          ["]i"] = path_actions.insert_abspath_i_visual,
        },
      }

      local opts = {
        defaults = {
          layout_strategy = "horizontal",
          sorting_strategy = "ascending",
          layout_config = {
            horizontal = {
              prompt_position = "top",
              preview_cutoff = 110,
              preview_width = { 0.5, min = 70, max = 100 },
              width = 0.999,
              height = 0.999,
            },
            vertical = {
              prompt_position = "top",
              preview_cutoff = 25,
              preview_height = { 0.6, min = 20, max = 40 },
              width = 0.999,
              height = 0.999,
            },
          },
          file_ignore_patterns = { "^.git/", ".cache/", ".venv/" },
          prompt_prefix = icons.ui.Telescope .. " ",
          selection_caret = icons.ui.Forward .. " ",
          mappings = mappings,
          border = true,
          borderchars = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
          color_devicons = true,
        },
        pickers = {
          find_files = {
            hidden = true,
            find_command = { "rg", "--files", "--hidden", "-g", "!.git" },
          },
          live_grep = {
            only_sort_text = true,
            mappings = {
              i = { ["<c-g>"] = actions.to_fuzzy_refine },
            },
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
      telescope.load_extension "aerial"
      telescope.load_extension "fzf"
      telescope.load_extension "file_browser"
      telescope.load_extension "project"
      telescope.load_extension "projects"
      telescope.load_extension "aerial"
      telescope.load_extension "dap"
      telescope.load_extension "neoclip"
      telescope.load_extension "hop"
      telescope.load_extension "live_grep_args"
      telescope.load_extension "lazygit"

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
        -- Manual mode doesn't automatically change your root directory, so you have
        -- the option to manually do so using `:ProjectRoot` command.
        manual_mode = false,

        -- Methods of detecting the root directory. **"lsp"** uses the native neovim
        -- lsp, while **"pattern"** uses vim-rooter like glob pattern matching. Here
        -- order matters: if one is not detected, the other is used as fallback. You
        -- can also delete or rearangne the detection methods.
        detection_methods = { "pattern", "lsp" },

        -- All the patterns used to detect root dir, when **"pattern"** is in
        -- detection_methods  -- All the patterns used to detect root dir, when **"pattern"** is in
        -- detection_methods
        patterns = { ".project", ".git" },

        -- Table of lsp clients to ignore by name
        -- eg: { "efm", ... }
        ignore_lsp = { "null-ls" },

        -- Show hidden files in telescope
        show_hidden = false,

        -- When set to false, you will get a message when project.nvim changes your
        -- directory.
        silent_chdir = true,

        -- What scope to change the directory, valid options are
        -- * global (default)
        -- * tab
        -- * win
        scope_chdir = "win",
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

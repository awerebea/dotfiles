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
      "nvim-telescope/telescope-z.nvim",
      "debugloop/telescope-undo.nvim",
      "ANGkeith/telescope-terraform-doc.nvim",
      "ThePrimeagen/harpoon",
      "axkirillov/hbac.nvim",
    },
    cmd = "Telescope",
    keys = {
      -- Following 5 keymaps are defined in nescopes.lua module
      -- {
      --   "<leader>ff",
      --   function()
      --     require("plugins.telescope.telescopePickers").prettyGrepPicker { picker = "find_files" }
      --   end,
      --   desc = "Find files (menufacture)",
      -- },
      -- {
      --   "<leader>f/",
      --   function()
      --     require("plugins.telescope.telescopePickers").prettyGrepPicker { picker = "live_grep" }
      --   end,
      --   { desc = "Live grep (menufacture)" },
      -- },
      -- {
      --   "<leader>f?",
      --   function()
      --     require("telescope").extensions.live_grep_args.live_grep_args()
      --   end,
      --   { desc = "Live grep (custom args)" },
      -- },
      -- {
      --   "<leader>fa",
      --   function()
      --     require("telescope").extensions.menufacture.grep_string {
      --       shorten_path = true,
      --       word_match = "-w",
      --       only_sort_text = true,
      --       search = "",
      --     }
      --   end,
      --   desc = "Fuzzy Grep (menufacture)",
      -- },
      -- {
      --   "<leader>fw",
      --   function()
      --     require("plugins.telescope.telescopePickers").prettyGrepPicker { picker = "grep_string" }
      --   end,
      --   desc = "Find word under cursor",
      -- },
      {
        "<leader>//",
        function()
          require("telescope.builtin").current_buffer_fuzzy_find()
        end,
        desc = "Fuzzy grep in current buffer",
      },
      {
        "<leader>fg",
        function()
          require("plugins.telescope.telescopePickers").prettyFilesPicker {
            picker = "git_files",
          }
        end,
        desc = "Find Git managed files",
      },
      {
        "<leader>fb",
        function()
          require("plugins.telescope.telescopePickers").prettyBuffersPicker()
        end,
        desc = "Buffers",
      },
      {
        "<leader><CR>",
        function()
          require("plugins.telescope.telescopePickers").prettyBuffersPicker()
        end,
        desc = "Buffers",
      },
      {
        "<leader><leader><CR>",
        function()
          require("telescope").extensions.hbac.buffers {
            path_display = { "truncate" },
          }
        end,
        desc = "Hbac Buffers",
      },
      {
        "<leader>fh",
        function()
          require("telescope.builtin").help_tags()
        end,
        desc = "Help tags",
      },
      {
        "<leader>fs",
        function()
          require("plugins.telescope.telescopePickers").prettyDocumentSymbols()
        end,
        desc = "Document symbols",
      },
      {
        "<leader>fS",
        function()
          require("plugins.telescope.telescopePickers").prettyWorkspaceSymbols()
        end,
        desc = "Workspace symbols",
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
          require("telescope.builtin").resume()
        end,
        desc = "Resume",
      },
      {
        "<leader>fo",
        function()
          require("plugins.telescope.telescopePickers").prettyFilesPicker {
            picker = "oldfiles",
          }
        end,
        desc = "Recent",
      },
      {
        "<leader>fab",
        function()
          require("telescope").extensions.file_browser.file_browser()
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
          require("telescope").extensions.repo.list()
        end,
        desc = "Search",
      },
      {
        "<leader>fp",
        function()
          require("telescope").extensions.projects.projects()
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
          require("telescope.builtin").diagnostics()
        end,
        desc = "Diagnostics",
      },
      {
        "<leader>vo",
        function()
          require("telescope").extensions.aerial.aerial()
        end,
        desc = "Code Outline",
      },

      -- list of items copied to clipboard
      {
        "<leader>fc",
        function()
          require("telescope").extensions.neoclip.default()
        end,
        desc = "Clipboard",
      },
      -- list notifications
      {
        "<leader>fn",
        function()
          require("telescope").extensions.notify.notify()
        end,
        desc = "Notifications",
      },
      -- git commands
      -- Defined later in this file using custom previewer with delta
      {
        "<leader>glg",
        function()
          -- require("telescope.builtin").git_commits()
          Delta_git_commits()
        end,
        desc = "Commits",
      },
      {
        "<leader>glf",
        function()
          -- require("telescope.builtin").git_bcommits()
          Delta_git_bcommits()
        end,
        desc = "Commits of current file",
      },
      {
        "<leader>gb",
        function()
          require("telescope.builtin").git_branches()
        end,
        desc = "Branches",
      },
      {
        "<leader>gst",
        function()
          -- require("telescope.builtin").git_status()
          Delta_git_status()
        end,
        desc = "Status",
      },
      {
        "<leader>gss",
        function()
          require("utils").git_diff_picker()
        end,
        desc = "git diff --name-only",
      },
      {
        "<leader>gz",
        function()
          require("telescope").extensions.z.list {
            cmd = { "bash", "-c", "fasd", "-d" },
          }
        end,
        desc = "fasd",
      },
      {
        "<leader>tu",
        function()
          require("telescope").extensions.undo.undo()
        end,
        desc = "Undo tree",
      },
      {
        "<leader>fm",
        "<Cmd>Telescope macrothis<CR>",
        desc = "Macrothis",
      },
      {
        "<leader>m",
        function()
          require("telescope").extensions.harpoon.marks()
        end,
        desc = "Harpoon marks",
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

      -- Get the full path to the directory containing the selected item
      get_item_dirpath = function(prompt_bufnr)
        file_path = get_item_path(prompt_bufnr)
        if not file_path then
          return
        end
        return vim.fs.dirname(file_path)
      end

      -- Get the full path to the selected item
      get_item_path = function(prompt_bufnr)
        -- Get the full path
        local file_path = nil
        local content = require("telescope.actions.state").get_selected_entry()
        if content == nil then
          return
        end
        if content.filename then
          if content.cwd then
            file_path = content.cwd .. "/" .. content.filename
          else
            file_path = vim.fn.systemlist("pwd")[1] .. "/" .. content.filename
          end
        elseif content.path then
          file_path = content.path
        elseif content.value then
          file_path = content.value
        end
        return file_path
      end

      -- Toggleterm
      open_terminal = function(prompt_bufnr)
        local file_dir = get_item_dirpath(prompt_bufnr)
        -- Close the Telescope window
        require("telescope.actions").close(prompt_bufnr)
        require("utils").open_term(nil, { direction = "float", dir = file_dir })
      end

      -- Copy the path to the directory containing the selected item to the clipboard
      copy_dirpath_of_selected_item = function(prompt_bufnr)
        local file_dir = get_item_dirpath(prompt_bufnr)
        vim.fn.setreg("*", file_dir)
        require("telescope.actions").close(prompt_bufnr)
      end

      -- Copy the path to the selected item to the clipboard
      copy_path_of_selected_item = function(prompt_bufnr)
        local file_path = get_item_path(prompt_bufnr)
        vim.fn.setreg("*", file_path)
        require("telescope.actions").close(prompt_bufnr)
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
          ["<C-x>"] = actions.delete_buffer,
          ["<C-j>"] = actions.move_selection_next,
          ["<C-k>"] = actions.move_selection_previous,
          ["<C-n>"] = actions.move_selection_next,
          -- ["<C-p>"] = actions.move_selection_previous,
          ["<M-j>"] = actions.cycle_history_next,
          ["<M-k>"] = actions.cycle_history_prev,
          ["<M-n>"] = actions.cycle_history_next,
          ["<M-p>"] = actions.cycle_history_prev,
          ["<C-p>"] = actions_layout.toggle_preview,
          ["<C-q>"] = actions.send_to_qflist + actions.open_qflist, -- send all to quickfixlist
          ["<M-q>"] = actions.send_selected_to_qflist + actions.open_qflist, -- send selected to quickfixlist
          ["<C-c"] = actions.close,
          ["<Esc><Esc>"] = actions.close,
          ["<C-t>"] = trouble.open_with_trouble,
          ["<C-h>"] = function(prompt_bufnr)
            telescope.extensions.hop.hop(prompt_bufnr)
          end, -- hop.hop or hop.hop_toggle_selection
          ["<C-M-h>"] = function(prompt_bufnr)
            telescope.extensions.hop._hop(prompt_bufnr)
          end,
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
          ["<C-g>"] = actions.to_fuzzy_refine,
          ["<C-z>"] = open_terminal,
          ["<C-M-d>"] = copy_dirpath_of_selected_item,
          ["<C-M-f>"] = copy_path_of_selected_item,
        },
        n = {
          ["<C-p>"] = actions_layout.toggle_preview,
          ["dd"] = actions.delete_buffer,
          ["<C-t>"] = trouble.open_with_trouble,
          ["[i"] = path_actions.insert_relpath_i_visual,
          ["]i"] = path_actions.insert_abspath_i_visual,
          ["z"] = open_terminal,
          ["<C-M-d>"] = copy_dirpath_of_selected_item,
          ["<C-M-f>"] = copy_path_of_selected_item,
        },
      }

      local opts = {
        defaults = {
          layout_strategy = "horizontal",
          sorting_strategy = "ascending",
          path_display = { "truncate" },
          layout_config = {
            horizontal = {
              prompt_position = "top",
              anchor = "S",
              preview_cutoff = 110,
              preview_width = { 0.5, min = 70, max = 100 },
              width = 0.999,
              height = 0.95,
            },
            vertical = {
              prompt_position = "top",
              anchor = "S",
              preview_cutoff = 25,
              preview_height = { 0.6, min = 20, max = 40 },
              width = 0.999,
              height = 0.95,
            },
          },
          file_ignore_patterns = { "^.git/", ".cache/", ".venv/" },
          prompt_prefix = icons.ui.Telescope .. " ",
          selection_caret = icons.ui.Forward .. " ",
          mappings = mappings,
          border = true,
          borderchars = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
          color_devicons = true,
          vimgrep_arguments = {
            "rg",
            "--color=never",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
            "--smart-case",
            "--hidden",
          },
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
            theme = "ivy",
            previewer = true,
            hijack_netrw = false,
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
          undo = {
            layout_strategy = "vertical",
            layout_config = {
              vertical = {
                mirror = true,
              },
            },
            -- use_delta = true,
            use_custom_command = { "bash", "-c", "echo '$DIFF' | delta" },
            side_by_side = true,
            diff_context_lines = vim.o.scrolloff,
            entry_format = "state #$ID, $STAT, $TIME",
            time_format = "",
            mappings = {
              i = {
                ["<C-a>"] = require("telescope-undo.actions").yank_additions,
                ["<C-d>"] = require("telescope-undo.actions").yank_deletions,
                ["<cr>"] = require("telescope-undo.actions").restore,
              },
              n = {
                ["<C-a>"] = require("telescope-undo.actions").yank_additions,
                ["<C-d>"] = require("telescope-undo.actions").yank_deletions,
                ["<cr>"] = require("telescope-undo.actions").restore,
              },
            },
          },
          macrothis = {
            mappings = {},
            -- <CR>   Load selected entry into register,
            -- <C-c>  Copy macro as printable
            -- <C-d>  Delete selected entry or delete all marked entries
            -- <C-e>  Edit content of macro
            -- <C-n>  Rename selected entry
            -- <C-q>  Run macro on files in quickfix list
            -- <C-r>  Run macro
            -- <C-s>  Save a macro/register
            -- <C-x>  Edit register (<C-c> can be used to copy the register as printable)
          },
          terraform_doc = {
            url_open_command = "xdg-open",
            latest_provider_symbol = "  ",
            wincmd = "botright vnew",
            wrap = "nowrap",
          },
        },
      }

      -- {{{ flash.nvim integration
      local function flash(prompt_bufnr)
        require("flash").jump {
          pattern = "^",
          label = { after = { 0, 0 } },
          search = {
            mode = "search",
            exclude = {
              function(win)
                return vim.bo[vim.api.nvim_win_get_buf(win)].filetype ~= "TelescopeResults"
              end,
            },
          },
          action = function(match)
            local picker = require("telescope.actions.state").get_current_picker(prompt_bufnr)
            picker:set_selection(match.pos[1] - 1)
          end,
        }
      end
      opts.defaults = vim.tbl_deep_extend("force", opts.defaults or {}, {
        mappings = {
          n = { s = flash },
          i = { ["<c-s>"] = flash },
        },
      })
      -- }}} flash.nvim integration

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
      telescope.load_extension "undo"
      telescope.load_extension "menufacture"
      telescope.load_extension "macrothis"
      telescope.load_extension "terraform_doc"
      telescope.load_extension "harpoon"
      telescope.load_extension "hbac"

      -- this is a hack to add menufacture items to all the builtin pickers
      local telescope_builtin = require "telescope.builtin"
      local menufacture = require("telescope").extensions.menufacture
      -- this menu items will be present in all the pickers
      local global_menu_items = {
        ["change cwd to the current file dir"] = function(opts, callback)
          opts.search_dirs = {}
          opts.cwd = vim.fn.expand "%:p:h"
          callback(opts)
        end,
        ["change cwd to parent"] = function(opts, callback)
          local cwd = opts.cwd and vim.fn.expand(opts.cwd) or vim.loop.cwd()
          opts.cwd = vim.fn.fnamemodify(cwd, ":p:h:h")
          callback(opts)
        end,
        ["find with fd in $HOME"] = function(opts, callback)
          opts.search_dirs = {}
          opts.cwd = vim.fn.expand "$HOME"
          opts.find_command = {
            "fd",
            "--type",
            "f",
            "--hidden",
            "--follow",
            "--ignore-file",
            vim.fn.expand "$HOME/.config/fd/vim-ignore",
          }
          callback(opts)
        end,
        ["layout strategy vertical"] = function(opts, callback)
          opts.layout_strategy = "vertical"
          callback(opts)
        end,
        ["--pcre2"] = menufacture.toggle_flag("additional_args", "--pcre2"),
      }

      for key, picker in pairs(telescope_builtin) do
        local menu_items = global_menu_items
        if menufacture[key .. "_menu"] then
          -- this additional menu items are copied from the menufacture extension (if present)
          menu_items = vim.tbl_extend("force", global_menu_items, menufacture[key .. "_menu"])
        end
        -- we overwrite the builtin pickers. This makes every builtin picker have a menu
        telescope_builtin[key] = menufacture.add_menu_with_default_mapping(picker, menu_items)
      end

      -- Open all files in the quickfix list
      vim.cmd [[
        function! QuickFixOpenAll()
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

      local telescope_previewers = require "telescope.previewers"
      local telescope_builtin = require "telescope.builtin"

      local delta_commits = telescope_previewers.new_termopen_previewer {
        get_command = function(entry)
          return {
            "git",
            "-c",
            "core.pager=delta",
            "-c",
            "delta.side-by-side=false",
            "diff",
            entry.value .. "^!",
          }
        end,
      }

      local delta_bcommits = telescope_previewers.new_termopen_previewer {
        get_command = function(entry)
          return {
            "git",
            "-c",
            "core.pager=delta",
            "-c",
            "delta.side-by-side=false",
            "diff",
            entry.value .. "^!",
            "--",
            entry.current_file,
          }
        end,
      }

      local viewer
      if os.execute "bat --version" == 0 then
        viewer = { "bat" }
      else
        viewer = { "less", "-NR", "-r" }
      end

      local delta_status = telescope_previewers.new_termopen_previewer {
        get_command = function(entry)
          local git_path = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
          if git_path ~= nil then
            if entry.status and (entry.status == "??" or entry.status == "A ") then
              return { unpack(viewer), git_path .. "/" .. entry.value }
            else
              return {
                "git",
                "-c",
                "core.pager=delta",
                "-c",
                "delta.side-by-side=false",
                "diff",
                "--",
                git_path .. "/" .. entry.value,
              }
            end
          end
        end,
      }

      local is_in_git_repo = function()
        if vim.fn.systemlist("git rev-parse --is-inside-work-tree")[1]:lower() == "true" then
          return true
        else
          print "Not a git repo"
          return false
        end
      end

      Delta_git_commits = function(opts)
        if not is_in_git_repo() then
          return
        end
        opts = opts or {}
        opts.previewer = {
          delta_commits,
          telescope_previewers.git_commit_message.new(opts),
          telescope_previewers.git_commit_diff_as_was.new(opts),
        }
        telescope_builtin.git_commits(opts)
      end

      Delta_git_bcommits = function(opts)
        if not is_in_git_repo() then
          return
        end
        opts = opts or {}
        opts.previewer = {
          delta_bcommits,
          telescope_previewers.git_commit_message.new(opts),
          telescope_previewers.git_commit_diff_as_was.new(opts),
        }
        telescope_builtin.git_bcommits(opts)
      end

      Delta_git_status = function(opts)
        if not is_in_git_repo() then
          return
        end
        opts = opts or {}
        opts.previewer = { delta_status }
        telescope_builtin.git_status(opts)
      end
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
        show_hidden = true,

        -- When set to false, you will get a message when project.nvim changes your
        -- directory.
        silent_chdir = true,

        -- What scope to change the directory, valid options are
        -- * global (default)
        -- * tab
        -- * win
        scope_chdir = "global",

        -- Path where project.nvim will store the project history for use in
        -- telescope
        datapath = vim.fn.stdpath "data",
      }
    end,
  },
  {
    "AckslD/nvim-neoclip.lua",
    dependencies = {
      {
        "kkharji/sqlite.lua",
        module = "sqlite",
        config = function()
          if
            string.sub(string.lower(vim.loop.os_uname().sysname), 1, string.len "windows")
            == "windows"
          then
            vim.g.sqlite_clib_path = "C:/Program Files/sqlite/sqlite3.dll"
          end
        end,
      },
    },
    event = "VeryLazy",
    opts = {
      enable_persistent_history = true,
      continuous_sync = true,
      db_path = vim.fn.stdpath "data" .. "/databases/neoclip.sqlite3",
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
    config = true,
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
  {
    "ThePrimeagen/harpoon",
    -- From the quickmenu, open a file in:
    -- Vertical split with <ctrl-v>
    -- Horizontal split with <ctrl-x>
    -- New tab with <ctrl-t>

    -- Valid keymaps in Telescope are:
    -- <ctrl-d> delete the current mark
    -- <ctrl-p> move mark up one position
    -- <ctrl-n> move mark down one position

    -- stylua: ignore
    keys = {
      { "<leader><leader>m",
        function() require("harpoon.mark").add_file() end,
        desc = "Add Harpoon mark",
      },
      {
        "<leader>hr",
        function() require("harpoon.mark").rm_file() end,
        desc = "Remove Harpoon mark",
      },
      {
        "]h",
        function() require("harpoon.ui").nav_next() end,
        desc = "Next Harpoon mark",
      },
      {
        "[h",
        function() require("harpoon.ui").nav_prev() end,
        desc = "Previous Harpoon mark",
      },
      {
        "<leader>hm",
        function()
          require("harpoon").setup {
            menu = {
              width = math.min(
                math.max(math.min(vim.api.nvim_win_get_width(0) - 60, 100), 75),
                vim.api.nvim_win_get_width(0)
              ),
            },
          }
          require("harpoon.ui").toggle_quick_menu()
        end,
        desc = "Harpoon marks",
      },
    },
    config = true,
  },
}

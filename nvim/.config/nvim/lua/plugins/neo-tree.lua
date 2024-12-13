return {
  "nvim-neo-tree/neo-tree.nvim",
  enabled = false,
  cmd = { "Neotree" },
  keys = {
    { "<F2>", desc = "Toggle neo-tree" },
    { "<leader><F2>", desc = "Toggle neo-tree at current file or working directory" },
    { "<leader><leader><F2>", desc = "Toggle neo-tree with custom Git base" },
  },
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
    "MunifTanjim/nui.nvim",
    -- "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
  },
  config = function()
    local win_width = 40
    require("neo-tree").setup {
      close_if_last_window = false, -- Close Neo-tree if it is the last window left in the tab
      use_default_mappings = false,
      event_handlers = {
        {
          event = "vim_buffer_enter",
          handler = function()
            if vim.bo.filetype == "neo-tree" then
              vim.cmd "setlocal relativenumber"
            end
          end,
        },
        {
          event = "neo_tree_popup_input_ready",
          ---@diagnostic disable-next-line
          ---@param input NuiInput
          ---@diagnostic disable-next-line
          handler = function(input)
            -- enter input popup with normal mode by default.
            vim.cmd "stopinsert"
          end,
        },
      },
      source_selector = {
        winbar = true,
        statusline = false,
      },
      popup_border_style = "rounded",
      enable_git_status = true,
      enable_diagnostics = true,
      open_files_do_not_replace_types = { "terminal", "trouble", "qf" }, -- when opening files, do not use windows containing these filetypes or buftypes
      sort_case_insensitive = false, -- used when sorting files and directories in the tree
      sort_function = nil, -- use a custom function for sorting files and directories in the tree
      -- sort_function = function (a,b)
      --       if a.type == b.type then
      --           return a.path > b.path
      --       else
      --           return a.type > b.type
      --       end
      --   end , -- this sorts files and directories descendantly
      default_component_configs = {
        container = {
          enable_character_fade = true,
        },
        indent = {
          indent_size = 2,
          padding = 1, -- extra padding on left hand side
          -- indent guides
          with_markers = true,
          indent_marker = "│",
          last_indent_marker = "└",
          highlight = "NeoTreeIndentMarker",
          -- expander config, needed for nesting files
          with_expanders = nil, -- if nil and file nesting is enabled, will enable expanders
          expander_collapsed = "",
          expander_expanded = "",
          expander_highlight = "NeoTreeExpander",
        },
        icon = {
          folder_closed = "",
          folder_open = "",
          folder_empty = "󰜌",
          -- The next two settings are only a fallback, if you use nvim-web-devicons and configure default icons there
          -- then these will never be used.
          default = "*",
          highlight = "NeoTreeFileIcon",
        },
        modified = {
          symbol = "[+]",
          highlight = "NeoTreeModified",
        },
        name = {
          trailing_slash = false,
          use_git_status_colors = true,
          highlight = "NeoTreeFileName",
        },
        git_status = {
          symbols = {
            -- Change type
            added = "", -- or "✚", but this is redundant info if you use git_status_colors on the name
            modified = "", -- or "", but this is redundant info if you use git_status_colors on the name
            deleted = "✖", -- this can only be used in the git_status source
            renamed = "󰁕", -- this can only be used in the git_status source
            -- Status type
            untracked = "",
            ignored = "",
            unstaged = "󰄱",
            staged = "",
            conflict = "",
          },
        },
        -- If you don't want to use these columns, you can set `enabled = false` for each of them individually
        file_size = {
          enabled = true,
          required_width = 64, -- min width of window required to show this column
        },
        type = {
          enabled = true,
          required_width = 122, -- min width of window required to show this column
        },
        last_modified = {
          enabled = true,
          required_width = 88, -- min width of window required to show this column
        },
        created = {
          enabled = true,
          required_width = 110, -- min width of window required to show this column
        },
        symlink_target = {
          enabled = false,
        },
      },
      -- A list of functions, each representing a global custom command
      -- that will be available in all sources (if not overridden in `opts[source_name].commands`)
      -- see `:h neo-tree-custom-commands-global`
      commands = {
        copy_selector = function(state)
          local node = state.tree:get_node()
          local filepath = node:get_id()
          local dirpath = vim.fs.dirname(filepath)
          local filename = node.name
          local modify = vim.fn.fnamemodify

          local results = {
            filepath,
            modify(filepath, ":."),
            modify(filepath, ":~"),
            dirpath,
            modify(dirpath, ":."),
            modify(dirpath, ":~"),
            filename,
            modify(filename, ":r"),
            modify(filename, ":e"),
          }

          local messages = {
            "Choose to copy to clipboard:",
            "1. File path absolute         : " .. results[1],
            "2. File path relative to CWD  : " .. results[2],
            "3. File path relative to HOME : " .. results[3],
            "4. Dir path absolute          : " .. results[4],
            "5. Dir path relative to CWD   : " .. results[5],
            "6. Dir path relative to HOME  : " .. results[6],
            "7. Filename                   : " .. results[7],
            "8. File basename              : " .. results[8],
            "9. Extension of the file      : " .. results[9],
          }

          vim.api.nvim_echo({ { table.concat(messages, "\n"), "Normal" } }, true, {})
          local choice = vim.fn.getchar() - 48

          if choice >= 1 and choice <= 9 then
            local result = results[choice]
            vim.notify(("Copied: `%s`"):format(result))
            vim.fn.setreg("+", result)
          elseif choice then
            vim.notify("Invalid choice: " .. string.char(choice + 48))
          end
        end,
        toggle_width = function()
          local max_width = math.floor((win_width + 1) * 2.25)
          local cur_width = vim.fn.winwidth(0)
          local new_width = win_width + 1
          if cur_width >= win_width and cur_width < math.floor(win_width * 1.5) then
            new_width = math.floor(win_width * 1.5)
          elseif cur_width >= math.floor(win_width * 1.5) and cur_width < max_width then
            new_width = max_width
          end
          vim.cmd(new_width .. " wincmd |")
        end,
      },
      window = {
        position = "right",
        width = win_width,
        mapping_options = {
          noremap = true,
          nowait = true,
        },
        mappings = {
          ["<space>"] = {
            "toggle_node",
            nowait = false, -- disable `nowait` if you have existing combos starting with this char that you want to use
          },
          ["<2-LeftMouse>"] = "open",
          ["<cr>"] = "open",
          -- ["<cr>"] = "open_drop",
          ["l"] = "open",
          ["<esc>"] = "cancel", -- close preview or floating neo-tree window
          ["P"] = { "toggle_preview", config = { use_float = true, use_image_nvim = true } },
          -- Read `# Preview Mode` for more information
          ["F"] = "focus_preview",
          -- ["S"] = "open_split",
          -- ["s"] = "open_vsplit",
          ["S"] = "split_with_window_picker",
          ["s"] = "vsplit_with_window_picker",
          ["t"] = "open_tabnew",
          -- ["t"] = "open_tab_drop",
          ["w"] = "open_with_window_picker",
          --["P"] = "toggle_preview", -- enter preview mode, which shows the current node without focusing
          ["C"] = "close_node",
          ["h"] = "close_node",
          -- ['C'] = 'close_all_subnodes',
          ["z"] = "close_all_nodes",
          ["Z"] = "expand_all_nodes",
          ["a"] = {
            "add",
            -- this command supports BASH style brace expansion ("x{a,b,c}" -> xa,xb,xc). see `:h neo-tree-file-actions` for details
            -- some commands may take optional config options, see `:h neo-tree-mappings` for details
            config = {
              show_path = "none", -- "none", "relative", "absolute"
            },
          },
          ["A"] = "add_directory", -- also accepts the optional config.show_path option like "add". this also supports BASH style brace expansion.
          ["d"] = "delete",
          ["r"] = "rename",
          ["y"] = "copy_to_clipboard",
          ["x"] = "cut_to_clipboard",
          ["p"] = "paste_from_clipboard",
          -- ["c"] = "copy", -- takes text input for destination, also accepts the optional config.show_path option like "add":
          ["c"] = {
            "copy",
            config = {
              show_path = "relative", -- "none", "relative", "absolute"
            },
          },
          -- ["m"] = "move", -- takes text input for destination, also accepts the optional config.show_path option like "add".
          ["m"] = {
            "move",
            config = {
              show_path = "relative", -- "none", "relative", "absolute"
            },
          },
          ["q"] = "close_window",
          ["R"] = "refresh",
          ["?"] = "show_help",
          ["<"] = "prev_source",
          [">"] = "next_source",
          ["i"] = "show_file_details",
          ["W"] = "toggle_width",
          ["Y"] = "copy_selector",
        },
      },
      nesting_rules = {},
      filesystem = {
        filtered_items = {
          visible = false, -- when true, they will just be displayed differently than normal items
          hide_dotfiles = true,
          hide_gitignored = true,
          hide_hidden = true, -- only works on Windows for hidden files/directories
          hide_by_name = {
            --"node_modules"
          },
          hide_by_pattern = { -- uses glob style patterns
            --"*.meta",
            --"*/src/*/tsconfig.json",
          },
          always_show = { -- remains visible even if other settings would normally hide it
            --".gitignored",
          },
          never_show = { -- remains hidden even if visible is toggled to true, this overrides always_show
            --".DS_Store",
            --"thumbs.db"
          },
          never_show_by_pattern = { -- uses glob style patterns
            --".null-ls_*",
          },
        },
        follow_current_file = {
          enabled = false, -- This will find and focus the file in the active buffer every time
          --               -- the current file is changed while the tree is open.
          leave_dirs_open = false, -- `false` closes auto expanded dirs, such as with `:Neotree reveal`
        },
        group_empty_dirs = false, -- when true, empty folders will be grouped together
        hijack_netrw_behavior = "open_default", -- netrw disabled, opening a directory opens neo-tree
        -- in whatever position is specified in window.position
        -- "open_current",  -- netrw disabled, opening a directory opens within the
        -- window like netrw would, regardless of window.position
        -- "disabled",    -- netrw left alone, neo-tree does not handle opening dirs
        use_libuv_file_watcher = true, -- This will use the OS level file watchers to detect changes
        -- instead of relying on nvim autocmd events.
        window = {
          mappings = {
            ["<bs>"] = "navigate_up",
            ["u"] = "navigate_up",
            ["."] = "set_root",
            ["H"] = "toggle_hidden",
            ["/"] = "fuzzy_finder",
            ["D"] = "fuzzy_finder_directory",
            ["#"] = "fuzzy_sorter", -- fuzzy sorting using the fzy algorithm
            -- ["D"] = "fuzzy_sorter_directory",
            ["f"] = "filter_on_submit",
            ["<c-x>"] = "clear_filter",
            ["[g"] = "prev_git_modified",
            ["]g"] = "next_git_modified",
            ["o"] = {
              "show_help",
              nowait = false,
              config = { title = "Order by", prefix_key = "o" },
            },
            ["oc"] = { "order_by_created", nowait = false },
            ["od"] = { "order_by_diagnostics", nowait = false },
            ["og"] = { "order_by_git_status", nowait = false },
            ["om"] = { "order_by_modified", nowait = false },
            ["on"] = { "order_by_name", nowait = false },
            ["os"] = { "order_by_size", nowait = false },
            ["ot"] = { "order_by_type", nowait = false },
          },
          fuzzy_finder_mappings = { -- define keymaps for filter popup window in fuzzy_finder_mode
            ["<down>"] = "move_cursor_down",
            ["<C-n>"] = "move_cursor_down",
            ["<up>"] = "move_cursor_up",
            ["<C-p>"] = "move_cursor_up",
          },
        },

        commands = {}, -- Add a custom command or override a global one using the same function name
      },
      buffers = {
        follow_current_file = {
          enabled = true, -- This will find and focus the file in the active buffer every time
          --              -- the current file is changed while the tree is open.
          leave_dirs_open = false, -- `false` closes auto expanded dirs, such as with `:Neotree reveal`
        },
        group_empty_dirs = true, -- when true, empty folders will be grouped together
        show_unloaded = true,
        window = {
          mappings = {
            ["bd"] = "buffer_delete",
            ["<bs>"] = "navigate_up",
            ["."] = "set_root",
            ["o"] = {
              "show_help",
              nowait = false,
              config = { title = "Order by", prefix_key = "o" },
            },
            ["oc"] = { "order_by_created", nowait = false },
            ["od"] = { "order_by_diagnostics", nowait = false },
            ["om"] = { "order_by_modified", nowait = false },
            ["on"] = { "order_by_name", nowait = false },
            ["os"] = { "order_by_size", nowait = false },
            ["ot"] = { "order_by_type", nowait = false },
          },
        },
      },
      git_status = {
        window = {
          position = "float",
          mappings = {
            ["A"] = "git_add_all",
            ["gu"] = "git_unstage_file",
            ["ga"] = "git_add_file",
            ["gr"] = "git_revert_file",
            ["gc"] = "git_commit",
            ["gp"] = "git_push",
            ["gg"] = "git_commit_and_push",
            ["o"] = {
              "show_help",
              nowait = false,
              config = { title = "Order by", prefix_key = "o" },
            },
            ["oc"] = { "order_by_created", nowait = false },
            ["od"] = { "order_by_diagnostics", nowait = false },
            ["om"] = { "order_by_modified", nowait = false },
            ["on"] = { "order_by_name", nowait = false },
            ["os"] = { "order_by_size", nowait = false },
            ["ot"] = { "order_by_type", nowait = false },
          },
        },
      },
    }

    local function get_reveal_path()
      local reveal_path = nil
      reveal_path = vim.fn.expand "%:p"
      if reveal_path == "" then
        reveal_path = vim.fn.getcwd()
      else
        local f = io.open(type(reveal_path) == "string" and reveal_path or reveal_path[0], "r")
        if f then
          f.close(f)
        else
          reveal_path = vim.fn.getcwd()
        end
      end
      return reveal_path
    end

    local function conditional_neotree_exec(neotree_opts)
      if vim.bo.filetype == "neo-tree" then
        require("neo-tree.command").execute { action = "close" }
      else
        require("neo-tree.command").execute(neotree_opts)
      end
    end

    vim.keymap.set("n", "<F2>", function()
      conditional_neotree_exec {
        action = "focus",
        source = "filesystem",
        position = "right",
        reveal_force_cwd = false,
      }
    end, { desc = "Toggle neo-tree" })

    vim.keymap.set("n", "<leader><F2>", function()
      conditional_neotree_exec {
        action = "focus",
        source = "filesystem",
        position = "right",
        reveal_file = get_reveal_path(), -- path to file or folder to reveal
        reveal_force_cwd = true,
      }
    end, { desc = "Toggle neo-tree at current file or working directory" })

    vim.keymap.set("n", "<leader><leader><F2>", function()
      local git_base = ""
      if vim.bo.filetype ~= "neo-tree" then
        git_base = vim.fn.input "Enter a Git base or just <CR> for default HEAD: "
      end
      print "\n"
      conditional_neotree_exec {
        action = "focus",
        source = "filesystem",
        position = "right",
        git_base = git_base == "" and "HEAD" or git_base,
        reveal_force_cwd = false,
      }
    end, { desc = "Toggle neo-tree with custom Git base" })
  end,
}

return {
  {
    "stevearc/aerial.nvim",
    keys = {
      {
        "<leader>vo",
        function()
          require("telescope").extensions.aerial.aerial()
        end,
        desc = "Code Outline",
      },
    },
    config = true,
    init = function()
      require("telescope").load_extension "aerial"
    end,
  },
  {
    "ahmedkhalf/project.nvim",
    -- Telescope mappings
    -- Normal mode  Insert mode Action
    -- f            <c-f>       find_project_files
    -- b            <c-b>       browse_project_files
    -- d            <c-d>       delete_project
    -- s            <c-s>       search_in_project_files
    -- r            <c-r>       recent_project_files
    -- w            <c-w>       change_working_directory
    keys = {
      {
        "<leader>fp",
        function()
          require("telescope").extensions.projects.projects()
        end,
        desc = "Projects",
      },
    },
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
    init = function()
      require("telescope").load_extension "projects"
    end,
  },
  {
    "AckslD/nvim-neoclip.lua",
    keys = {
      {
        "<leader>fc",
        function()
          require("telescope").extensions.neoclip.default()
        end,
        desc = "Clipboard",
      },
    },
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
    init = function()
      require("telescope").load_extension "neoclip"
    end,
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
    init = function()
      require("telescope").load_extension "harpoon"
    end,
  },
  {
    "jedrzejboczar/possession.nvim",
    dependencies = {
      { "nvim-lua/plenary.nvim" },
      {
        "tiagovla/scope.nvim",
        config = true,
      },
    },
    lazy = false,
    config = function()
      require("possession").setup {
        autosave = {
          current = true, -- or fun(name): boolean
        },
        plugins = { delete_hidden_buffers = { hooks = {} } },
        telescope = {
          list = {
            default_action = "load",
            mappings = {
              save = { n = "<c-s>", i = "<c-s>" },
              load = { n = "<c-l>", i = "<c-l>" },
              delete = { n = "<c-x>", i = "<c-x>" },
              rename = { n = "<c-r>", i = "<c-r>" },
            },
          },
        },
      }

      local function transform_cwd(cwd)
        if cwd then
          return cwd:gsub("/", "@_@"):gsub(":", "@+@")
        end
      end

      local function get_session_name()
        local session_name, _ = vim.fn.getcwd(-1, -1):gsub("/", "@_@"):gsub(":", "@+@")
        return session_name
      end

      local function get_session_file(session_name)
        local session_file = vim.fn.stdpath "data" .. "/possession/" .. session_name .. ".json"
        return session_file
      end

      local function close_neo_tree()
        require("neo-tree.sources.manager").close_all()
        vim.notify "closed all"
      end

      local function handle_current_cwd_session(cmd)
        local session_cwd, _ = vim.fn.getcwd(-1, -1)
        local session_name = transform_cwd(session_cwd)
        local session_file = get_session_file(session_name)
        if cmd == "load" then
          if vim.fn.filereadable(session_file) == 1 then
            require("possession").load(session_name)
          end
        elseif cmd == "delete" then
          if vim.fn.filewritable(session_file) == 1 then
            require("possession").delete(session_name)
          end
        elseif cmd == "save" then
          -- close_neo_tree()
          require("possession").save(session_name)
          print("Session CWD is: " .. session_cwd)
        end
      end

      local function save_session()
        local session_cwd, _ = vim.fn.getcwd(-1, -1) -- /foo/bar/baz or C:\foo\bar\baz
        local pathsep = package.config:sub(1, 1) -- Returns "\\" on Windows, "/" on Unix-like systems
        local parts = {}
        if session_cwd then
          parts = vim.fn.split(session_cwd, pathsep)
        end
        local last_part = parts[#parts]
        vim.ui.input(
          { prompt = "Session name: ", default = last_part or "" },
          function(session_name)
            if session_name ~= "" then
              require("possession").save(session_name)
            end
          end
        )
      end

      local config_group = vim.api.nvim_create_augroup("SessionManagerCustom", {})
      vim.api.nvim_create_autocmd({ "VimEnter" }, {
        pattern = "*",
        callback = function()
          if
            vim.fn.argc() ~= 0 -- git or `nvim ...`.
          then
            return
          end
          vim.g.CWD_initial = vim.fn.getcwd(-1, -1)
          -- Load the current CWD session if it exists automatically.
          -- handle_current_cwd_session "load"
        end,
      })
      vim.api.nvim_create_autocmd({ "VimLeavePre" }, {
        group = config_group,
        callback = function()
          local git_filetypes = {
            "git",
            "gitcommit",
            "gitconfig",
            "gitrebase",
            "gitsendemail",
          }
          local buf_filetype = vim.bo.filetype
          for _, str in ipairs(git_filetypes) do
            if str == buf_filetype then
              return
            end
          end
          handle_current_cwd_session "save"
          vim.api.nvim_set_current_dir(vim.g.CWD_initial)
          local session_name = get_session_name()
          require("possession").save(session_name)
        end,
      })

      vim.keymap.set("n", "<leader>qa", function()
        require("telescope").extensions.possession.list()
      end, { desc = "Show All sessions" })
      vim.keymap.set("n", "<leader>fb", function()
        require("telescope").extensions.scope.buffers()
      end, { desc = "Buffers accross all tabs" })
      vim.keymap.set("n", "<leader>qL", function()
        handle_current_cwd_session "load"
      end, { desc = "Load the current CWD session" })
      vim.keymap.set("n", "<leader>qS", function()
        handle_current_cwd_session "save"
      end, { desc = "Save the current CWD session" })
      vim.keymap.set("n", "<leader>qD", function()
        handle_current_cwd_session "delete"
      end, { desc = "Delete the current CWD session" })
      vim.keymap.set("n", "<leader>qs", function()
        save_session()
      end, { desc = "Save session" })

      require("telescope").load_extension "possession"
      require("telescope").load_extension "scope"
    end,
  },
  {
    "johmsalas/text-case.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-telescope/telescope.nvim" },
    -- Author's Note: If default keymappings fail to register (possible config issue in my local setup),
    -- verify lazy loading functionality. On failure, disable lazy load and report issue
    -- lazy = false,
    keys = {
      { "ga.", "<Cmd>TextCaseOpenTelescope<CR>", mode = { "n", "v" }, desc = "Telescope" },
      { "gaa", "<Cmd>TextCaseOpenTelescopeQuickChange<CR>", desc = "Telescope Quick Change" },
      { "gai", "<Cmd>TextCaseOpenTelescopeLSPChange<CR>", desc = "Telescope LSP Change" },
      { "<leader>ga", "ga", desc = "Show the char code" },
    },
    config = function()
      require("textcase").setup {}
      require("telescope").load_extension "textcase"
    end,
  },
  {
    "desdic/macrothis.nvim",
    opts = {},
    keys = {
      {
        "<Leader>kkd",
        function()
          require("macrothis").delete()
        end,
        desc = "delete",
      },
      {
        "<Leader>kke",
        function()
          require("macrothis").edit()
        end,
        desc = "edit",
      },
      {
        "<Leader>kkl",
        function()
          require("macrothis").load()
        end,
        desc = "load",
      },
      {
        "<Leader>kkn",
        function()
          require("macrothis").rename()
        end,
        desc = "rename",
      },
      {
        "<Leader>kkq",
        function()
          require("macrothis").quickfix()
        end,
        desc = "run macro on all files in quickfix",
      },
      {
        "<Leader>kkr",
        function()
          require("macrothis").run()
        end,
        desc = "run macro",
      },
      {
        "<Leader>kks",
        function()
          require("macrothis").save()
        end,
        desc = "save",
      },
      {
        "<Leader>kkx",
        function()
          require("macrothis").register()
        end,
        desc = "edit register",
      },
      {
        "<Leader>kkp",
        function()
          require("macrothis").copy_register_printable()
        end,
        desc = "Copy register as printable",
      },
      {
        "<Leader>kkm",
        function()
          require("macrothis").copy_macro_printable()
        end,
        desc = "Copy macro as printable",
      },
      {
        "<leader>fm",
        function()
          require("telescope").extensions.macrothis.macrothis()
        end,
        desc = "Macrothis",
      },
    },
    init = function()
      require("telescope").load_extension "macrothis"
    end,
  },
}

return {
  {
    "stevearc/aerial.nvim",
    config = true,
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

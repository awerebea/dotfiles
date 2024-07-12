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
    "LennyPhoenix/project.nvim", -- Temporary switch to fork
    branch = "fix-get_clients",
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
      {
        "<leader><leader>m",
        function()
          local filename = vim.api.nvim_buf_get_name(0)
          if filename == "" then
            vim.notify("Couldn't find a valid file name to mark, sorry.")
            return
          end
          vim.notify("Add Harpoon mark for file: " .. vim.fn.fnamemodify(filename, ":."))
          require("harpoon.mark").add_file()
        end,
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
    "johmsalas/text-case.nvim",
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

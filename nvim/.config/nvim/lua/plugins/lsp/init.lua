return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      { "smjonas/inc-rename.nvim", config = true },
    },
    opts = {
      -- server binaries come from mise (mise/.config/mise/conf.d/nvim.toml)
      servers = {
        lua_ls = {
          settings = {
            Lua = {
              workspace = {
                checkThirdParty = false,
              },
              completion = { callSnippet = "Replace" },
              telemetry = { enable = false },
              hint = {
                enable = false,
              },
              diagnostics = { globals = { "vim" } },
            },
          },
        },
        dockerls = {},
        cssls = {},
        emmet_language_server = {},
        html = {},
        tailwindcss = {},
        -- TypeScript 7's native `tsc --lsp`; replaces ts_ls, which needs the
        -- JS tsserver that TypeScript 7 no longer ships
        tsc = {},
        pyright = {
          settings = {
            pyright = {
              disableOrganizeImports = true, -- Use Ruff's import organizer
            },
            python = {
              analysis = {
                -- ignore = { "*" }, -- Ignore all files to exclusively use Ruff for linting
                -- "off" | "basic" | "standard" | "strict" ("off" to leave type checks to mypy)
                typeCheckingMode = "standard",
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
                -- check open files only; "workspace" type-checks the whole repo in the background
                diagnosticMode = "openFilesOnly",
              },
            },
          },
        },
        terraformls = {},
        bashls = { filetypes = { "sh", "zsh" } },
        gopls = {},
        ruff = {
          on_attach = function(client)
            -- Disable hover in favor of Pyright
            client.server_capabilities.hoverProvider = false
          end,
        },
        marksman = {},
        yamlls = {},
        taplo = {},
      },
      -- per-server handlers; one returning true takes over starting the server
      setup = {},
    },
    config = function(plugin, opts)
      require("plugins.lsp.servers").setup(plugin, opts)
    end,
  },
  {
    "folke/trouble.nvim",
    cmd = { "TroubleToggle", "Trouble" },
    opts = { use_diagnostic_signs = true },
    keys = {
      {
        "<leader>xx",
        function()
          require("trouble").toggle()
        end,
        desc = "Toggle Trouble",
      },
      {
        "<leader>xw",
        function()
          require("trouble").toggle("workspace_diagnostics")
        end,
        desc = "Workspace Diagnostics",
      },
      {
        "<leader>xd",
        function()
          require("trouble").toggle("document_diagnostics")
        end,
        desc = "Document Diagnostics",
      },
      {
        "<leader>xq",
        function()
          require("trouble").toggle("quickfix")
        end,
        desc = "Trouble quickfix",
      },
      {
        "<leader>xl",
        function()
          require("trouble").toggle("loclist")
        end,
        desc = "Trouble loclist",
      },
      {
        "gR",
        function()
          require("trouble").toggle("lsp_references")
        end,
        desc = "Trouble LSP references",
      },
    },
  },
  {
    -- Neovim API and plugin types for lua_ls, added to the workspace only
    -- for the modules a file actually requires (replaces neodev)
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
        { path = "snacks.nvim", words = { "Snacks" } },
        "neotest",
      },
    },
  },
  {
    "Bekaboo/dropbar.nvim",
    event = "BufReadPost",
    keys = {
      {
        "<leader>nb",
        function()
          require("dropbar.api").pick()
        end,
        desc = "Pick symbol in breadcrumbs (dropbar)",
      },
    },
    enabled = function()
      return vim.fn.has("nvim-0.10.0") == 1
    end,
  },
}

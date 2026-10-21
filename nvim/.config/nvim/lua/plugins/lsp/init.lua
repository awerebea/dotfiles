return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      { "folke/neoconf.nvim", cmd = "Neoconf", config = true },
      { "smjonas/inc-rename.nvim", config = true },
      { "mason-org/mason.nvim", version = "^1.0.0" },
      { "mason-org/mason-lspconfig.nvim", version = "^1.0.0" },
    },
    opts = {
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
        emmet_ls = {},
        html = {},
        tailwindcss = {},
        ts_ls = {},
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
        rust_analyzer = {},
        gopls = {},
        ruff = {},
        marksman = {},
        yamlls = {},
        taplo = {},
      },
      setup = {
        lua_ls = function(_, _)
          local lsp_utils = require("plugins.lsp.utils")
          lsp_utils.on_attach(function(client, buffer)
            if client.name == "lua_ls" then
              vim.keymap.set("n", "<leader>dX", function()
                require("osv").run_this()
              end, { buffer = buffer, desc = "OSV Run" })
              vim.keymap.set("n", "<leader>dL", function()
                require("osv").launch({ port = 8086 })
              end, { buffer = buffer, desc = "OSV Launch" })
            elseif client.name == "pyright" then
              vim.keymap.set("n", "<leader>tC", function()
                require("dap-python").test_class()
              end, { buffer = buffer, desc = "Debug Class" })
              vim.keymap.set("n", "<leader>tM", function()
                require("dap-python").test_method()
              end, { buffer = buffer, desc = "Debug Method" })
              vim.keymap.set("v", "<leader>tS", function()
                require("dap-python").debug_selection()
              end, { buffer = buffer, desc = "Debug Selection" })
            elseif client.name == "ruff" then
              -- Disable hover in favor of Pyright
              client.server_capabilities.hoverProvider = false
            end
          end)
        end,
      },
    },
    config = function(plugin, opts)
      require("plugins.lsp.servers").setup(plugin, opts)
    end,
  },
  {
    "williamboman/mason.nvim",
    build = ":MasonUpdate",
    cmd = "Mason",
    keys = { { "<leader><leader>M", "<Cmd>Mason<CR>", desc = "Mason" } },
    opts = {
      ensure_installed = {
        "prettierd",
        "stylua",
        "isort",
        "black",
        "mypy",
        "pylint",
        "shellcheck",
        "beautysh",
        "shfmt",
        "debugpy",
        "codelldb",
        "powershell-editor-services",
        "yamlfmt",
      },
    },
    config = function(_, opts)
      require("mason").setup()
      local mr = require("mason-registry")
      local function ensure_installed()
        for _, tool in ipairs(opts.ensure_installed) do
          local p = mr.get_package(tool)
          if not p:is_installed() then
            p:install()
          end
        end
      end
      if mr.refresh then
        mr.refresh(ensure_installed)
      else
        ensure_installed()
      end
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

return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      { "smjonas/inc-rename.nvim", config = true },
    },
    opts = {
      -- `mason` is the mason package that provides the server (stripped before
      -- vim.lsp.config); servers without it are not installed by mason
      servers = {
        lua_ls = {
          mason = "lua-language-server",
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
        dockerls = { mason = "dockerfile-language-server" },
        cssls = { mason = "css-lsp" },
        emmet_ls = { mason = "emmet-ls" },
        html = { mason = "html-lsp" },
        tailwindcss = { mason = "tailwindcss-language-server" },
        ts_ls = { mason = "typescript-language-server" },
        pyright = {
          mason = "pyright",
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
        terraformls = { mason = "terraform-ls" },
        bashls = { mason = "bash-language-server", filetypes = { "sh", "zsh" } },
        rust_analyzer = { mason = "rust-analyzer" },
        gopls = { mason = "gopls" },
        ruff = { mason = "ruff" },
        marksman = { mason = "marksman" },
        yamlls = { mason = "yaml-language-server" },
        taplo = { mason = "taplo" },
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
    -- not loaded on file open: servers.lua puts mason/bin on PATH and loads
    -- mason only when a server binary or a tool below is missing
    "mason-org/mason.nvim",
    version = "^1.0.0",
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
      -- the tools above plus the package of every configured server
      local packages = vim.list_extend({}, opts.ensure_installed)
      local servers = require("plugins.lsp.utils").opts("nvim-lspconfig").servers or {}
      for _, server_opts in pairs(servers) do
        if type(server_opts) == "table" and server_opts.mason then
          packages[#packages + 1] = server_opts.mason
        end
      end
      local function ensure_installed()
        for _, name in ipairs(packages) do
          local p = mr.get_package(name)
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

return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      { "folke/neoconf.nvim", cmd = "Neoconf", config = true },
      {
        "folke/neodev.nvim",
        opts = {
          library = { plugins = { "neotest", "nvim-dap-ui" }, types = true },
        },
      },
      { "smjonas/inc-rename.nvim", config = true },
      { "mason-org/mason.nvim", version = "^1.0.0" },
      { "mason-org/mason-lspconfig.nvim", version = "^1.0.0" },
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-nvim-lsp-signature-help",
      {
        "ray-x/lsp_signature.nvim",
        opts = {
          floating_window = false,
          hint_enable = true,
          toggle_key = "<M-x>",
          toggle_key_flip_floatwin_setting = true,
        },
        config = function(_, opts)
          require("lsp_signature").setup(opts)
        end,
      },
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
                typeCheckingMode = "on", -- "on", "basic", "off" (off to use mypy)
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
                diagnosticMode = "workspace",
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
    "ErichDonGubler/lsp_lines.nvim",
    event = "VeryLazy",
    config = function()
      require("lsp_lines").setup()
      -- toggle diagnostic lines
      local diagnostics_mode = 0
      function ToggleDiagnosticsMode()
        if diagnostics_mode == 0 then
          vim.diagnostic.config({ virtual_text = false, virtual_lines = true })
          diagnostics_mode = 1
        elseif diagnostics_mode == 1 then
          vim.diagnostic.config({ virtual_text = false, virtual_lines = false })
          diagnostics_mode = 2
        elseif diagnostics_mode == 2 then
          vim.diagnostic.config({
            virtual_text = { severity = { min = vim.diagnostic.severity.ERROR } },
            virtual_lines = false,
          })
          diagnostics_mode = 0
        end
      end

      vim.keymap.set(
        "n",
        "<leader>td",
        "<Cmd>lua ToggleDiagnosticsMode()<CR>",
        { desc = "Toggle Diagnostics Mode" }
      )
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
    "Bekaboo/dropbar.nvim",
    event = "BufReadPost",
    enabled = function()
      return vim.fn.has("nvim-0.10.0") == 1
    end,
  },
}

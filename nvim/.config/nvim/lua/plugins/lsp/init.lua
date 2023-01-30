return {
  {
    "neovim/nvim-lspconfig",
    event = "BufReadPre",
    dependencies = {
      { "folke/neoconf.nvim", cmd = "Neoconf", config = true },
      {
        "folke/neodev.nvim",
        opts = {
          library = { plugins = { "neotest" }, types = true },
        },
      },
      { "j-hui/fidget.nvim", config = true },
      { "smjonas/inc-rename.nvim", config = true },
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-nvim-lsp-signature-help",
    },
    opts = {
      servers = {
        sumneko_lua = {
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
            },
          },
        },
        dockerls = {},
        cssls = {},
        emmet_ls = {},
        html = {},
        tailwindcss = {},
        tsserver = {},
        pyright = {},
        terraformls = {},
        bashls = {},
        rust_analyzer = {},
        gopls = {},
      },
      setup = {
        sumneko_lua = function(_, _)
          local lsp_utils = require "plugins.lsp.utils"
          lsp_utils.on_attach(function(client, buffer)
            if client.name == "sumneko_lua" then
              vim.keymap.set("n", "<leader>dX", function()
                require("osv").run_this()
              end, { buffer = buffer, desc = "OSV Run" })
              vim.keymap.set("n", "<leader>dL", function()
                require("osv").launch { port = 8086 }
              end, { buffer = buffer, desc = "OSV Launch" })
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
    cmd = "Mason",
    keys = { { "<leader>cm", "<Cmd>Mason<CR>", desc = "Mason" } },
    opts = {
      ensure_installed = {
        "prettier",
        "stylua",
        "eslint_d",
        -- "autopep8",
        "flake8",
        "yapf",
        "pydocstyle",
        -- "pylama",
        "pylint",
        "tflint",
        "shellcheck",
        "shellharden",
        "beautysh",
        "ruff",
        "debugpy",
        "codelldb",
      },
    },
    config = function(_, opts)
      require("mason").setup()
      local mr = require "mason-registry"
      for _, tool in ipairs(opts.ensure_installed) do
        local p = mr.get_package(tool)
        if not p:is_installed() then
          p:install()
        end
      end
    end,
  },
  {
    "jose-elias-alvarez/null-ls.nvim",
    event = "BufReadPre",
    dependencies = { "mason.nvim" },
    config = function()
      local nls = require "null-ls"
      nls.setup {
        sources = {
          nls.builtins.formatting.prettier,
          nls.builtins.formatting.stylua.with { extra_args = { "--column-width", "99" } },
          nls.builtins.diagnostics.eslint_d.with { -- js/ts linter
            -- only enable eslint if root has .eslintrc.js
            condition = function(utils)
              return utils.root_has_file ".eslintrc.js" -- change file extension if you use something else
            end,
          },
          nls.builtins.formatting.yapf.with {
            extra_args = {
              "--style={based_on_style: google, column_limit: 99, indent_width: 4}",
            },
          },
          -- nls.builtins.formatting.autopep8,
          -- nls.builtins.diagnostics.pylama,
          nls.builtins.diagnostics.pylint,
          nls.builtins.diagnostics.pydocstyle,
          nls.builtins.diagnostics.flake8.with { extra_args = { "--max-line-length=99" } },
          nls.builtins.formatting.terraform_fmt,
          nls.builtins.formatting.beautysh,
          nls.builtins.formatting.shellharden,
          nls.builtins.diagnostics.ruff.with { extra_args = { "--max-line-length=99" } },
        },
      }
    end,
  },
  {
    "utilyre/barbecue.nvim",
    event = "VeryLazy",
    dependencies = {
      "neovim/nvim-lspconfig",
      "SmiteshP/nvim-navic",
      "nvim-tree/nvim-web-devicons",
    },
    config = true,
  },
  {
    url = "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
    event = "VeryLazy",
    -- config = true,
    config = function()
      require("lsp_lines").setup()
      -- toggle diagnostic lines
      local diagnostics_mode = 0
      function ToggleDiagnosticsMode()
        if diagnostics_mode == 0 then
          vim.diagnostic.config { virtual_text = false, virtual_lines = true }
          diagnostics_mode = 1
        elseif diagnostics_mode == 1 then
          vim.diagnostic.config { virtual_text = false, virtual_lines = false }
          diagnostics_mode = 2
        elseif diagnostics_mode == 2 then
          vim.diagnostic.config {
            virtual_text = { severity = { min = vim.diagnostic.severity.ERROR } },
            virtual_lines = false,
          }
          diagnostics_mode = 0
        end
      end
      vim.keymap.set("n", "<leader>td", "<Cmd>lua ToggleDiagnosticsMode()<CR>")
    end,
  },
  {
    "folke/trouble.nvim",
    cmd = { "TroubleToggle", "Trouble" },
    opts = { use_diagnostic_signs = true },
    keys = {
      { "<leader>xx", "<Cmd>TroubleToggle<CR>" },
      { "<leader>xw", "<Cmd>TroubleToggle workspace_diagnostics<CR>" },
      { "<leader>xd", "<Cmd>TroubleToggle document_diagnostics<CR>" },
      { "<leader>xl", "<Cmd>TroubleToggle loclist<CR>" },
      { "<leader>xq", "<Cmd>TroubleToggle quickfix<CR>" },
      { "gR", "<Cmd>TroubleToggle lsp_references<CR>" },
    },
    {
      "glepnir/lspsaga.nvim",
      event = "VeryLazy",
      config = true,
    },
  },
}

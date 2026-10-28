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
    -- Windows only: elsewhere the same tools come from mise
    -- (mise/.config/mise/conf.d/nvim.toml), keep both lists in sync
    "mason-org/mason.nvim",
    version = "^2.0.0",
    enabled = require("utils").is_windows(),
    event = "VeryLazy",
    cmd = "Mason",
    build = ":MasonUpdate",
    keys = { { "<leader><leader>M", "<Cmd>Mason<CR>", desc = "Mason" } },
    -- servers for a file opened from the command line start before VeryLazy,
    -- so put mason's bin dir on PATH right away; loading mason can wait
    init = function()
      local bin = vim.fn.stdpath("data") .. "\\mason\\bin"
      if not vim.env.PATH:find(bin, 1, true) then
        vim.env.PATH = bin .. ";" .. vim.env.PATH
      end
    end,
    opts = {
      ensure_installed = {
        -- language servers
        "lua-language-server",
        "marksman",
        "ruff",
        "taplo",
        "terraform-ls",
        "gopls",
        "rust-analyzer",
        "bash-language-server",
        "dockerfile-language-server",
        "emmet-language-server",
        "pyright",
        "tailwindcss-language-server",
        "tsc", -- TypeScript 7
        "css-lsp",
        "html-lsp",
        "json-lsp",
        "yaml-language-server",
        -- formatters
        "shfmt",
        "stylua",
        "yamlfmt",
        "prettierd",
        "black",
        "isort",
        -- linters
        "shellcheck",
        "mypy",
        "refurb",
      },
    },
    config = function(_, opts)
      require("mason").setup({ PATH = "skip" }) -- init already did it
      local mr = require("mason-registry")
      mr.refresh(function()
        for _, name in ipairs(opts.ensure_installed) do
          local ok, p = pcall(mr.get_package, name)
          if ok and not p:is_installed() then
            p:install()
          end
        end
      end)
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

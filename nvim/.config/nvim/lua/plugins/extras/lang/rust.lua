return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, { "rust" })
    end,
  },
  {
    -- Starts and configures rust-analyzer itself for Rust buffers (lazy by
    -- design, so it must not be lazy-loaded). Debugging uses codelldb from
    -- Mason automatically once nvim-dap is installed.
    "mrcjkb/rustaceanvim",
    version = "^9",
    lazy = false,
    init = function()
      vim.g.rustaceanvim = function()
        return {
          server = {
            capabilities = require("plugins.lsp.utils").capabilities(),
            on_attach = function(_, buffer)
              -- stylua: ignore start
              vim.keymap.set("n", "<leader>cR", function() vim.cmd.RustLsp("runnables") end, { buffer = buffer, desc = "Runnables" })
              vim.keymap.set("n", "<leader>cl", vim.lsp.codelens.run, { buffer = buffer, desc = "Code Lens" })
              -- stylua: ignore end
              -- refreshed by Neovim when the buffer changes
              vim.lsp.codelens.enable(true, { bufnr = buffer })
            end,
            default_settings = {
              ["rust-analyzer"] = {
                cargo = { allFeatures = true },
                checkOnSave = true,
                check = {
                  command = "clippy",
                  extraArgs = { "--no-deps" },
                },
              },
            },
          },
        }
      end
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      setup = {
        -- rust_analyzer stays in the server list so that Mason installs it,
        -- but rustaceanvim starts it
        rust_analyzer = function()
          return true
        end,
      },
    },
  },
}

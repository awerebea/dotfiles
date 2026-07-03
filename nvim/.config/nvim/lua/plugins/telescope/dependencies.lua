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
      require("telescope").load_extension("aerial")
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
      require("textcase").setup({})
      require("telescope").load_extension("textcase")
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
        desc = "Delete",
      },
      {
        "<Leader>kke",
        function()
          require("macrothis").edit()
        end,
        desc = "Edit",
      },
      {
        "<Leader>kkl",
        function()
          require("macrothis").load()
        end,
        desc = "Load",
      },
      {
        "<Leader>kkn",
        function()
          require("macrothis").rename()
        end,
        desc = "Rename",
      },
      {
        "<Leader>kkq",
        function()
          require("macrothis").quickfix()
        end,
        desc = "Run macro on all quickfix files",
      },
      {
        "<Leader>kkr",
        function()
          require("macrothis").run()
        end,
        desc = "Run macro",
      },
      {
        "<Leader>kks",
        function()
          require("macrothis").save()
        end,
        desc = "Save",
      },
      {
        "<Leader>kkx",
        function()
          require("macrothis").register()
        end,
        desc = "Edit register",
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
      require("telescope").load_extension("macrothis")
    end,
  },
}

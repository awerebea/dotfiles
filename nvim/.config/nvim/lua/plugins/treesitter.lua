return {
  {
    "nvim-treesitter/nvim-treesitter",
    dependencies = {
      "JoosepAlviste/nvim-ts-context-commentstring",
      "RRethy/nvim-treesitter-endwise",
      { "nvim-treesitter/nvim-treesitter-textobjects", branch = "main" },
      { "HiPhish/rainbow-delimiters.nvim", submodules = false },
      "windwp/nvim-ts-autotag",
    },
    -- nvim-treesitter v1.0 does not support lazy-loading
    lazy = false,
    -- opts.ensure_installed is not a real nvim-treesitter v1.0 option, but we keep it here
    -- so that lang extras (lua/plugins/extras/lang/*.lua) can extend the list via
    -- vim.list_extend(opts.ensure_installed, {...}). The config function passes the
    -- merged list to require("nvim-treesitter").install().
    opts = {
      ensure_installed = {
        "bash",
        "css",
        "dockerfile",
        "gitignore",
        "graphql",
        "hcl",
        "html",
        "javascript",
        "json",
        "lua",
        "markdown",
        "markdown_inline",
        "python",
        "query",
        "regex",
        "rust",
        "svelte",
        "terraform",
        "tsx",
        "typescript",
        "vim",
        "vimdoc",
        "yaml",
      },
    },
    config = function(_, opts)
      require("nvim-treesitter").setup()

      -- Install parsers from the merged list (no-op if already installed)
      require("nvim-treesitter").install(opts.ensure_installed)

      -- In nvim-treesitter v1.0, highlighting is not automatic — enable it per filetype.
      vim.api.nvim_create_autocmd("FileType", {
        callback = function()
          pcall(vim.treesitter.start)
        end,
      })

      require("nvim-ts-autotag").setup()

      -- nvim-treesitter-textobjects v1.0 (main branch) uses explicit keymaps instead of declarative config.
      require("nvim-treesitter-textobjects").setup({
        select = { lookahead = true },
        move = { set_jumps = true },
      })

      local select = require("nvim-treesitter-textobjects.select")
      for key, query in pairs({
        ["aa"] = "@parameter.outer",
        ["ia"] = "@parameter.inner",
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["ac"] = "@class.outer",
        ["ic"] = "@class.inner",
        ["ii"] = "@conditional.inner",
        ["ai"] = "@conditional.outer",
        ["il"] = "@loop.inner",
        ["al"] = "@loop.outer",
        ["at"] = "@comment.outer",
      }) do
        vim.keymap.set({ "x", "o" }, key, function()
          select.select_textobject(query, "textobjects")
        end)
      end

      local move = require("nvim-treesitter-textobjects.move")
      vim.keymap.set({ "n", "x", "o" }, "]m",  function() move.goto_next_start("@function.outer", "textobjects") end)
      vim.keymap.set({ "n", "x", "o" }, "]]",  function() move.goto_next_start("@class.outer", "textobjects") end)
      vim.keymap.set({ "n", "x", "o" }, "]M",  function() move.goto_next_end("@function.outer", "textobjects") end)
      vim.keymap.set({ "n", "x", "o" }, "][",  function() move.goto_next_end("@class.outer", "textobjects") end)
      vim.keymap.set({ "n", "x", "o" }, "[m",  function() move.goto_previous_start("@function.outer", "textobjects") end)
      vim.keymap.set({ "n", "x", "o" }, "[[",  function() move.goto_previous_start("@class.outer", "textobjects") end)
      vim.keymap.set({ "n", "x", "o" }, "[M",  function() move.goto_previous_end("@function.outer", "textobjects") end)
      vim.keymap.set({ "n", "x", "o" }, "[]",  function() move.goto_previous_end("@class.outer", "textobjects") end)

      local swap = require("nvim-treesitter-textobjects.swap")
      vim.keymap.set("n", "<leader>cxp", function() swap.swap_next("@parameter.inner") end)
      vim.keymap.set("n", "<leader>cxf", function() swap.swap_next("@function.outer") end)
      vim.keymap.set("n", "<leader>cxc", function() swap.swap_next("@class.outer") end)
      vim.keymap.set("n", "<leader>cxP", function() swap.swap_previous("@parameter.inner") end)
      vim.keymap.set("n", "<leader>cxF", function() swap.swap_previous("@function.outer") end)
      vim.keymap.set("n", "<leader>cxC", function() swap.swap_previous("@class.outer") end)
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = "VeryLazy",
    enabled = true,
    opts = { mode = "cursor", max_lines = 3 },
    keys = {
      {
        "<leader>tTc",
        function()
          require("treesitter-context").toggle()
        end,
        desc = "Toggle Treesitter Context",
      },
    },
  },
}

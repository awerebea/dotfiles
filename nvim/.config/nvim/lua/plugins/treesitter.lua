return {
  {
    "nvim-treesitter/nvim-treesitter",
    dependencies = {
      "JoosepAlviste/nvim-ts-context-commentstring",
      "RRethy/nvim-treesitter-endwise",
      "nvim-treesitter/nvim-treesitter-textobjects",
      "p00f/nvim-ts-rainbow",
      "windwp/nvim-ts-autotag",
    },
    build = ":TSUpdate",
    event = "BufReadPost",
    opts = {
      sync_install = false,
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
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = true,
        disable = { "gitcommit" },
      },
      indent = { enable = true, disable = { "python" } },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "gnn",
          node_incremental = "grn",
          scope_incremental = "grc",
          node_decremental = "grm",
        },
      },
      textobjects = {
        select = {
          enable = true,
          lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
          keymaps = {
            -- You can use the capture groups defined in textobjects.scm
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
          },
        },
        move = {
          enable = true,
          set_jumps = true, -- whether to set jumps in the jumplist
          goto_next_start = {
            ["]m"] = "@function.outer",
            ["]]"] = "@class.outer",
          },
          goto_next_end = {
            ["]M"] = "@function.outer",
            ["]["] = "@class.outer",
          },
          goto_previous_start = {
            ["[m"] = "@function.outer",
            ["[["] = "@class.outer",
          },
          goto_previous_end = {
            ["[M"] = "@function.outer",
            ["[]"] = "@class.outer",
          },
        },
        swap = {
          enable = true,
          swap_next = {
            ["<leader>cxp"] = "@parameter.inner",
            ["<leader>cxf"] = "@function.outer",
            ["<leader>cxc"] = "@class.outer",
          },
          swap_previous = {
            ["<leader>cxP"] = "@parameter.inner",
            ["<leader>cxF"] = "@function.outer",
            ["<leader>cxC"] = "@class.outer",
          },
        },
        -- TODO: check if I need it
        lsp_interop = {
          enable = true,
          border = "none",
          peek_definition_code = {
            ["<leader>pf"] = "@function.outer",
            ["<leader>pc"] = "@class.outer",
          },
        },
      },
      matchup = {
        enable = true,
      },
      endwise = {
        enable = true,
      },
      rainbow = {
        enable = true,
        extended_mode = true,
        colors = {
          "#ff0000",
          "#ff8000",
          "#ffff00",
          "#80ff00",
          "#00ffff",
          "#0080ff",
          "#8000ff",
          "#ff00ff",
          "#ff0080",
        },
      },
      autotag = { enable = true },
    },
    config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)
      -- require("ts_context_commentstring").setup {}
      -- vim.g.skip_ts_context_commentstring_module = true
    end,
  },
}

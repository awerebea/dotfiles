return {
  "AckslD/nvim-neoclip.lua",
  enabled = true,
  keys = {
    {
      "<leader>fcc",
      function()
        require("telescope").extensions.neoclip.default()
      end,
      desc = "Clipboard",
    },
    {
      "<leader>fcl",
      function()
        require("neoclip").db_pull()
      end,
      desc = "Pull database",
    },
    {
      "<leader>fcp",
      function()
        require("neoclip").db_push()
      end,
      desc = "Push database",
    },
  },
  dependencies = { "kkharji/sqlite.lua" },
  -- Loading reads the whole history database (~40 ms with 900 entries), so
  -- load on the first yank instead of at startup; lazy.nvim re-sends the
  -- event, so that yank is still recorded
  event = "TextYankPost",
  opts = {
    -- every yank rewrites the database and every picker open reads it
    -- (continuous_sync), and both scale with the number of entries
    history = 300,
    enable_persistent_history = true,
    -- sync on every change, so several nvim instances do not overwrite each
    -- other's history on exit
    continuous_sync = true,
    db_path = vim.fn.stdpath("data") .. "/databases/neoclip.sqlite3",
    default_register = "+",
    content_spec_column = true,
    keys = {
      telescope = {
        i = {
          select = "<CR>",
          paste = "<C-p>",
          paste_behind = "<C-M-p>",
          replay = "<C-q>", -- replay a macro
          delete = "<C-d>", -- delete an entry
        },
        n = {
          select = "<CR>",
          paste = { "p", "<C-p>" },
          paste_behind = { "P", "<C-M-p>" },
          replay = "q",
          delete = "d",
        },
      },
    },
    on_select = { move_to_front = true },
    on_paste = { move_to_front = true },
  },
  config = function(_, opts)
    require("neoclip").setup(opts)
    -- only when telescope is already loaded: requiring it here would load
    -- telescope and all its extensions on the first yank. The picker keymap
    -- loads the extension on demand through telescope.extensions
    if package.loaded.telescope then
      require("telescope").load_extension("neoclip")
    end
  end,
}

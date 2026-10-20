-- Commenting uses the built-in gc/gcc (:h commenting); the extra keymaps
-- (gco, gb, <C-/>, ...) are in config/comment.lua.
return {
  {
    -- Loaded at startup as an nvim-treesitter dependency. Gives the built-in
    -- commenting the 'commentstring' of the tree-sitter node at the cursor
    -- (JSX in TSX, <script> in HTML, code blocks in markdown, ...).
    "JoosepAlviste/nvim-ts-context-commentstring",
    -- computed on demand below instead of on every CursorHold
    opts = { enable_autocmd = false },
    config = function(_, opts)
      require("ts_context_commentstring").setup(opts)
      local get_option = vim.filetype.get_option
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.filetype.get_option = function(filetype, option)
        if option == "commentstring" then
          local ok, cs =
            pcall(require("ts_context_commentstring.internal").calculate_commentstring)
          if ok and cs then
            return cs
          end
        end
        return get_option(filetype, option)
      end
    end,
  },
}

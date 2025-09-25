return {
  {
    enabled = false,
    "andrejlevkovitch/vim-lua-format",
    event = "VeryLazy",
    config = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "lua",
        callback = function()
          vim.api.nvim_buf_set_keymap(
            0,
            "n",
            "<C-k>",
            ":call LuaFormat()<CR>",
            { noremap = true, silent = true }
          )
        end,
      })

      vim.api.nvim_create_autocmd("BufWritePre", {
        pattern = "*.lua",
        callback = function()
          vim.cmd "call LuaFormat()"
        end,
      })
    end,
  },
}

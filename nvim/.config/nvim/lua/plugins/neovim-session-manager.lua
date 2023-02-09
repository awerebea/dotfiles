return {
  {
    "Shatur/neovim-session-manager",
    -- event = "VimEnter",
    lazy = false,
    config = function()
      require("session_manager").setup {
        -- Disabled, CurrentDir, LastSession
        autoload_mode = require("session_manager.config").AutoloadMode.CurrentDir,
        path_replacer = "@_@",
        colon_replacer = "@+@",
        autosave_last_session = false, -- Avoid saving sessions with names that do not match CWD_initial
        -- Do not save when no buffers are opened, or all of them aren't writable or listed.
        autosave_ignore_not_normal = true,
        autosave_ignore_dirs = {},
        autosave_ignore_filetypes = {
          "gitcommit",
          "gitrebase",
          "toggleterm",
        },
        autosave_ignore_buftypes = {},
        autosave_only_in_session = false,
        max_path_length = 80,
      }
      vim.keymap.set(
        "n",
        "<leader>qs",
        "<Cmd>SessionManager load_current_dir_session<CR>",
        { desc = "Restore the session for the current directory" }
      )
      vim.keymap.set(
        "n",
        "<leader>qq",
        "<Cmd>SessionManager load_session<CR>",
        { desc = "Select and restore the session" }
      )
      vim.keymap.set(
        "n",
        "<leader>ql",
        "<Cmd>SessionManager load_last_session<CR>",
        { desc = "Restore the last session" }
      )
      vim.keymap.set(
        "n",
        "<leader>qd",
        "<Cmd>SessionManager delete_session<CR>",
        { desc = "Delete session" }
      )
      local config_group = vim.api.nvim_create_augroup("SessionManagerCustom", {})
      vim.api.nvim_create_autocmd({ "VimEnter" }, {
        pattern = "*",
        callback = function()
          if
            vim.fn.argc() ~= 0 -- git or `nvim ...`.
          then
            return
          end
          vim.g.CWD_initial = vim.fn.getcwd(-1, -1)
        end,
      })
      vim.api.nvim_create_autocmd({ "VimLeavePre" }, {
        group = config_group,
        callback = function()
          if vim.bo.filetype ~= "git" and not vim.bo.filetype ~= "gitcommit" then
            vim.api.nvim_set_current_dir(vim.g.CWD_initial)
            require("session_manager").save_current_session()
          end
        end,
      })
      vim.api.nvim_create_autocmd({ "BufWritePost" }, {
        group = config_group,
        callback = function()
          if vim.bo.filetype ~= "git" and not vim.bo.filetype ~= "gitcommit" then
            vim.g.cwd_bckp = vim.fn.getcwd(-1, -1)
            vim.api.nvim_set_current_dir(vim.g.CWD_initial)
            require("session_manager").save_current_session()
            vim.api.nvim_set_current_dir(vim.g.cwd_bckp)
          end
        end,
      })
    end,
  },
}

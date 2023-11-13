return {
  "natecraddock/sessions.nvim",
  lazy = false,
  config = function()
    require("sessions").setup {
      absolute = true,
      session_filepath = vim.fn.stdpath "data" .. "/sessions",
    }
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
        local session_file, _ = vim.fn.getcwd(-1, -1):gsub("/", "@_@")
        session_file = vim.fn.stdpath "data" .. "/sessions/" .. session_file
        -- require("sessions").load(session_file)
      end,
    })
    vim.api.nvim_create_autocmd({ "VimLeavePre" }, {
      group = config_group,
      callback = function()
        local git_filetypes = {
          "git",
          "gitcommit",
          "gitconfig",
          "gitrebase",
          "gitsendemail",
        }
        local buf_filetype = vim.bo.filetype
        for _, str in ipairs(git_filetypes) do
          if str == buf_filetype then
            return
          end
        end
        HandleCurrentCwdSession "save"
        vim.api.nvim_set_current_dir(vim.g.CWD_initial)
        local session_file, _ = vim.fn.getcwd(-1, -1):gsub("/", "@_@")
        session_file = vim.fn.stdpath "data" .. "/sessions/" .. session_file
        require("sessions").save(session_file)
      end,
    })
    HandleCurrentCwdSession = function(cmd)
      local session_cwd, _ = vim.fn.getcwd(-1, -1)
      local function transform_cwd(cwd)
        if cwd then
          return cwd:gsub("/", "@_@"):gsub(":", "@+@")
        end
      end
      local session_file = vim.fn.stdpath "data" .. "/sessions/" .. transform_cwd(session_cwd)
      if cmd == "load" then
        if vim.fn.filereadable(session_file) == 1 then
          require("sessions").load(session_file)
        end
      elseif cmd == "delete" then
        if vim.fn.filewritable(session_file) == 1 then
          vim.fn.delete(session_file)
        end
      elseif cmd == "save" then
        require("sessions").save(session_file)
        print("Session CWD is: " .. session_cwd)
      end
    end
    vim.keymap.set(
      "n",
      "<leader>ql",
      "<Cmd>lua HandleCurrentCwdSession('load')<CR>",
      { desc = "Load the current CWD session" }
    )
    vim.keymap.set(
      "n",
      "<leader>qs",
      "<Cmd>lua HandleCurrentCwdSession('save')<CR>",
      { desc = "Save the current CWD session" }
    )
    vim.keymap.set(
      "n",
      "<leader>qd",
      "<Cmd>lua HandleCurrentCwdSession('delete')<CR>",
      { desc = "Delete the current CWD session" }
    )
  end,
}

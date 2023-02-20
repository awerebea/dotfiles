return {
  "natecraddock/sessions.nvim",
  lazy = false,
  config = function()
    require("sessions").setup()
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
        if vim.bo.filetype ~= "git" and not vim.bo.filetype ~= "gitcommit" then
          vim.api.nvim_set_current_dir(vim.g.CWD_initial)
          -- require("sessions").save(vim.fn.getcwd(-1, -1):gsub("/", "@_@"))
          local session_file, _ = vim.fn.getcwd(-1, -1):gsub("/", "@_@")
          session_file = vim.fn.stdpath "data" .. "/sessions/" .. session_file
          require("sessions").save(session_file)
        end
      end,
    })
    LoadCurrentCwdSession = function()
      local session_file, _ = vim.fn.getcwd(-1, -1):gsub("/", "@_@"):gsub(":", "@+@")
      session_file = vim.fn.stdpath "data" .. "/sessions/" .. session_file
      if vim.fn.filereadable(session_file) == 1 then
        require("sessions").load(session_file)
      end
    end
    vim.keymap.set(
      "n",
      "<leader>qs",
      "<Cmd> lua LoadCurrentCwdSession()<CR>",
      { desc = "Restore the current CWD session" }
    )
  end,
}

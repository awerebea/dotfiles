return {
  "awerebea/possession.nvim",
  branch = "urlencoded_session_names",
  enabled = true,
  dependencies = {
    { "nvim-lua/plenary.nvim" },
    {
      "tiagovla/scope.nvim",
      config = true,
    },
  },
  lazy = false,
  config = function()
    vim.opt.sessionoptions:remove { "curdir" } -- don't save current directory in session
    --                                            to avoid conflicts with possession plugin
    require("possession").setup {
      session_name_encode = true,
      prompt_no_cr = true, -- don't add a carriage return to the prompt
      autosave = {
        current = true, -- or fun(name): boolean
      },
      plugins = { delete_hidden_buffers = { hooks = {} } },
      telescope = {
        list = {
          default_action = "load",
          mappings = {
            save = { n = "<c-s>", i = "<c-s>" },
            load = { n = "<c-l>", i = "<c-l>" },
            delete = { n = "<c-x>", i = "<c-x>" },
            rename = { n = "<c-r>", i = "<c-r>" },
          },
        },
      },
      -- hooks = {
      --   after_load = function(name, user_data)
      --     -- Delete buffers that are not present on disk
      --     local buffers = vim.api.nvim_list_bufs()
      --     for _, buf in ipairs(buffers) do
      --       local path = vim.api.nvim_buf_get_name(buf)
      --       if vim.fn.filereadable(path) == 0 then
      --         local success, bufdel = pcall(require, "bufdel")
      --         if success then
      --           bufdel.setup()
      --           vim.api.nvim_command("BufDel! " .. buf)
      --         else
      --           vim.api.nvim_buf_delete(buf, { force = true })
      --         end
      --       end
      --     end
      --   end,
      -- },
    }

    local path_delim = require("utils").path_delim()

    local function get_session_file(session_name)
      local session_file = vim.fn.stdpath "data"
        .. path_delim
        .. "possession"
        .. path_delim
        .. session_name
        .. ".json"
      return session_file
    end

    local function close_neo_tree()
      require("neo-tree.sources.manager").close_all()
      vim.notify "closed all"
    end

    local function handle_current_cwd_session(cmd)
      local session_cwd, _ = vim.fn.getcwd(-1, -1)
      local session_file = get_session_file(require("utils").url_encode(session_cwd))
      if cmd == "load" then
        if vim.fn.filereadable(session_file) == 1 then
          require("possession").load(session_cwd)
        end
      elseif cmd == "delete" then
        if vim.fn.filewritable(session_file) == 1 then
          require("possession").delete(session_cwd)
        end
      elseif cmd == "save" then
        -- close_neo_tree()
        -- require("possession").save(session_cwd)
        -- Overwrite without confirmation
        require("possession").save(session_cwd, { no_confirm = true })
        print("Session CWD is: " .. session_cwd)
      end
    end

    local function save_session()
      local session_cwd, _ = vim.fn.getcwd(-1, -1) -- /foo/bar/baz or C:\foo\bar\baz
      local pathsep = package.config:sub(1, 1) -- Returns "\\" on Windows, "/" on Unix-like systems
      local parts = {}
      if session_cwd then
        parts = vim.fn.split(session_cwd, pathsep)
      end
      local last_part = parts[#parts]
      vim.ui.input({ prompt = "Session name: ", default = last_part or "" }, function(session_name)
        if session_name ~= "" then
          -- require("possession").save(session_name)
          -- Overwrite without confirmation
          require("possession").save(session_name, { no_confirm = true })
        end
      end)
    end

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
        -- Load the current CWD session if it exists automatically.
        -- handle_current_cwd_session "load"
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
        handle_current_cwd_session "save"
        vim.api.nvim_set_current_dir(vim.g.CWD_initial)
        local session_cwd, _ = vim.fn.getcwd(-1, -1)
        -- require("possession").save(session_cwd)
        -- Overwrite without confirmation
        require("possession").save(session_cwd, { no_confirm = true })
      end,
    })

    vim.keymap.set("n", "<leader>ql", function()
      require("telescope").extensions.possession.list()
    end, { desc = "List sessions" })
    vim.keymap.set("n", "<leader>fb", function()
      require("telescope").extensions.scope.buffers()
    end, { desc = "Buffers accross all tabs" })
    vim.keymap.set("n", "<leader>qL", function()
      handle_current_cwd_session "load"
    end, { desc = "Load the current CWD session" })
    vim.keymap.set("n", "<leader>qS", function()
      handle_current_cwd_session "save"
    end, { desc = "Save the current CWD session" })
    vim.keymap.set("n", "<leader>qD", function()
      handle_current_cwd_session "delete"
    end, { desc = "Delete the current CWD session" })
    vim.keymap.set("n", "<leader>qs", function()
      save_session()
    end, { desc = "Save session" })

    require("telescope").load_extension "possession"
    require("telescope").load_extension "scope"
  end,
}

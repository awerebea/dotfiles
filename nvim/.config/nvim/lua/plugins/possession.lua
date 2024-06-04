return {
  "awerebea/possession.nvim", -- Temporary switch to fork
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
    -- don't save current directory in session to avoid erros and dead buffers when loading session
    vim.opt.sessionoptions:remove { "curdir" }

    local sep = package.config:sub(1, 1) -- Returns "\\" on Windows, "/" on Unix-like systems

    local path_aliases_file = vim.fn.stdpath "config" .. sep .. "path_aliases.json"

    -- Load custom path aliases
    local path_aliases = {}
    if vim.fn.filereadable(path_aliases_file) == 1 then
      path_aliases = vim.fn.json_decode(vim.fn.readfile(path_aliases_file))
      vim.validate { path_aliases = { path_aliases, "table" } }
    end

    ---@param str string
    ---@return string collapsed path in the home directory
    local function home_to_tilde(str)
      str, _ = string.gsub(str, "^" .. vim.loop.os_homedir(), "~")
      return str
    end

    if next(path_aliases) ~= nil then
      for alias, path in pairs(path_aliases) do
        vim.validate {
          alias = { alias, "string" },
          path = { path, "string" },
        }
        -- normilize paths in home directory
        path = home_to_tilde(path)
        -- remove trailing path separators
        while string.sub(path, -1) == sep do
          path = string.sub(path, 1, -2)
        end
        path_aliases[alias] = path
      end
    end

    -- Function to collapse path to alias
    ---@param path string
    ---@return string name of the session
    local function collapse_path(path)
      -- normilize paths in home directory
      path = home_to_tilde(path)
      local best_alias = ""
      local longest_length = 0

      for alias, alias_path in pairs(path_aliases) do
        local length = string.len(alias_path)
        if string.sub(path, 1, length) == alias_path and length > longest_length then
          best_alias = alias
          longest_length = length
        end
      end

      if best_alias ~= "" then
        -- gsub arguments to escape special characters
        local subst_args = { "([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1" }
        path = string.gsub(
          path,
          "^" .. string.gsub(path_aliases[best_alias], subst_args[1], subst_args[2]),
          best_alias
        )
      end

      return path
    end

    require("possession").setup {
      percent_encode_name = true,
      prompt_no_cr = true, -- don't add a carriage return to the prompt
      autosave = {
        current = true,
        -- tmp = false, -- or fun(): boolean
        tmp = function()
          local ignore_filetypes = {
            "git",
            "gitcommit",
            "gitconfig",
            "gitrebase",
            "gitsendemail",
          }
          local buf_filetype = vim.bo.filetype
          for _, str in ipairs(ignore_filetypes) do
            if str == buf_filetype then
              return false
            end
          end
          return true
        end,
        tmp_name = "autosave_" .. collapse_path(vim.fn.getcwd(-1, -1)),
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
    }

    local function get_session_file(session_name)
      return vim.fn.stdpath "data" .. sep .. "possession" .. sep .. session_name .. ".json"
    end

    local function close_neo_tree()
      require("neo-tree.sources.manager").close_all()
      vim.notify "closed all"
    end

    local function handle_current_cwd_session(cmd, args)
      local session_cwd = vim.fn.getcwd(-1, -1)
      local session_name = collapse_path(session_cwd)
      local session_file = get_session_file(require("utils").url_encode(session_name))
      if cmd == "load" then
        if vim.fn.filereadable(session_file) == 1 then
          require("possession").load(session_name)
        end
      elseif cmd == "delete" then
        if vim.fn.filewritable(session_file) == 1 then
          require("possession").delete(session_name)
        end
      elseif cmd == "save" then
        -- close_neo_tree()
        -- Overwrite without confirmation
        require("possession").save(session_name, args)
      end
    end

    local function save_session(args)
      local session_cwd = vim.fn.getcwd(-1, -1)
      local parts = {}
      if session_cwd then
        parts = vim.fn.split(session_cwd, sep)
      end
      vim.ui.input(
        { prompt = "Session name: ", default = parts[#parts] or "" },
        function(session_name)
          if session_name ~= "" then
            -- Overwrite without confirmation
            require("possession").save(session_name, args)
          end
        end
      )
    end

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
      handle_current_cwd_session("save", { no_confirm = true })
    end, { desc = "Save the current CWD session" })
    vim.keymap.set("n", "<leader>qD", function()
      handle_current_cwd_session "delete"
    end, { desc = "Delete the current CWD session" })
    vim.keymap.set("n", "<leader>qs", function()
      save_session { no_confirm = false }
    end, { desc = "Save session" })
    vim.keymap.set("n", "<leader>qx", function()
      require("possession.session").close()
    end, { desc = "Close current session" })

    require("telescope").load_extension "possession"
    require("telescope").load_extension "scope"
  end,
}

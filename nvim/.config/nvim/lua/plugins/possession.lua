return {
  "jedrzejboczar/possession.nvim", -- Temporary switch to fork
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
    vim.opt.sessionoptions:remove({ "curdir" })

    -- capture launch cwd before any session loading changes the global cwd via :cd
    local launch_cwd = vim.fn.getcwd(-1, -1)

    local sep = package.config:sub(1, 1) -- Returns "\\" on Windows, "/" on Unix-like systems

    local path_aliases_file = vim.fn.stdpath("config") .. sep .. "path_aliases.json"

    -- Load custom path aliases
    local path_aliases = {}
    if vim.fn.filereadable(path_aliases_file) == 1 then
      path_aliases = vim.fn.json_decode(vim.fn.readfile(path_aliases_file))
      vim.validate({ path_aliases = { path_aliases, "table" } })
    end

    ---@param str string
    ---@return string collapsed path in the home directory
    local function home_to_tilde(str)
      str, _ = string.gsub(str, "^" .. vim.uv.os_homedir(), "~")
      return str
    end

    if next(path_aliases) ~= nil then
      for alias, path in pairs(path_aliases) do
        vim.validate({
          alias = { alias, "string" },
          path = { path, "string" },
        })
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

    require("possession").setup({
      prompt_no_cr = true, -- don't add a carriage return to the prompt
      autosave = {
        current = true,
        -- tmp = false, -- or fun(): boolean
        tmp = function()
          local ignore_filetypes = {
            "fyler",
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
        tmp_name = "autosave_" .. collapse_path(launch_cwd),
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
    })

    local function get_session_file(session_name)
      return vim.fn.stdpath("data") .. sep .. "possession" .. sep .. session_name .. ".json"
    end

    local function close_neo_tree()
      require("neo-tree.sources.manager").close_all()
      vim.notify("closed all")
    end

    local function handle_current_cwd_session(cmd, args, use_global_cwd)
      local session_cwd = (use_global_cwd == nil or use_global_cwd) and launch_cwd
        or vim.fn.getcwd(0)
      local session_name = collapse_path(session_cwd)
      local session_file = get_session_file(require("utils").url_encode(session_name))
      -- for load: if no manually-saved session exists, fall back to the autosave for this cwd
      if cmd == "load" and vim.fn.filereadable(session_file) ~= 1 then
        local autosave_name = "autosave_" .. session_name
        local autosave_file = get_session_file(require("utils").url_encode(autosave_name))
        if vim.fn.filereadable(autosave_file) == 1 then
          session_name = autosave_name
          session_file = autosave_file
        end
      end
      if cmd == "load" then
        if vim.fn.filereadable(session_file) == 1 then
          require("possession").load(session_name)
        else
          vim.notify("No session for: " .. session_cwd, vim.log.levels.WARN)
        end
      elseif cmd == "delete" then
        if vim.fn.filewritable(session_file) == 1 then
          require("possession").delete(session_name)
        end
      elseif cmd == "save" then
        -- Overwrite without confirmation
        require("possession").save(session_name, args)
      end
    end

    local function save_session(args, use_global_cwd)
      local session_cwd = use_global_cwd and launch_cwd or vim.fn.getcwd(0)
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

    local function filter_empty(tbl)
      if type(tbl) ~= "table" then
        return tbl
      end
      local result = {}
      for k, v in pairs(tbl) do
        local filtered = filter_empty(v)
        if type(filtered) ~= "table" or next(filtered) ~= nil then
          result[k] = filtered
        end
      end
      return result
    end

    local function possession_picker()
      local possession_dir = vim.fn.stdpath("data") .. sep .. "possession"
      Snacks.picker.pick({
        title = "Sessions",
        finder = function()
          local items = {}
          local files = vim.fn.glob(possession_dir .. sep .. "*.json", false, true)
          for _, filepath in ipairs(files) do
            local stat = vim.uv.fs_stat(filepath)
            local mtime = stat and stat.mtime.sec or 0
            local ok, raw = pcall(vim.fn.readfile, filepath)
            if ok then
              local ok2, data = pcall(vim.fn.json_decode, table.concat(raw, "\n"))
              if ok2 and type(data) == "table" then
                local name = data.name or vim.fn.fnamemodify(filepath, ":t:r")
                local cwd = home_to_tilde(data.cwd or "")
                local buffers = {}
                if type(data.vimscript) == "string" then
                  for line in data.vimscript:gmatch("[^\n]+") do
                    local buf_path = line:match("^badd %+%d+ (.+)$")
                    if buf_path then
                      buffers[#buffers + 1] = home_to_tilde(buf_path)
                    end
                  end
                end
                local preview_lines = {
                  "Name: " .. name,
                  "File: " .. home_to_tilde(filepath),
                  "Cwd:  " .. cwd,
                  "",
                  "Buffers:",
                }
                for _, buf in ipairs(buffers) do
                  preview_lines[#preview_lines + 1] = "  " .. buf
                end
                local plugins = filter_empty(data.plugins)
                if type(plugins) == "table" and next(plugins) ~= nil then
                  preview_lines[#preview_lines + 1] = ""
                  preview_lines[#preview_lines + 1] = "Plugin data:"
                  for line in vim.inspect(plugins):gmatch("[^\n]+") do
                    preview_lines[#preview_lines + 1] = line
                  end
                end
                items[#items + 1] = {
                  text = name,
                  session_name = name,
                  mtime = mtime,
                  date_str = os.date("%b %d %H:%M", mtime),
                  preview = { text = table.concat(preview_lines, "\n") },
                }
              end
            end
          end
          table.sort(items, function(a, b)
            return a.mtime > b.mtime
          end)
          return items
        end,
        format = function(item, _)
          return {
            { item.date_str, "SnacksPickerTime" },
            { " " },
            { item.session_name },
          }
        end,
        preview = "preview",
        confirm = function(picker, item)
          picker:close()
          if item then
            vim.schedule(function()
              local ok, err = pcall(require("possession").load, item.session_name)
              if not ok then
                vim.notify("Session load failed: " .. tostring(err), vim.log.levels.ERROR)
              else
                vim.notify("Session loaded: " .. item.session_name, vim.log.levels.INFO)
              end
            end)
          end
        end,
        actions = {
          session_delete = function(picker, item)
            if item then
              require("possession").delete(item.session_name)
              picker:find()
            end
          end,
          session_save = function(picker, item)
            picker:close()
            if item then
              vim.schedule(function()
                require("possession").save(item.session_name, { no_confirm = true })
              end)
            end
          end,
          session_rename = function(picker, item)
            if not item then
              return
            end
            picker:close()
            vim.schedule(function()
              vim.ui.input(
                { prompt = "Rename session: ", default = item.session_name },
                function(new_name)
                  if new_name and new_name ~= "" and new_name ~= item.session_name then
                    require("possession").save(new_name, { no_confirm = true })
                    require("possession").delete(item.session_name)
                  end
                end
              )
            end)
          end,
        },
        win = {
          input = {
            keys = {
              ["<c-s>"] = { "session_save", mode = { "i", "n" } },
              ["<c-x>"] = { "session_delete", mode = { "i", "n" } },
              ["<c-r>"] = { "session_rename", mode = { "i", "n" } },
            },
          },
        },
      })
    end

    vim.keymap.set("n", "<leader>qa", function()
      possession_picker()
    end, { desc = "All sessions" })
    vim.keymap.set("n", "<leader>ql", function()
      handle_current_cwd_session("load", nil, false)
    end, { desc = "Load session (window-local cwd)" })
    vim.keymap.set("n", "<leader>qL", function()
      handle_current_cwd_session("load", nil, true)
    end, { desc = "Load session (global cwd)" })
    vim.keymap.set("n", "<leader>qS", function()
      save_session({ no_confirm = false }, true)
    end, { desc = "Save session (global cwd)" })
    vim.keymap.set("n", "<leader>qD", function()
      handle_current_cwd_session("delete")
    end, { desc = "Delete the current CWD session" })
    vim.keymap.set("n", "<leader>qs", function()
      save_session({ no_confirm = false }, false)
    end, { desc = "Save session (window-local cwd)" })
    vim.keymap.set("n", "<leader>qx", function()
      require("possession.session").close()
    end, { desc = "Close current session" })
  end,
}

return {
  "DrKJeff16/project.nvim",
  event = "VeryLazy",
  cmd = "Project",
  keys = {
    {
      "<leader>fp",
      function()
        local ext = require("project.extensions.snacks")
        local Util = require("project.util")
        local function open_picker()
          local items = ext.gen_items()
          require("snacks").picker.pick({
            actions = {
              chdir_only = function(self, item)
                self:close()
                require("project.core").set_pwd(item.value, "snacks")
              end,
              -- <C-d>: delete selected (or cursor) projects with a single confirmation
              delete_project = function(self, _)
                local selected = self:selected({ fallback = true })
                self:close()
                local paths = vim.tbl_map(function(item)
                  return vim.fn.expand(item.value)
                end, selected)
                local msg = "Delete " .. #paths .. " project(s) from history?\n\n"
                  .. table.concat(paths, "\n") .. "\n"
                if vim.fn.confirm(msg, "&Yes\n&No", 2) ~= 1 then
                  open_picker()
                  return
                end
                for _, path in ipairs(paths) do
                  Util.history.delete_project(path, false)
                end
                open_picker()
              end,
              rename_project = function(self, item)
                self:close()
                vim.api.nvim_feedkeys("i", "n", false)
                require("project.popup").rename_input(
                  vim.fn.expand(item.value),
                  Util.history.find_entry("recent", item.value, "name")
                )
              end,
            },
            confirm = function(self, item)
              self:close()
              if not require("project.core").set_pwd(vim.fn.expand(item.value), "snacks") then
                return
              end
              require("snacks").picker.files({
                cwd = vim.uv.cwd() or vim.fn.getcwd(),
                show_empty = true,
                hidden = false,
                finder = "files",
                format = "file",
                supports_live = true,
                auto_close = true,
                enter = true,
              })
            end,
            enter = true,
            format = function(item)
              local cfg = ext.config
              local icon = cfg.icon or { icon = " ", highlight = "Directory" }
              for _, pi in pairs(cfg.path_icons or {}) do
                if item.text:find(pi.match) then
                  icon = pi
                  break
                end
              end
              return {
                { icon.icon, icon.highlight },
                { item.text, "Normal" },
              }
            end,
            items = items,
            layout = "select",
            preview = function() return false end,
            show_empty = false,
            title = "Select Project",
            win = {
              input = {
                keys = {
                  ["<C-d>"] = { "delete_project", mode = { "n", "i" }, desc = "Delete selected project(s)" },
                  ["<C-r>"] = { "rename_project", mode = { "n", "i" }, desc = "Rename project" },
                  ["<C-w>"] = { "chdir_only", mode = { "n", "i" }, desc = "Change working directory" },
                },
              },
            },
          })
        end
        open_picker()
      end,
      desc = "Projects",
    },
    {
      "<leader>pr",
      "<Cmd>Project root<CR>",
      desc = "Set CWD to the root of the project",
    },
  },
  opts = {
    manual_mode = true,
    detection_methods = { "pattern", "lsp" },
    patterns = { ".project", ".git" },
    lsp = {},
    show_hidden = true,
    silent_chdir = false,
    scope_chdir = "global",
    history = {
      save_dir = vim.fn.stdpath("data"),
    },
    snacks = {
      enabled = true,
      opts = {
        hidden = false,
        sort = "newest",
        title = "Select Project",
        layout = "select",
        show = "paths",
      },
    },
  },
}

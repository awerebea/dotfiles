return {
  "stevearc/oil.nvim",
  keys = { { "-", "<Cmd>Oil<CR>", desc = "Oil file manager" } },
  cmd = "Oil",
  -- Optional dependencies
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local git_ignored = setmetatable({}, {
      __index = function(self, key)
        local proc = vim.system(
          { "git", "ls-files", "--ignored", "--exclude-standard", "--others", "--directory" },
          {
            cwd = key,
            text = true,
          }
        )
        local result = proc:wait()
        local ret = {}
        if result.code == 0 then
          for line in vim.gsplit(result.stdout, "\n", { plain = true, trimempty = true }) do
            -- Remove trailing slash
            line = line:gsub("/$", "")
            table.insert(ret, line)
          end
        end

        rawset(self, key, ret)
        return ret
      end,
    })

    require("oil").setup {
      default_file_explorer = false,
      skip_confirm_for_simple_edits = true,
      prompt_save_on_select_new_entry = false,
      view_options = {
        is_hidden_file = function(name, _)
          -- dotfiles are not considered hidden
          if vim.startswith(name, ".") then
            return false
          end
          local dir = require("oil").get_current_dir()
          -- if no local directory (e.g. for ssh connections), always show
          if not dir then
            return false
          end
          -- Check if file is gitignored
          return vim.list_contains(git_ignored[dir], name)
        end,
      },
      -- Prevent buffer conflicts with NvimTree
      buf_options = {
        buflisted = false,
      },
    }
  end,
}

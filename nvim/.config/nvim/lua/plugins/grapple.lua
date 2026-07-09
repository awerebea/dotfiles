return {
  "cbochs/grapple.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  cmd = "Grapple",

  -- Lazy-load on first keymap press or command.
  keys = (function()
    local k = {
      {
        "<leader>m",
        function()
          local grapple = require("grapple")
          if grapple.exists() then
            if vim.fn.confirm("Remove grapple tag?", "&Yes\n&No", 2) == 1 then
              grapple.untag()
            end
          else
            vim.ui.input({ prompt = "Tag name (optional): " }, function(name)
              if name == nil then
                return
              end
              grapple.tag({ name = name ~= "" and name or nil })
            end)
          end
        end,
        desc = "Grapple tag toggle",
      },
      {
        "<leader><leader>m",
        function()
          local grapple = require("grapple")
          local tags = grapple.tags() or {}

          -- Resolve scope root to compute the relative display path length.
          local scope_root = vim.fn.getcwd()
          pcall(function()
            local scope, err = require("grapple.app").get():resolve_scope({})
            if scope and not err then
              scope_root = scope.path
            end
          end)

          local max_len = 0
          for _, tag in ipairs(tags) do
            local path = tag.path or ""
            -- Strip scope root to match grapple's style="relative" rendering.
            if path:sub(1, #scope_root + 1) == scope_root .. "/" then
              path = path:sub(#scope_root + 2)
            end
            -- Include tag name width if the tag is named.
            local name_extra = tag.name and (#tag.name + 2) or 0
            local w = #path + name_extra
            if w > max_len then
              max_len = w
            end
          end

          -- Overhead: "/001" (4) + icon (2) + spaces (3) + border (2) = ~12.
          local min_w = 40
          local max_w = math.floor(vim.o.columns * 0.9)
          local width = math.max(min_w, math.min(max_w, max_len + 12))

          require("grapple.app").get().settings.inner.win_opts.width = width
          grapple.toggle_tags()
        end,
        desc = "Grapple tags",
      },
      {
        "[g",
        function()
          require("grapple").cycle_tags("prev")
        end,
        desc = "Prev grapple tag",
      },
      {
        "]g",
        function()
          require("grapple").cycle_tags("next")
        end,
        desc = "Next grapple tag",
      },
    }
    -- <leader><leader>1-9 jump to tags 1-9; <leader><leader>0 jumps to tag 10.
    for i = 1, 9 do
      table.insert(k, {
        "<leader><leader>" .. i,
        function()
          require("grapple").select({ index = i })
        end,
        desc = "Grapple tag " .. i,
      })
    end
    table.insert(k, {
      "<leader><leader>0",
      function()
        require("grapple").select({ index = 10 })
      end,
      desc = "Grapple tag 10",
    })
    return k
  end)(),

  opts = {
    -- Tags are namespaced per git repo. Switching repos gives you a fresh list.
    scope = "git",

    -- Show file paths relative to the git root (cleaner than absolute).
    style = "relative",

    -- Show the tag name (if set via R in the window) after the path.
    name_pos = "end",

    -- Press 1-9 or 0 (slot 10) inside the tags window to jump instantly.
    quick_select = "1234567890",

    -- Requires nvim-web-devicons (already a dep above).
    icons = true,

    -- Remove save files older than 30 days automatically.
    prune = "30d",

    win_opts = {
      -- Width is overridden dynamically on each open; this is only the fallback.
      width = 80,
      height = 12,
      border = "rounded",
    },
  },
}

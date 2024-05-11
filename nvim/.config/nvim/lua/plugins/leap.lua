return {
  {
    "ggandor/leap.nvim",
    enabled = true,
    keys = {
      { "s", mode = { "n", "x", "o" }, desc = "Leap (bidirectional)" },
      { "gs", mode = { "n", "x", "o" }, desc = "Leap from Windows" },
      { "|", mode = { "n", "x", "o" }, desc = "Leap to line start" },
    },
    opts = {
      -- safe_labels = {}, -- Set to {} to disable auto-jumping to first match

      -- Define equivalence classes for brackets and quotes, in addition to
      -- the default whitespace group.
      equivalence_classes = { " \t\r\n", "([{", ")]}", "'\"`" },
    },
    config = function(_, opts)
      local leap = require "leap"
      for k, v in pairs(opts) do
        leap.opts[k] = v
      end
      vim.api.nvim_set_hl(0, "LeapBackdrop", { link = "Comment" })
      vim.keymap.set({ "n", "x", "o" }, "s", "<Plug>(leap)")
      vim.keymap.set({ "n", "x", "o" }, "gs", "<Plug>(leap-from-window)")

      -- Linewise motions
      local function get_line_starts(winid, skip_range, is_upward)
        local wininfo = vim.fn.getwininfo(winid)[1]
        local cur_line = vim.fn.line "."
        -- Skip lines close to the cursor.
        local skip_range = skip_range or 2
        local is_directional = is_upward ~= nil and true or false

        -- Get targets.
        local targets = {}
        local lnum = wininfo.topline
        while lnum <= wininfo.botline do
          local fold_end = vim.fn.foldclosedend(lnum)
          -- Skip folded ranges.
          if fold_end ~= -1 then
            lnum = fold_end + 1
          else
            if is_directional then
              if is_upward and lnum > cur_line - skip_range then
                break
              elseif not is_upward and lnum < cur_line + skip_range then
                goto continue
              end
            end
            if (lnum < cur_line - skip_range) or (lnum > cur_line + skip_range) then
              table.insert(targets, { pos = { lnum, 1 } })
            end
            ::continue::
            lnum = lnum + 1
          end
        end

        -- Sort them by vertical screen distance from cursor.
        local cur_screen_row = vim.fn.screenpos(winid, cur_line, 1)["row"]
        local function screen_rows_from_cur(t)
          local t_screen_row = vim.fn.screenpos(winid, t.pos[1], t.pos[2])["row"]
          return math.abs(cur_screen_row - t_screen_row)
        end
        table.sort(targets, function(t1, t2)
          return screen_rows_from_cur(t1) < screen_rows_from_cur(t2)
        end)

        if #targets >= 1 then
          return targets
        end
      end

      -- You can pass an argument to specify a range to be skipped
      -- before/after the cursor (default is +/-2).
      function leap_line_start(skip_range, is_upward)
        local winid = vim.api.nvim_get_current_win()
        require("leap").leap {
          target_windows = { winid },
          targets = get_line_starts(winid, skip_range, is_upward),
        }
      end

      -- For maximum comfort, force linewise selection in the mappings:
      vim.keymap.set("x", "|", function()
        -- Only force V if not already in it (otherwise it would exit Visual mode).
        if vim.fn.mode(1) ~= "V" then
          vim.cmd "normal! V"
        end
        leap_line_start()
      end, { desc = "Leap to line start" })
      vim.keymap.set("o", "|", "V<cmd>lua leap_line_start()<cr>", { desc = "Leap to line start" })
      vim.keymap.set("n", "|", function()
        leap_line_start()
      end, { desc = "Leap to line start upwards" })
      vim.keymap.set("n", "<leader><leader>j", function()
        leap_line_start(2, false)
      end, { desc = "Leap to line start downwards" })
      vim.keymap.set("n", "<leader><leader>k", function()
        leap_line_start(2, true)
      end, { desc = "Leap to line start upwards" })
    end,
  },
  {
    "ggandor/flit.nvim",
    enabled = false,
    keys = function()
      local ret = {}
      for _, key in ipairs { "f", "F", "t", "T" } do
        ret[#ret + 1] = { key, mode = { "n", "x", "o" }, desc = key }
      end
      return ret
    end,
    opts = { labeled_modes = "nx" },
  },
}

return {
  {
    "ggandor/leap.nvim",
    enabled = true,
    keys = function()
      local ret = {}
      for key, desc in pairs {
        ["<leader><leader>J"] = "Leap to line start downwards",
        ["<leader><leader>K"] = "Leap to line start upwards",
        ["<leader><leader>j"] = "Leap downwards",
        ["<leader><leader>k"] = "Leap upwards",
      } do
        ret[#ret + 1] = { key, mode = { "n", "x", "o" }, desc = desc }
      end
      ret[#ret + 1] = { "s", mode = { "n", "x", "o" }, desc = "Leap (bidirectional)" }
      ret[#ret + 1] = { "gs", mode = { "n", "x", "o" }, desc = "Leap from Windows" }
      ret[#ret + 1] = { "|", mode = { "n", "x", "o" }, desc = "Leap to line start" }
      return ret
    end,
    opts = {
      -- safe_labels = {}, -- Set to {} to disable auto-jumping to first match

      -- Define equivalence classes for brackets and quotes, in addition to
      -- the default whitespace group.
      equivalence_classes = { " \t\r\n", "([{", ")]}", "'\"`" },
      special_keys = {
        next_target = "<tab>",
        prev_target = nil,
      },
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
      local function get_line_len(bufid, line_number)
        local line_content =
          vim.api.nvim_buf_get_lines(bufid, line_number - 1, line_number, false)[1]
        return string.len(line_content)
      end

      local function get_line_targets(winid, skip_range, is_upward, keep_column)
        local wininfo = vim.fn.getwininfo(winid)[1]
        local bufid = vim.api.nvim_win_get_buf(winid)
        local cur_line = vim.fn.line "."
        local cur_col = vim.fn.col "."
        -- Skip lines close to the cursor.
        local skip_range = skip_range or 2
        local keep_column = keep_column or false
        local is_directional = is_upward ~= nil and true or false

        -- Get targets.
        local targets = {}
        local lnum = wininfo.topline
        local cnum = 1
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
            if keep_column then
              cnum = math.max(1, math.min(cur_col, get_line_len(bufid, lnum)))
            end
            if (lnum < cur_line - skip_range) or (lnum > cur_line + skip_range) then
              table.insert(targets, { pos = { lnum, cnum } })
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

      -- You can pass a table of arguments to specify the jump behavior:
      -- skip_range - range to be skipped before/after the cursor (default is +/-2)
      -- is_upward - set the jump direction, true - up, false - down (default nil - bidirectional)
      -- keep_column - whether to try to keep the column after the jump (default false)
      local function leap_vertically(args)
        local args = args or {}
        local skip_range = args.skip_range
        local is_upward = args.is_upward
        local keep_column = args.keep_column
        local winid = vim.api.nvim_get_current_win()
        require("leap").leap {
          target_windows = { winid },
          targets = get_line_targets(winid, skip_range, is_upward, keep_column),
        }
      end

      -- For maximum comfort, force linewise selection in the mappings:
      for key, args in pairs {
        ["|"] = { { keep_column = true }, { desc = "Leap vertically" } },
        ["<leader><leader>J"] = {
          { is_upward = false },
          { desc = "Leap to line start downwards" },
        },
        ["<leader><leader>K"] = {
          { is_upward = true },
          { desc = "Leap to line start upwards" },
        },
        ["<leader><leader>j"] = {
          { is_upward = false, keep_column = true },
          { desc = "Leap downwards" },
        },
        ["<leader><leader>k"] = {
          { is_upward = true, keep_column = true },
          { desc = "Leap upwards" },
        },
      } do
        for mode, rhs_expr in pairs {
          n = function()
            leap_vertically(args[1])
          end,
          x = function()
            -- Only force V if not already in it (otherwise it would exit Visual mode).
            if vim.fn.mode(1) ~= "V" then
              vim.cmd "normal! V"
            end
            leap_vertically(args[1])
          end,
          o = "V<Cmd>lua leap_vertically(" .. require("utils")
            .serialize_table(args[1])
            :gsub("\n", "") .. ")<CR>",
        } do
          vim.keymap.set(mode, key, rhs_expr, args[2])
        end
      end
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

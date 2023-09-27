return {
  {
    "ggandor/leap.nvim",
    event = "VimEnter",
    keys = {
      { "<leader><leader>j", "nxo" },
      { "<leader><leader>k", "nxo" },
    },
    dependencies = { "tpope/vim-repeat" },
    config = function()
      require("leap").add_default_mappings()
      require("leap").add_repeat_mappings(";", ",", { relative_directions = true })

      local function get_line_starts(winid, skip_range)
        local wininfo = vim.fn.getwininfo(winid)[1]
        local cur_line = vim.fn.line "." or 0
        -- Skip lines close to the cursor.
        skip_range = skip_range or 2

        -- Get targets.
        local targets = {}
        local lnum = wininfo.topline
        while lnum <= wininfo.botline do
          local fold_end = vim.fn.foldclosedend(lnum)
          -- Skip folded ranges.
          if fold_end ~= -1 then
            lnum = fold_end + 1
          else
            if (lnum < cur_line - skip_range) or (lnum > cur_line + skip_range) then
              table.insert(targets, { pos = { lnum, 1 } })
            end
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
      function Leap_linewise(skip_range)
        local winid = vim.api.nvim_get_current_win()
        require("leap").leap {
          target_windows = { winid },
          targets = get_line_starts(winid, skip_range),
        }
      end

      -- For maximum comfort, make sure to set the mappings in a way that
      -- forces linewise selection:
      vim.keymap.set("x", "<leader><leader>j", function()
        return (vim.fn.mode(1) == "V" and "" or "V") .. "<Cmd>lua Leap_linewise()<CR>"
      end, { expr = true })
      vim.keymap.set("x", "<leader><leader>k", function()
        return (vim.fn.mode(1) == "V" and "" or "V") .. "<Cmd>lua Leap_linewise()<CR>"
      end, { expr = true })
      vim.keymap.set("o", "<leader><leader>j", "V<Cmd>lua Leap_linewise()<CR>")
      vim.keymap.set("o", "<leader><leader>k", "V<Cmd>lua Leap_linewise()<CR>")
      vim.keymap.set("n", "<leader><leader>j", "<Cmd>lua Leap_linewise()<CR>")
      vim.keymap.set("n", "<leader><leader>k", "<Cmd>lua Leap_linewise()<CR>")
    end,
  },
  {
    "ggandor/flit.nvim",
    event = "VeryLazy",
    dependencies = { "ggandor/leap.nvim", "tpope/vim-repeat" },
    opts = {
      keys = { f = "f", F = "F", t = "t", T = "T" },
      labeled_modes = "nvo",
      multiline = true,
    },
    config = true,
  },
}

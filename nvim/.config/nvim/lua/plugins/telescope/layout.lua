-- Custom telescope layout using native nvim_open_win borders.
-- Bypasses plenary's text-based border system which is broken in Neovim 0.13.
local Layout = require("telescope.pickers.layout")

local function get_line_count()
  local n = vim.o.lines - vim.o.cmdheight
  if vim.o.laststatus ~= 0 then
    n = n - 1
  end
  return n
end

-- Convert telescope borderchars { top, right, bot, left, topleft, topright, botright, botleft }
-- to nvim_open_win border { topleft, top, topright, right, botright, bot, botleft, left }
local function to_nvim_border(bc)
  if not bc or type(bc) ~= "table" or #bc < 8 then
    return "single"
  end
  return { bc[5], bc[1], bc[6], bc[2], bc[7], bc[3], bc[8], bc[4] }
end

local function make_win(enter, opts, hl_normal, hl_border, hl_title, border)
  local bufnr = vim.api.nvim_create_buf(false, true)
  local win_opts = {
    style = "minimal",
    relative = "editor",
    width = opts.width,
    height = opts.height,
    row = opts.line - 2, -- opts.line is 1-indexed content row; border corner is 1 above that
    col = opts.col - 2, -- opts.col is 1-indexed content col; border corner is 1 to the left
    border = border,
    zindex = 100,
    focusable = opts.focusable,
  }
  if type(opts.title) == "string" and opts.title ~= "" then
    win_opts.title = " " .. opts.title .. " "
    win_opts.title_pos = "center"
  end
  local winid = vim.api.nvim_open_win(bufnr, enter, win_opts)

  vim.wo[winid].winhighlight = table.concat({
    "Normal:" .. hl_normal,
    "FloatBorder:" .. hl_border,
    "FloatTitle:" .. hl_title,
    "EndOfBuffer:" .. hl_normal,
  }, ",")

  return Layout.Window({
    bufnr = bufnr,
    winid = winid,
    border = {
      change_title = function(_, title, _pos)
        if vim.api.nvim_win_is_valid(winid) and type(title) == "string" then
          vim.api.nvim_win_set_config(winid, { title = " " .. title .. " " })
        end
      end,
    },
  })
end

local function destroy_win(win)
  if not win then
    return
  end
  if win.winid and vim.api.nvim_win_is_valid(win.winid) then
    vim.api.nvim_win_close(win.winid, true)
  end
  if win.bufnr and vim.api.nvim_buf_is_valid(win.bufnr) then
    vim.api.nvim_buf_delete(win.bufnr, { force = true })
  end
end

local function get_border()
  local bc = require("telescope.config").values.borderchars
  if type(bc) == "table" then
    if type(bc[1]) == "string" then
      return to_nvim_border(bc)
    elseif type(bc.results) == "table" and type(bc.results[1]) == "string" then
      return to_nvim_border(bc.results)
    end
  end
  return "single"
end

return function(picker)
  local border = get_border()

  return Layout({
    picker = picker,

    mount = function(self)
      local o = picker:get_window_options(vim.o.columns, get_line_count())

      self.results = make_win(
        false,
        o.results,
        "TelescopeResultsNormal",
        "TelescopeResultsBorder",
        "TelescopeResultsTitle",
        border
      )

      if o.preview then
        self.preview = make_win(
          false,
          o.preview,
          "TelescopePreviewNormal",
          "TelescopePreviewBorder",
          "TelescopePreviewTitle",
          border
        )
      end

      self.prompt = make_win(
        true,
        o.prompt,
        "TelescopePromptNormal",
        "TelescopePromptBorder",
        "TelescopePromptTitle",
        border
      )
    end,

    unmount = function(self)
      destroy_win(self.results)
      destroy_win(self.preview)
      destroy_win(self.prompt)
    end,

    update = function(self)
      local o = picker:get_window_options(vim.o.columns, get_line_count())

      local function reposition(win, opts)
        if win and opts and vim.api.nvim_win_is_valid(win.winid) then
          vim.api.nvim_win_set_config(win.winid, {
            width = opts.width,
            height = opts.height,
            row = opts.line - 2,
            col = opts.col - 2,
          })
        end
      end

      reposition(self.results, o.results)
      reposition(self.preview, o.preview)
      reposition(self.prompt, o.prompt)
    end,
  })
end

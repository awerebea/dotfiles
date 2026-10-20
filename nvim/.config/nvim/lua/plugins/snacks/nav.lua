-- Window navigation out of snacks picker layouts (the explorer sidebar).
-- A picker's windows are floats placed inside one split window (the layout
-- root). smart-splits cannot navigate from them: it measures a float's
-- distance to the screen edge from the float's own position, which here is
-- relative to the layout root, not to the screen. So find the neighbor from
-- the root, and at the screen edge do what smart-splits would do there.
local M = {}

local directions = { h = "left", j = "down", k = "up", l = "right" }
local opposite = { h = "l", j = "k", k = "j", l = "h" }

---Move to the window next to the picker's layout in direction `dir`.
---@param picker snacks.Picker
---@param dir "h"|"j"|"k"|"l"
function M.leave(picker, dir)
  local root = picker.layout.root.win
  if not (root and vim.api.nvim_win_is_valid(root)) then
    return
  end
  local function win_from_root(key)
    return vim.api.nvim_win_call(root, function()
      return vim.fn.win_getid(vim.fn.winnr(key))
    end)
  end

  local target = win_from_root(dir)
  if target ~= 0 and target ~= root then
    vim.api.nvim_set_current_win(target)
    return
  end

  -- At the edge of Neovim's layout: the multiplexer pane in that direction
  -- (tmux), otherwise smart-splits' `move.at_edge` behavior
  local at_edge = require("smart-splits.config").move.at_edge
  local mux_opts = { at_edge = type(at_edge) == "string" and at_edge or nil }
  if require("smart-splits.backend").move(directions[dir], mux_opts) then
    return
  end
  if at_edge == "wrap" then
    target = win_from_root("999" .. opposite[dir])
    if target ~= 0 and target ~= root then
      vim.api.nvim_set_current_win(target)
    end
  end
end

return M

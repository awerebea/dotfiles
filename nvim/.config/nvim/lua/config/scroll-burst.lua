-- Make holding a motion key (j, k, <C-d>, ...) cheap to redraw.
--
-- While a motion key auto-repeats:
--   * j/k presses in Normal mode are not executed one by one: they are
--     counted and applied as a single `{count}gj` / `{count}gk` every
--     `frame_ms`, so Neovim draws one frame per interval instead of one per
--     key repeat, and the terminal never builds up a backlog of frames to
--     replay after the key is released;
--   * floating windows drawn over the buffer (incline, treesitter-context)
--     are hidden: any float covering a window makes Neovim repaint the whole
--     window on every scroll instead of sending one terminal scroll command;
--   * CursorMoved autocmds are paused, so plugins that react to every move
--     (illuminate, render-markdown anti-conceal, ...) do not repaint parts of
--     the screen per frame. Plugins that also react to WinScrolled can ask
--     `M.active()` to skip work (see the deadcolumn spec).
-- Once the key is released the remaining moves are applied, everything is
-- restored and CursorMoved fires once for the final cursor position.

local M = {}

-- Keys whose auto-repeat starts a burst (as typed, before mappings)
local motion_keys = {}
for _, k in ipairs({ "j", "k", "<Down>", "<Up>", "<C-d>", "<C-u>", "<C-e>", "<C-y>", "<C-f>", "<C-b>" }) do
  motion_keys[vim.keycode(k)] = true
end
-- Motions batched through M.motion() (used by the j/k mappings)
local batched = { j = 1, k = -1 }

local repeat_ms = 100 -- same key again within this time => auto-repeat
-- No motion key for this long => burst is over. Pending moves are applied
-- every frame anyway, so this only delays restoring floats and CursorMoved.
-- The timer restarts on every j/k Neovim reads, so it must exceed the longest
-- gap between two reads while the key is held: the key repeat interval, or a
-- slow frame (flush + redraw), during which queued keys wait unread. If it is
-- shorter, the burst ends and restarts mid-hold, costing two full repaints.
-- It does not depend on frame_ms: batched j/k presses are read between frames.
local settle_ms = 300
local frame_ms = 100 -- apply accumulated j/k moves this often while held
-- WinScrolled stays enabled so render-markdown keeps rendering lines that
-- scroll into view
local paused_events = { "CursorMoved" }

local settle_timer = assert(vim.uv.new_timer())
local frame_timer = assert(vim.uv.new_timer())
local last_key, last_time = nil, 0
local active = false
local pending = 0 -- accumulated screen lines to move, > 0 down, < 0 up
local saved_eventignore
local restore_floats = {}

-- Float plugins that can be switched off for the duration of a burst
local floats = {
  {
    mod = "incline",
    is_on = function(m) return m.is_enabled() end,
    off = function(m) m.disable() end,
    on = function(m) m.enable() end,
  },
  {
    mod = "treesitter-context",
    is_on = function(m) return m.enabled() end,
    off = function(m) m.disable() end,
    on = function(m) m.enable() end,
  },
}

local flushing = false

---Apply the accumulated moves now.
local function flush()
  if pending == 0 then
    return
  end
  local cmd = math.abs(pending) .. (pending > 0 and "gj" or "gk")
  pending = 0
  -- :normal passes its keys through on_key as typed; don't treat them as input
  flushing = true
  pcall(vim.cmd.normal, { cmd, bang = true })
  flushing = false
end

local function finish()
  if not active then
    return
  end
  active = false
  settle_timer:stop()
  frame_timer:stop()
  flush()
  vim.o.eventignore = saved_eventignore
  for _, restore in ipairs(restore_floats) do
    pcall(restore)
  end
  restore_floats = {}
  -- Let plugins catch up with the final position once
  local win = vim.api.nvim_get_current_win()
  for _, ev in ipairs(paused_events) do
    pcall(vim.api.nvim_exec_autocmds, ev, { pattern = tostring(win), modeline = false })
  end
end

local function start()
  active = true
  saved_eventignore = vim.o.eventignore
  local ignore = vim.split(saved_eventignore, ",", { trimempty = true })
  vim.list_extend(ignore, paused_events)
  vim.o.eventignore = table.concat(ignore, ",")
  frame_timer:start(frame_ms, frame_ms, vim.schedule_wrap(flush))
  -- start() can run inside the j/k expr mapping, where textlock forbids
  -- closing windows, so hide the floats right after it
  vim.schedule(function()
    if not active then
      return
    end
    for _, f in ipairs(floats) do
      -- only touch plugins that are already loaded, never load one here
      local m = package.loaded[f.mod]
      if m and f.is_on(m) and pcall(f.off, m) then
        table.insert(restore_floats, function() f.on(m) end)
      end
    end
  end)
end

---Register a motion key press: start a burst on auto-repeat, extend it.
---@param key string
local function note_motion(key)
  local now = vim.uv.now()
  if not active and key == last_key and now - last_time < repeat_ms then
    start()
  end
  last_key, last_time = key, now
  if active then
    settle_timer:stop()
    settle_timer:start(settle_ms, 0, vim.schedule_wrap(finish))
  end
end

---Expr mapping for j/k: wrap-aware move, batched while the key is held.
---@param key "j"|"k"
---@return string
function M.motion(key)
  if vim.v.count > 0 then
    return key -- counted jumps move by real lines, as before
  end
  local mode = vim.api.nvim_get_mode().mode
  if mode == "n" then
    note_motion(key)
    if active then
      pending = pending + batched[key]
      return ""
    end
  elseif mode == "v" or mode == "V" or mode == "\22" then
    note_motion(key)
  end
  return "g" .. key
end

local function on_key(_, typed)
  if flushing or typed == nil or typed == "" then
    return
  end
  if batched[typed] then
    return -- handled by M.motion()
  end
  local mode = vim.api.nvim_get_mode().mode
  -- exact modes only: "no" (operator-pending) must not count `d<C-d>` and alike
  local motion_mode = mode == "n" or mode == "v" or mode == "V" or mode == "\22"
  if motion_keys[typed] and motion_mode then
    note_motion(typed)
    return
  end
  last_key = nil
  if active then
    -- Runs before `typed` is executed, so it acts on the final position
    finish()
  end
end

---@return boolean whether a motion key is being held right now
function M.active()
  return active
end

function M.setup()
  vim.on_key(on_key, vim.api.nvim_create_namespace("scroll_burst"))
end

return M

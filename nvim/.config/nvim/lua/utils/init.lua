local M = {}

local function default_on_open(term)
  vim.cmd "stopinsert"
  vim.api.nvim_buf_set_keymap(
    term.bufnr,
    "n",
    "q",
    "<cmd>close<CR>",
    { noremap = true, silent = true }
  )
end

function M.open_term(cmd, opts)
  opts = opts or {}
  opts.size = opts.size or vim.o.columns * 0.5
  opts.direction = opts.direction or "float"
  opts.on_open = opts.on_open or default_on_open
  opts.on_exit = opts.on_exit or nil
  opts.dir = opts.dir or "git_dir"

  local Terminal = require("toggleterm.terminal").Terminal
  local new_term = Terminal:new {
    cmd = cmd,
    dir = opts.dir,
    auto_scroll = false,
    close_on_exit = false,
    start_in_insert = true,
    on_open = opts.on_open,
    on_exit = opts.on_exit,
  }
  new_term:open(opts.size, opts.direction)
end

-- Returns true if current directory is a git worktree
function M.is_git_worktree()
  local _, ret, _ = require("telescope.utils").get_os_command_output {
    "git",
    "rev-parse",
    "--is-inside-work-tree",
  }
  if ret == 0 then
    return true
  end
  return false
end

function M.git_diff_picker(opts)
  opts = opts or require("telescope.themes").get_dropdown {}
  local pickers = require "telescope.pickers"
  local finders = require "telescope.finders"
  local conf = require("telescope.config").values
  local list = nil

  if M.is_git_worktree() then
    list = vim.fn.systemlist "git diff --name-only"
  else
    print "Not a git worktree."
    return
  end

  local git_path = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
  if git_path ~= nil and list ~= nil then
    for k, v in pairs(list) do
      list[k] = git_path .. "/" .. v
    end
  end

  pickers
    .new(opts, {
      prompt_title = "Git Diff Files",
      finder = finders.new_table { results = list },
      sorter = conf.generic_sorter(opts),
    })
    :find()
end

-- Delete the current file
function M.delete_current_file()
  local current_buffer = vim.fn.bufnr "%" -- Get the buffer number of the current buffer
  local current_file = vim.fn.expand "%:p" -- Get the full path of the current file

  -- Close the buffer associated with the current file
  local success, bufdel = pcall(require, "bufdel")
  if success then
    bufdel.setup()
    vim.api.nvim_command "BufDel!" -- Delete buffer with nvim-bufdel
  else
    vim.api.nvim_command(current_buffer .. "bdel") -- Buffer deletion command
  end

  -- Delete the file
  vim.fn.delete(current_file) -- Delete the file
  vim.api.nvim_out_write("Deleted file: " .. current_file .. "\n") -- Optional: Display a message
end

-- Switch to the recent project
function M.switch_project()
  local contents = require("project_nvim").get_recent_projects()
  local reverse = {}
  for i = #contents, 1, -1 do
    reverse[#reverse + 1] = contents[i]
  end
  require("fzf-lua").fzf_exec(reverse, {
    actions = {
      ["default"] = function(e)
        vim.cmd.cd(e[1])
      end,
      ["ctrl-d"] = function(x)
        local choice = vim.fn.confirm("Delete '" .. #x .. "' projects? ", "&Yes\n&No", 2)
        if choice == 1 then
          local history = require "project_nvim.utils.history"
          for _, v in ipairs(x) do
            history.delete_project(v)
          end
        end
      end,
    },
  })
end

function M.is_windows()
  return vim.fn.has "win32" == 1 or vim.fn.has "win64" == 1
end

function M.path_separator()
  return M.is_windows() and "\\" or "/"
end

-- URL encode/decode
function M.url_encode(str)
  if type(str) == "string" then
    str = string.gsub(str, "\n", "\r\n")
    str = string.gsub(str, "([^%w %%%+%-%_%.])", function(c)
      return string.format("%%%02X", string.byte(c))
    end)
    str = string.gsub(str, " ", "+")
  end
  return str
end

function M.url_decode(str)
  if type(str) == "string" then
    str = string.gsub(str, "+", " ")
    str = string.gsub(str, "%%(%x%x)", function(h)
      return string.char(tonumber(h, 16))
    end)
    str = string.gsub(str, "\r\n", "\n")
  end
  return str
end

-- ref: https://stackoverflow.com/a/6081639/14110650
function M.serialize_table(val, name, skipnewlines, depth)
  skipnewlines = skipnewlines or false
  depth = depth or 0

  local tmp = string.rep(" ", depth)

  if name then
    tmp = tmp .. name .. " = "
  end

  if type(val) == "table" then
    tmp = tmp .. "{" .. (not skipnewlines and "\n" or "")

    for k, v in pairs(val) do
      tmp = tmp
        .. M.serialize_table(v, k, skipnewlines, depth + 1)
        .. ","
        .. (not skipnewlines and "\n" or "")
    end

    tmp = tmp .. string.rep(" ", depth) .. "}"
  elseif type(val) == "number" then
    tmp = tmp .. tostring(val)
  elseif type(val) == "string" then
    tmp = tmp .. string.format("%q", val)
  elseif type(val) == "boolean" then
    tmp = tmp .. (val and "true" or "false")
  else
    tmp = tmp .. '"[inserializeable datatype:' .. type(val) .. ']"'
  end

  return tmp
end

--- Return the visually selected text as an array with an entry for each line
---
--- @return string[]|nil lines The selected text as an array of lines.
function M.get_visual_selection_text()
  local _, srow, scol = unpack(vim.fn.getpos "v")
  local _, erow, ecol = unpack(vim.fn.getpos ".")

  -- visual line mode
  if vim.fn.mode() == "V" then
    if srow > erow then
      return vim.api.nvim_buf_get_lines(0, erow - 1, srow, true)
    else
      return vim.api.nvim_buf_get_lines(0, srow - 1, erow, true)
    end
  end

  -- regular visual mode
  if vim.fn.mode() == "v" then
    if srow < erow or (srow == erow and scol <= ecol) then
      return vim.api.nvim_buf_get_text(0, srow - 1, scol - 1, erow - 1, ecol, {})
    else
      return vim.api.nvim_buf_get_text(0, erow - 1, ecol - 1, srow - 1, scol, {})
    end
  end

  -- visual block mode
  if vim.fn.mode() == "\22" then
    local lines = {}
    if srow > erow then
      srow, erow = erow, srow
    end
    if scol > ecol then
      scol, ecol = ecol, scol
    end
    for i = srow, erow do
      table.insert(
        lines,
        vim.api.nvim_buf_get_text(
          0,
          i - 1,
          math.min(scol - 1, ecol),
          i - 1,
          math.max(scol - 1, ecol),
          {}
        )[1]
      )
    end
    return lines
  end
end
return M

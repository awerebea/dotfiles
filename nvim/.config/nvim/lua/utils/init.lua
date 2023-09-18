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

return M

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

function M.git_diff_picker(opts)
  opts = opts or require("telescope.themes").get_dropdown {}
  local pickers = require "telescope.pickers"
  local finders = require "telescope.finders"
  local conf = require("telescope.config").values
  local list = vim.fn.systemlist "git diff --name-only"

  pickers
    .new(opts, {
      prompt_title = "Git Diff Files",
      finder = finders.new_table { results = list },
      sorter = conf.generic_sorter(opts),
      attach_mappings = function()
        vim.api.nvim_set_current_dir(vim.fn.systemlist("git rev-parse --show-toplevel")[1])
        return true
      end,
    })
    :find()
end

return M

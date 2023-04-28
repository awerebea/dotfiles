local aucmd_dict = {
  -- See `:help vim.highlight.on_yank()`
  TextYankPost = {
    {
      callback = function()
        vim.highlight.on_yank { timeout = 250 }
      end,
      group = vim.api.nvim_create_augroup("YankHighlight", { clear = true }),
      pattern = "*",
    },
  },
  -- Check if we need to reload the file when it changed
  FocusGained = { { command = "checktime" } },
  -- go to last loc when opening a buffer
  BufReadPost = {
    {
      callback = function()
        local mark = vim.api.nvim_buf_get_mark(0, '"')
        local lcount = vim.api.nvim_buf_line_count(0)
        if mark[1] > 0 and mark[1] <= lcount then
          pcall(vim.api.nvim_win_set_cursor, 0, mark)
        end
      end,
    },
  },
  -- windows to close with q
  FileType = {
    {
      pattern = {
        "OverseerForm",
        "OverseerList",
        "floggraph",
        "fugitive",
        "git",
        "help",
        "lspinfo",
        "man",
        "neotest-output",
        "neotest-summary",
        "qf",
        "query",
        "spectre_panel",
        "startuptime",
        "toggleterm",
        "tsplayground",
        "vim",
        "neoai-input",
      },
      callback = function(event)
        vim.bo[event.buf].buflisted = false
        vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf })
      end,
    },
  },
  -- don't auto comment new line
  BufEnter = {
    {
      callback = function()
        vim.opt.formatoptions:remove { "c", "r", "o" }
      end,
    },
  },
}

for event, opt_tbls in pairs(aucmd_dict) do
  for _, opt_tbl in pairs(opt_tbls) do
    vim.api.nvim_create_autocmd(event, opt_tbl)
  end
end

-- Auto Create Intermediary Directories
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
  group = vim.api.nvim_create_augroup("auto_create_dir", { clear = true }),
  callback = function(event)
    local file = vim.loop.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})

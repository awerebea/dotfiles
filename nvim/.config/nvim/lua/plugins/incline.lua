-- Cache keyed by buffer number; nil = uncached, false = not a git repo, table = { repo, branch }
local _git_cache = {}

local function get_git_context(buf)
  if _git_cache[buf] ~= nil then
    return _git_cache[buf] or nil
  end

  local bufname = vim.api.nvim_buf_get_name(buf)
  if bufname == "" or vim.bo[buf].buftype ~= "" then
    _git_cache[buf] = false
    return nil
  end

  local dir = vim.fn.shellescape(vim.fn.fnamemodify(bufname, ":h"))

  -- Resolve the git common dir (shared across all worktrees of the same repo)
  local git_common_dir = vim.fn
    .system("git -C " .. dir .. " rev-parse --path-format=absolute --git-common-dir 2>/dev/null")
    :gsub("\n$", "")
  if vim.v.shell_error ~= 0 or git_common_dir == "" then
    _git_cache[buf] = false
    return nil
  end

  -- Bare repo: git-common-dir basename is not ".git" (e.g. "myrepo.git" or "myrepo")
  -- Non-bare (incl. worktrees of non-bare): git-common-dir basename is ".git"
  local repo_name
  if vim.fn.fnamemodify(git_common_dir, ":t") == ".git" then
    repo_name = vim.fn.fnamemodify(git_common_dir, ":h:t")
  else
    repo_name = vim.fn.fnamemodify(git_common_dir, ":t"):gsub("%.git$", "")
  end

  -- Branch name; detached HEAD shows short commit hash instead
  local branch =
    vim.fn.system("git -C " .. dir .. " rev-parse --abbrev-ref HEAD 2>/dev/null"):gsub("\n$", "")
  if branch == "" or branch == "HEAD" then
    branch =
      vim.fn.system("git -C " .. dir .. " rev-parse --short HEAD 2>/dev/null"):gsub("\n$", "")
  end

  local context = { repo = repo_name, branch = branch ~= "" and branch or "?" }
  _git_cache[buf] = context
  return context
end

return {
  "b0o/incline.nvim",
  enabled = true,
  event = "BufReadPost",
  opts = {
    hide = { cursorline = "focused_win" },
    window = { margin = { vertical = 0 }, overlap = { borders = true } },
    render = function(props)
      local bufname = vim.api.nvim_buf_get_name(props.buf)
      local filename = bufname ~= "" and vim.fn.fnamemodify(bufname, ":t") or "[No Name]"
      local modified = vim.bo[props.buf].modified
      local context = get_git_context(props.buf)

      local result = {}
      if context then
        table.insert(result, { context.repo, guifg = "#89b4fa" })
        table.insert(result, { "/", guifg = nil })
        table.insert(result, { context.branch, guifg = "#74c7ec" })
        table.insert(result, "  ")
      end
      table.insert(result, filename)
      if modified then
        table.insert(result, { " *", guifg = "#888888", gui = "bold" })
      end
      result.guibg = "#292e42"
      return result
    end,
  },
  config = function(_, opts)
    require("incline").setup(opts)
    vim.api.nvim_set_hl(0, "InclineNormal", { bg = "#292e42" })
    vim.api.nvim_set_hl(0, "InclineNormalNC", { bg = "#292e42" })
    -- Clear per-buffer cache on BufEnter so branch changes are reflected
    -- when you switch back to a buffer after an external git operation.
    vim.api.nvim_create_autocmd("BufEnter", {
      callback = function(ev)
        _git_cache[ev.buf] = nil
      end,
    })
  end,
}

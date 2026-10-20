-- Cache keyed by buffer number; nil = uncached, false = not a git repo,
-- table = { repo, branch }. Filled once per buffer: the git calls are
-- synchronous, so they must not run on every render or buffer switch.
local _git_cache = {}

local function git(dir, args)
  local out = vim.fn.system("git -C " .. dir .. " " .. args .. " 2>/dev/null"):gsub("\n$", "")
  return vim.v.shell_error == 0 and out or ""
end

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
  local git_common_dir = git(dir, "rev-parse --path-format=absolute --git-common-dir")
  if git_common_dir == "" then
    _git_cache[buf] = false
    return nil
  end

  -- Bare repo: git-common-dir basename is not ".git" (e.g. "myrepo.git" or "myrepo")
  -- Non-bare (incl. worktrees of non-bare): git-common-dir basename is ".git"
  local repo_name
  if vim.fn.fnamemodify(git_common_dir, ":t") == ".git" then
    repo_name = vim.fn.fnamemodify(git_common_dir, ":h:t")
  else
    -- repo_name = vim.fn.fnamemodify(git_common_dir, ":t"):gsub("%.git$", "") -- trim `.git` suffix
    repo_name = vim.fn.fnamemodify(git_common_dir, ":t")
  end

  -- Branch name; detached HEAD shows short commit hash instead. Only used
  -- until gitsigns attaches, see branch_of()
  local branch = git(dir, "rev-parse --abbrev-ref HEAD")
  if branch == "" or branch == "HEAD" then
    branch = git(dir, "rev-parse --short HEAD")
  end

  local context = { repo = repo_name, branch = branch ~= "" and branch or "?" }
  _git_cache[buf] = context
  return context
end

-- gitsigns keeps b:gitsigns_head up to date (it watches the git dir), so a
-- branch switch is shown without running git here
local function branch_of(buf, context)
  local head = vim.b[buf].gitsigns_head
  return (head and head ~= "") and head or context.branch
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
        table.insert(result, { branch_of(props.buf, context), guifg = "#74c7ec" })
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
    local group = vim.api.nvim_create_augroup("InclineGit", { clear = true })
    -- Redraw incline when gitsigns reports a new branch
    local shown_head = {}
    vim.api.nvim_create_autocmd("User", {
      group = group,
      pattern = "GitSignsUpdate",
      callback = function(ev)
        local buf = ev.data and ev.data.buffer
        local head = buf and vim.b[buf].gitsigns_head
        if head and head ~= shown_head[buf] then
          shown_head[buf] = head
          require("incline").refresh()
        end
      end,
    })
    -- Re-resolve the repo after a buffer is renamed or reloaded
    vim.api.nvim_create_autocmd({ "BufFilePost", "BufWipeout" }, {
      group = group,
      callback = function(ev)
        _git_cache[ev.buf] = nil
        shown_head[ev.buf] = nil
      end,
    })
  end,
}

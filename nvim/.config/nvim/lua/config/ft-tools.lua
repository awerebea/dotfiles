-- :FtTools [filetype] - which language servers, formatters and linters exist
-- or are configured for a filetype (default: the current buffer's), and
-- whether each one is installed.
--
--   * Language servers are discovered: every nvim-lspconfig definition
--     (lsp/*.lua on the runtimepath) that lists the filetype, so the list
--     grows as nvim-lspconfig is updated.
--   * Formatters (conform) and linters (nvim-lint) are the ones configured
--     for the filetype: their definitions carry no filetype metadata, so
--     there is nothing to discover them from.
--
-- The preview shows each tool's definition; for servers its header documents
-- how to install it. Confirm opens the definition file.

local M = {}

local lsp_utils = require("plugins.lsp.utils")

local status_hl = {
  attached = "DiagnosticOk",
  enabled = "DiagnosticInfo",
  installed = "DiagnosticHint",
  missing = "DiagnosticWarn",
  unknown = "Comment",
}
local status_rank = { attached = 1, enabled = 2, installed = 3, missing = 4, unknown = 5 }

-- servers run through these say nothing about whether the server itself is
-- installed (e.g. `npx some-server`, `python -m some_server`)
local runners = {}
for _, r in ipairs({ "npx", "bunx", "pnpm", "yarn", "node", "deno", "python", "python3", "uv", "uvx", "java", "dotnet", "go", "cargo", "sh", "bash" }) do
  runners[r] = true
end

---@param exe string?
local function exe_status(exe)
  if not exe or runners[exe] then
    return "unknown"
  end
  return vim.fn.executable(exe) == 1 and "installed" or "missing"
end

-- A function cmd (used to prefer a project-local binary) names its binary in
-- the definition, e.g. `local cmd = 'vscode-css-language-server'`
---@param file string
local function exe_from_source(file)
  local ok, lines = pcall(vim.fn.readfile, file)
  if not ok then
    return nil
  end
  local src = table.concat(lines, "\n")
  return src:match("local cmd = ['\"]([^'\"]+)['\"]")
    or src:match("rpc%.start%(%s*{%s*['\"]([^'\"]+)['\"]")
end

---@param ft string
---@param buf integer
local function lsp_items(ft, buf)
  local attached = {}
  for _, client in ipairs(vim.lsp.get_clients({ bufnr = buf })) do
    attached[client.name] = true
  end

  local items = {}
  -- deprecated definitions warn when loaded; skip them instead
  local deprecate = vim.deprecate
  for _, file in ipairs(vim.api.nvim_get_runtime_file("lsp/*.lua", true)) do
    local name = vim.fn.fnamemodify(file, ":t:r")
    local deprecated = false
    ---@diagnostic disable-next-line: duplicate-set-field
    vim.deprecate = function()
      deprecated = true
    end
    local ok, config = pcall(function()
      return vim.lsp.config[name]
    end)
    vim.deprecate = deprecate
    if ok and config and not deprecated and vim.tbl_contains(config.filetypes or {}, ft) then
      local exe = type(config.cmd) == "table" and config.cmd[1] or exe_from_source(file)
      local status = exe_status(exe)
      if attached[name] then
        status = "attached"
      elseif vim.lsp.is_enabled(name) then
        -- enabled but not running: say so when the binary is the reason
        status = status == "missing" and "missing" or "enabled"
      end
      items[#items + 1] = {
        kind = "server",
        name = name,
        exe = exe,
        status = status,
        enabled = vim.lsp.is_enabled(name),
        file = file,
      }
    end
  end
  table.sort(items, function(a, b)
    if status_rank[a.status] ~= status_rank[b.status] then
      return status_rank[a.status] < status_rank[b.status]
    end
    return a.name < b.name
  end)
  return items
end

---@param ft string
---@param buf integer
local function formatter_items(ft, buf)
  local ok, conform = pcall(require, "conform")
  if not ok then
    return {}
  end
  local names = conform.formatters_by_ft[ft] or {}
  if type(names) == "function" then
    names = names(buf)
  end
  local items = {}
  for _, name in ipairs(names) do
    if type(name) == "string" then
      local info = conform.get_formatter_info(name, buf)
      local file = vim.api.nvim_get_runtime_file("lua/conform/formatters/" .. name .. ".lua", false)[1]
      items[#items + 1] = {
        kind = "formatter",
        name = name,
        exe = info.command,
        status = info.available and "installed" or "missing",
        file = file,
      }
    end
  end
  return items
end

---@param ft string
local function linter_items(ft)
  local lint = package.loaded.lint
  local items = {}
  for _, name in ipairs(lsp_utils.list_linters(ft)) do
    local def = lint.linters[name]
    def = type(def) == "function" and def() or def
    local exe = type(def) == "table" and def.cmd or nil
    exe = type(exe) == "function" and exe() or exe
    local file = vim.api.nvim_get_runtime_file("lua/lint/linters/" .. name .. ".lua", false)[1]
    items[#items + 1] = {
      kind = "linter",
      name = name,
      exe = exe,
      status = exe_status(exe),
      file = file,
    }
  end
  return items
end

---@param ft? string
function M.open(ft)
  local buf = vim.api.nvim_get_current_buf()
  ft = (ft and ft ~= "") and ft or vim.bo[buf].filetype
  if ft == "" then
    vim.notify("FtTools: no filetype", vim.log.levels.WARN)
    return
  end
  -- server definitions come from nvim-lspconfig's runtime files
  require("lazy").load({ plugins = { "nvim-lspconfig" } })

  local items = {}
  for _, group in ipairs({ formatter_items(ft, buf), linter_items(ft), lsp_items(ft, buf) }) do
    for _, item in ipairs(group) do
      item.text = ("%s %s %s %s"):format(item.kind, item.name, item.status, item.exe or "")
      -- definitions without a file (custom formatters/linters) preview as text
      if not item.file then
        item.preview = { text = ("%s %s: defined in your config"):format(item.kind, item.name) }
      end
      items[#items + 1] = item
    end
  end
  if #items == 0 then
    vim.notify("FtTools: nothing known for filetype " .. ft, vim.log.levels.INFO)
    return
  end

  Snacks.picker.pick({
    title = "Tools for " .. ft,
    items = items,
    preview = function(ctx)
      if ctx.item.file then
        return Snacks.picker.preview.file(ctx)
      end
      return Snacks.picker.preview.preview(ctx)
    end,
    format = function(item)
      local ret = {
        { ("%-10s"):format(item.kind), "Comment" },
        { ("%-10s"):format(item.status), status_hl[item.status] },
        { ("%-28s"):format(item.name), item.enabled and "Special" or "Normal" },
      }
      if item.exe then
        ret[#ret + 1] = { item.exe, "Comment" }
      end
      return ret
    end,
  })
end

function M.setup()
  vim.api.nvim_create_user_command("FtTools", function(opts)
    M.open(opts.args)
  end, {
    nargs = "?",
    complete = "filetype",
    desc = "Language servers, formatters and linters for a filetype",
  })
  vim.keymap.set("n", "<leader>ht", M.open, { desc = "Tools for this filetype" })
end

return M

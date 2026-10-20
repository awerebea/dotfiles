-- Comment keymaps on top of the built-in commenting (:h commenting), kept
-- compatible with the ones Comment.nvim used to provide:
--   gco / gcO / gcA     add a comment below / above / at the end of the line
--   gb{motion}, gbc     toggle a block comment (/* */, --[[ ]], <!-- -->);
--                       filetypes without block comments get line comments
--   <C-/>, <C-\>        toggle a line / block comment on the line or selection
--   <leader>ci          invert comments: comment code lines, uncomment the rest
--   <leader>gy          duplicate the line(s) and comment out the original

local M = {}

-- Block comment strings for filetypes whose 'commentstring' is a line comment
local block_cs = {
  lua = "--[[%s]]",
  html = "<!--%s-->",
  xml = "<!--%s-->",
  markdown = "<!--%s-->",
  vue = "<!--%s-->",
  svelte = "<!--%s-->",
  haskell = "{-%s-}",
  ocaml = "(*%s*)",
}
for _, ft in ipairs({
  "c",
  "cpp",
  "cs",
  "css",
  "dart",
  "go",
  "groovy",
  "hcl",
  "java",
  "javascript",
  "javascriptreact",
  "jsonc",
  "kotlin",
  "less",
  "php",
  "rust",
  "scala",
  "scss",
  "sql",
  "swift",
  "terraform",
  "typescript",
  "typescriptreact",
}) do
  block_cs[ft] = "/*%s*/"
end

---Split a 'commentstring' into its trimmed left and right parts.
---@param cs string
---@return string left, string right
local function split_cs(cs)
  local left, right = cs:match("^%s*(.-)%s*%%s%s*(.-)%s*$")
  return left or "", right or ""
end

---Line comment parts at the cursor (tree-sitter context aware, see the
---nvim-ts-context-commentstring spec in plugins/comment.lua).
local function line_parts()
  local cs = vim.filetype.get_option(vim.bo.filetype, "commentstring")
  if type(cs) ~= "string" or not cs:find("%%s") then
    cs = vim.bo.commentstring
  end
  return split_cs(cs)
end

---Block comment parts, or nil when the filetype has no block comments.
local function block_parts()
  local cs = block_cs[vim.bo.filetype]
  if not cs then
    -- a 'commentstring' with a right part is a block comment already
    local left, right = line_parts()
    if right == "" then
      return nil
    end
    return left, right
  end
  return split_cs(cs)
end

-- {{{ gco / gcO / gcA
---@param key "o"|"O"|"A"
local function insert_comment(key)
  local left, right = line_parts()
  local before = left .. " "
  local after = right ~= "" and (" " .. right) or ""
  if key == "A" and vim.api.nvim_get_current_line():find("%S") then
    before = " " .. before
  end
  local keys = key .. before .. after .. string.rep("<Left>", vim.fn.strchars(after))
  vim.api.nvim_feedkeys(vim.keycode(keys), "n", false)
end
-- }}}

-- {{{ Block comments
---@param text string
---@param left string
---@param right string
---@return boolean
local function is_block_commented(text, left, right)
  local trimmed = vim.trim(text)
  return vim.startswith(trimmed, left) and vim.endswith(trimmed, right)
end

---Toggle a block comment around lines `first`..`last` (1-based).
local function block_lines(first, last, left, right)
  local lines = vim.api.nvim_buf_get_lines(0, first - 1, last, false)
  local head, tail = lines[1], lines[#lines]
  if is_block_commented(table.concat(lines, "\n"), left, right) then
    local indent, rest = head:match("^(%s*)(.*)$")
    lines[1] = indent .. rest:sub(#left + 1):gsub("^ ", "", 1)
    tail = lines[#lines]
    lines[#lines] = tail:gsub("%s*$", ""):sub(1, -#right - 1):gsub(" $", "", 1)
  else
    local indent, rest = head:match("^(%s*)(.*)$")
    lines[1] = indent .. left .. " " .. rest
    lines[#lines] = lines[#lines] .. " " .. right
  end
  vim.api.nvim_buf_set_lines(0, first - 1, last, false, lines)
end

---Toggle a block comment around a charwise region ((1,0)-indexed, end inclusive).
local function block_chars(srow, scol, erow, ecol, left, right)
  local last_line = vim.api.nvim_buf_get_lines(0, erow - 1, erow, false)[1]
  -- exclusive end, past the whole (possibly multibyte) last character
  local last_char = vim.fn.strcharpart(last_line:sub(ecol + 1), 0, 1)
  ecol = math.min(ecol + math.max(#last_char, 1), #last_line)
  local text = vim.api.nvim_buf_get_text(0, srow - 1, scol, erow - 1, ecol, {})
  local joined = table.concat(text, "\n")
  local new
  if vim.startswith(joined, left) and vim.endswith(joined, right) then
    new = joined:sub(#left + 1, -#right - 1):gsub("^ ", "", 1):gsub(" $", "", 1)
  else
    new = left .. " " .. joined .. " " .. right
  end
  vim.api.nvim_buf_set_text(0, srow - 1, scol, erow - 1, ecol, vim.split(new, "\n"))
end

---'operatorfunc' for gb: block comment, or line comment without block syntax.
---@param motion "line"|"char"|"block"
local function block_operator(motion)
  local s = vim.api.nvim_buf_get_mark(0, "[")
  local e = vim.api.nvim_buf_get_mark(0, "]")
  local left, right = block_parts()
  if not left then
    require("vim._comment").toggle_lines(s[1], e[1], s)
  elseif motion == "char" then
    block_chars(s[1], s[2], e[1], e[2], left, right)
  else
    block_lines(s[1], e[1], left, right)
  end
end

local function block_expr()
  vim.o.operatorfunc = "v:lua.require'config.comment'.block_operator"
  return "g@"
end
M.block_operator = block_operator
-- }}}

-- {{{ Invert comments
---'operatorfunc' for <leader>ci: toggle every non-blank line on its own, so
---commented lines get uncommented and the others commented.
function M.invert_operator()
  local first = vim.api.nvim_buf_get_mark(0, "[")[1]
  local last = vim.api.nvim_buf_get_mark(0, "]")[1]
  local cursor = vim.api.nvim_win_get_cursor(0)
  local toggle = require("vim._comment").toggle_lines
  for lnum = first, last do
    if vim.fn.getline(lnum):find("%S") then
      toggle(lnum, lnum, { lnum, 0 })
    end
  end
  vim.api.nvim_win_set_cursor(0, cursor)
end
-- }}}

function M.setup()
  local map = vim.keymap.set

  map("n", "gco", function()
    insert_comment("o")
  end, { desc = "Add comment below" })
  map("n", "gcO", function()
    insert_comment("O")
  end, { desc = "Add comment above" })
  map("n", "gcA", function()
    insert_comment("A")
  end, { desc = "Add comment at end of line" })

  map({ "n", "x" }, "gb", block_expr, { expr = true, desc = "Toggle block comment" })
  map("n", "gbc", function()
    return block_expr() .. "_"
  end, { expr = true, desc = "Toggle block comment line" })

  -- Terminals send <C-/> as <C-_>, unless they report keys with modifiers
  for _, lhs in ipairs({ "<C-_>", "<C-/>" }) do
    map("n", lhs, "gcc", { remap = true, desc = "Toggle comment line" })
    map("x", lhs, "gc", { remap = true, desc = "Toggle comment" })
  end
  map("n", "<C-\\>", "gbc", { remap = true, desc = "Toggle block comment line" })
  map("x", "<C-\\>", "gb", { remap = true, desc = "Toggle block comment" })

  map({ "n", "x" }, "<leader>ci", function()
    vim.o.operatorfunc = "v:lua.require'config.comment'.invert_operator"
    return "g@"
  end, { expr = true, desc = "Invert comments" })

  map("n", "<leader>gy", "yygccp", { remap = true, desc = "Duplicate commented line" })
  map("x", "<leader>gy", "ygvgc`>p", { remap = true, desc = "Duplicate commented line" })
end

return M

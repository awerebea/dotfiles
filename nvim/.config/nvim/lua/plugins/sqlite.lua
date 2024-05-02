return {
  "kkharji/sqlite.lua",
  module = "sqlite",
  config = function()
    if require("utils").is_windows() then
      vim.g.sqlite_clib_path = "C:/Program Files/sqlite/sqlite3.dll"
    end
  end,
}

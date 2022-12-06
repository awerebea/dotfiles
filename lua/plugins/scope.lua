-- import plugin safely
local setup, scope = pcall(require, "scope")
if not setup then
  return
end

scope.setup()

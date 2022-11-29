-- import plugin safely
local setup, todo_comments = pcall(require, "todo-comments")
if not setup then
  return
end

-- enable plugin
todo_comments.setup()

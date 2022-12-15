local setup, marks = pcall(require, "marks")
if not setup then
  return
end

marks.setup({ force_write_shada = true })

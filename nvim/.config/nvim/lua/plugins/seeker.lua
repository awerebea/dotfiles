return {
  "2kabhishek/seeker.nvim",
  dependencies = { "folke/snacks.nvim", "nvim-telescope/telescope.nvim" },
  cmd = { "Seeker" },
  keys = {
    { "<leader>fa", ":Seeker files<CR>", desc = "Seek Files" },
    { "<leader>sf", ":Seeker files<CR>", desc = "Seek Files" },
    { "<leader>sG", ":Seeker git_files<CR>", desc = "Seek Git Files" },
    { "<leader>sg", ":Seeker grep<CR>", desc = "Seek Grep (fuzzy)" },
    { "<leader>s/", ":Seeker grep<CR>", desc = "Seek Grep (live)" },
    {
      "<leader>sw",
      function()
        require("seeker").seek({ mode = "grep_word" })
      end,
      mode = { "n", "x" },
      desc = "Seek Grep Word / Selection",
    },
  },
  opts = {
    -- picker_provider = "telescope",
    picker_opts = {
      actions = {
        -- open the item's directory in a floating oil with the cursor on the
        -- file; once oil is closed without opening a file, resume the picker
        -- (same query and cursor, results re-run so renames/deletes show up)
        oil_reveal = function(picker, item)
          local path = item and Snacks.picker.util.path(item)
          if not path then
            return
          end
          local orig_buf = vim.api.nvim_win_get_buf(picker.main)
          picker:close()
          vim.schedule(function()
            local oil = require("oil")
            local name = vim.fs.basename(path)
            oil.open_float(vim.fs.dirname(path), nil, function()
              for lnum = 1, vim.api.nvim_buf_line_count(0) do
                local entry = oil.get_entry_on_line(0, lnum)
                if entry and entry.name == name then
                  vim.api.nvim_win_set_cursor(0, { lnum, 0 })
                  break
                end
              end
            end)
            vim.api.nvim_create_autocmd("WinClosed", {
              pattern = tostring(vim.api.nvim_get_current_win()),
              once = true,
              callback = function()
                -- oil closes the float before it opens a selected file, and it
                -- resolves the path async, so give it a moment; a file opened
                -- from oil replaces the original buffer and skips the resume
                vim.defer_fn(function()
                  if vim.api.nvim_get_current_buf() == orig_buf then
                    Snacks.picker.resume()
                  end
                end, 100)
              end,
            })
          end)
        end,
      },
      win = {
        input = {
          keys = {
            ["<C-o>"] = { "oil_reveal", mode = { "n", "i" }, desc = "Reveal in Oil" },
          },
        },
      },
    },
  },
}

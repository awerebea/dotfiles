return {
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    -- From the quickmenu, open a file in:
    -- Vertical split with <ctrl-v>
    -- Horizontal split with <ctrl-x>
    -- New tab with <ctrl-t>

    -- Valid keymaps in Telescope are:
    -- <ctrl-x> delete the current mark

    keys = {
      "<leader><leader>m",
      "<leader>ha",
      "[h",
      "]h",
      "<leader>hm",
      "<leader>m",
      "<leader>hs",
    },
    config = function()
      require("telescope").load_extension "harpoon"
      local harpoon = require "harpoon"
      harpoon:setup { settings = { save_on_toggle = true, sync_on_ui_close = true } }

      harpoon:extend {
        UI_CREATE = function(cx)
          vim.keymap.set("n", "<C-v>", function()
            harpoon.ui:select_menu_item { vsplit = true }
          end, { buffer = cx.bufnr })

          vim.keymap.set("n", "<C-x>", function()
            harpoon.ui:select_menu_item { split = true }
          end, { buffer = cx.bufnr })

          vim.keymap.set("n", "<C-t>", function()
            harpoon.ui:select_menu_item { tabedit = true }
          end, { buffer = cx.bufnr })
        end,
      }

      local conf = require("telescope.config").values
      local function toggle_telescope(harpoon_files)
        local finder = function()
          local paths = {}
          for _, item in ipairs(harpoon_files.items) do
            table.insert(paths, item.value)
          end

          return require("telescope.finders").new_table {
            results = paths,
          }
        end

        require("telescope.pickers")
          .new({}, {
            prompt_title = "Harpoon",
            finder = finder(),
            previewer = conf.file_previewer {},
            sorter = conf.generic_sorter {},
            attach_mappings = function(prompt_bufnr, map)
              map("i", "<C-x>", function()
                local state = require "telescope.actions.state"
                local selected_entry = state.get_selected_entry()
                local current_picker = state.get_current_picker(prompt_bufnr)

                table.remove(harpoon_files.items, selected_entry.index)
                current_picker:refresh(finder())
              end)
              return true
            end,
          })
          :find()
      end

      local function select_harpoon_item(harpoon_list)
        local harpoon_items = {}
        for i, harpoon_item in ipairs(harpoon_list.items) do
          table.insert(harpoon_items, i .. ". " .. harpoon_item.value)
          if i == 9 then
            break
          end
        end
        if #harpoon_items == 0 then
          vim.notify "Harpoon's list is empty. There is nothing to select."
          return
        end
        table.insert(harpoon_items, 1, "Select Harpoon item:")
        vim.api.nvim_echo({ { table.concat(harpoon_items, "\n"), "Normal" } }, true, {})
        local choice = vim.fn.getchar() - 48

        if choice >= 1 and choice <= 9 then
          harpoon:list():select(choice)
        elseif choice then
          if string.char(choice + 48) ~= "q" and string.char(choice + 48) ~= "Q" then
            vim.notify("Invalid choice: " .. string.char(choice + 48))
          end
        end
      end

      vim.keymap.set("n", "<leader>m", function()
        toggle_telescope(harpoon:list())
      end, { desc = "Harpoon marks" })
      vim.keymap.set("n", "<leader><leader>m", function()
        local filename = vim.api.nvim_buf_get_name(0)
        if filename == "" then
          vim.notify "Couldn't find a valid file name to mark, sorry."
          return
        end
        vim.notify("Add Harpoon mark for file: " .. vim.fn.fnamemodify(filename, ":."))
        harpoon:list():add()
      end, { desc = "Add Harpoon mark" })
      vim.keymap.set("n", "<leader>ha", function()
        local filename = vim.api.nvim_buf_get_name(0)
        if filename == "" then
          vim.notify "Couldn't find a valid file name to mark, sorry."
          return
        end
        vim.notify("Add Harpoon mark for file: " .. vim.fn.fnamemodify(filename, ":."))
        harpoon:list():add()
      end, { desc = "Add Harpoon mark" })
      vim.keymap.set("n", "<leader>hm", function()
        harpoon.ui:toggle_quick_menu(harpoon:list())
      end, { desc = "Harpoon marks" })
      vim.keymap.set("n", "[h", function()
        harpoon:list():prev()
      end, { desc = "Previous Harpoon mark" })
      vim.keymap.set("n", "]h", function()
        harpoon:list():next()
      end, { desc = "Next Harpoon mark" })
      vim.keymap.set("n", "<leader>hs", function()
        select_harpoon_item(harpoon:list())
      end, { desc = "Select Harpoon item (1-9)" })
    end,
  },
}

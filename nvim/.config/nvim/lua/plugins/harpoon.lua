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
      "<leader>ht",
      "<leader>hl",
      "<leader><leader>h",
      "<leader>ha",
      "[h",
      "]h",
      "<leader>i",
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
        local bindings_map = {
          [1] = "f",
          [2] = "s",
          [3] = "t",
          [4] = "r",
          [5] = "d",
          [6] = "w",
          [7] = "a",
          [8] = "v",
          [9] = "c",
        }
        local harpoon_items = {}
        for i, harpoon_item in ipairs(harpoon_list.items) do
          table.insert(harpoon_items, bindings_map[i] .. ". " .. harpoon_item.value)
          if i == 9 then
            break
          end
        end
        if #harpoon_items == 0 then
          vim.notify "Harpoon's list is empty. There is nothing to select."
          return
        end
        vim.api.nvim_echo(
          { { "Select Harpoon item:\n" .. table.concat(harpoon_items, "\n"), "Normal" } },
          true,
          {}
        )
        local choice = vim.fn.getchar()
        for i, item in ipairs(bindings_map) do
          if i > #harpoon_items then
            break
          end
          if string.char(choice) == item then
            harpoon:list():select(i)
            return
          end
        end
        if choice and string.char(choice) ~= "q" and string.char(choice) ~= "Q" then
          vim.notify("Invalid choice: " .. string.char(choice))
        end
      end

      local function add_file_to_harpoon_list()
        local filename = vim.api.nvim_buf_get_name(0)
        if filename == "" then
          vim.notify "Couldn't find a valid file name to add to list, sorry."
          return
        end
        vim.notify("Add a file to the Harpoon list: " .. vim.fn.fnamemodify(filename, ":."))
        harpoon:list():add()
      end

      vim.keymap.set("n", "<leader>ht", function()
        toggle_telescope(harpoon:list())
      end, { desc = "Harpoon list in Telescope" })
      vim.keymap.set("n", "<leader>hl", function()
        harpoon.ui:toggle_quick_menu(harpoon:list())
      end, { desc = "Harpoon list" })
      vim.keymap.set("n", "<leader><leader>h", function()
        add_file_to_harpoon_list()
      end, { desc = "Add a file to the Harpoon list" })
      vim.keymap.set("n", "<leader>ha", function()
        add_file_to_harpoon_list()
      end, { desc = "Add a file to the Harpoon list" })
      vim.keymap.set("n", "[h", function()
        harpoon:list():prev()
      end, { desc = "Previous Harpoon file" })
      vim.keymap.set("n", "]h", function()
        harpoon:list():next()
      end, { desc = "Next Harpoon file" })
      vim.keymap.set("n", "<leader>i", function()
        select_harpoon_item(harpoon:list())
      end, { desc = "Select Harpoon item" })
    end,
  },
}

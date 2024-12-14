return {
  {
    "nvim-tree/nvim-tree.lua",
    enabled = true,
    cmd = { "NvimTreeToggle", "NvimTreeFindFileToggle" },
    keys = { { "<F2>", "<leader><F2>" } },
    opts = {
      on_attach = function(bufnr)
        local api = require "nvim-tree.api"
        local function opts(desc)
          return {
            desc = "nvim-tree: " .. desc,
            buffer = bufnr,
            noremap = true,
            silent = true,
            nowait = true,
          }
        end
        -- use all default mappings
        api.config.mappings.default_on_attach(bufnr)
        -- remove a default
        vim.keymap.del("n", "-", { buffer = bufnr })
        -- override a default
        vim.keymap.set("n", "<C-e>", api.tree.reload, opts "Refresh")
        vim.keymap.set("n", "u", api.tree.change_root_to_parent, opts "Up")
        vim.keymap.set("n", "h", api.node.navigate.parent_close, opts "Close Directory")
        vim.keymap.set("n", "l", api.node.open.edit, opts "Open")
        vim.keymap.set("n", "F1", api.node.show_info_popup, opts "Info")
        vim.keymap.set("n", "<", function()
          require("nvim-tree.view").resize "+5"
        end, opts "Increase size")
        vim.keymap.set("n", ">", function()
          require("nvim-tree.view").resize "-5"
        end, opts "Decrease size")

        -- Copy the selected part of the file path {{
        local function copy_selector()
          local node = api.tree.get_node_under_cursor()
          local filepath = node.absolute_path
          local dirpath = vim.fs.dirname(filepath)
          local filename = vim.fs.basename(filepath)
          local modify = vim.fn.fnamemodify

          local results = {
            filepath,
            modify(filepath, ":."),
            modify(filepath, ":~"),
            dirpath,
            modify(dirpath, ":."),
            modify(dirpath, ":~"),
            filename,
            modify(filename, ":r"),
            modify(filename, ":e"),
          }

          local messages = {
            "Choose to copy to clipboard:",
            "1. File path absolute         : " .. results[1],
            "2. File path relative to CWD  : " .. results[2],
            "3. File path relative to HOME : " .. results[3],
            "4. Dir path absolute          : " .. results[4],
            "5. Dir path relative to CWD   : " .. results[5],
            "6. Dir path relative to HOME  : " .. results[6],
            "7. Filename                   : " .. results[7],
            "8. File basename              : " .. results[8],
            "9. Extension of the file      : " .. results[9],
          }

          vim.api.nvim_echo({ { table.concat(messages, "\n"), "Normal" } }, true, {})
          local choice = vim.fn.getchar() - 48

          if choice >= 1 and choice <= 9 then
            local result = results[choice]
            vim.notify(("Copied: `%s`"):format(result))
            vim.fn.setreg("+", result)
          elseif choice then
            vim.notify("Invalid choice: " .. string.char(choice + 48))
          end
        end
        vim.keymap.set("n", "Y", function()
          copy_selector()
        end, opts "Copy selector")
        -- }}
      end,
      disable_netrw = false,
      hijack_netrw = true,
      respect_buf_cwd = true,
      view = {
        side = "right",
        number = true,
        relativenumber = true,
        width = 50,
      },
      filters = {
        custom = { "^\\.git$" },
      },
      sync_root_with_cwd = true,
      prefer_startup_root = true,
      update_focused_file = {
        enable = false,
        update_root = true,
      },
      actions = {
        open_file = {
          quit_on_open = false,
          window_picker = {
            enable = true,
            picker = "default",
            chars = "FJDKSLA;EIQPWO",
            exclude = {
              filetype = { "notify", "packer", "qf", "diff", "fugitive", "fugitiveblame" },
              buftype = { "nofile", "terminal", "help" },
            },
          },
        },
      },
      renderer = {
        group_empty = true,
        icons = {
          glyphs = {
            folder = {
              arrow_closed = "󰁕", -- arrow when folder is closed
              arrow_open = "󰁆", -- arrow when folder is open
            },
          },
        },
        symlink_destination = false,
      },
      sort_by = "case_sensitive",
      --  git = {
      --    ignore = false,
      --  },
    },
    config = function(_, opts)
      -- recommended settings from nvim-tree documentation
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1
      -- change color for arrows in tree to light blue
      vim.api.nvim_command "highlight NvimTreeIndentMarker guifg=#3FC5FF"
      require("nvim-tree").setup(opts)
      vim.keymap.set("n", "<F2>", function()
        if vim.bo.filetype == "NvimTree" then
          require("nvim-tree.api").tree.close()
        else
          require("nvim-tree.api").tree.open()
        end
      end, { desc = "Toggle NvimTree" })
      vim.keymap.set("n", "<leader><F2>", function()
        require("nvim-tree.api").tree.find_file { open = true, focus = true }
      end, { desc = "Find file in NvimTree" })
    end,
  },
}

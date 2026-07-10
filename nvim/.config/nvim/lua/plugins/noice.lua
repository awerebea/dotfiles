return {
  "folke/noice.nvim",
  event = "VeryLazy",
  dependencies = { "MunifTanjim/nui.nvim" },
  opts = {
    lsp = {
      override = {
        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
        ["vim.lsp.util.stylize_markdown"] = true,
        -- Only relevant with nvim-cmp; remove if switching to blink.cmp.
        ["cmp.entry.get_documentation"] = true,
      },
    },
    presets = {
      bottom_search = false, -- when true - keep / search at the bottom bar (less disorienting)
      command_palette = true, -- float the : cmdline + popupmenu together
      long_message_to_split = true, -- long messages go to a split instead of a popup
      inc_rename = true, -- set true if using inc-rename.nvim
      lsp_doc_border = true, -- consistent with border = "rounded" everywhere else
    },
    views = {
      -- command_palette preset overrides row to 3 (near top); put it back to center.
      cmdline_popup = {
        position = {
          row = "50%",
          col = "50%",
        },
      },
      cmdline_popupmenu = {
        position = {
          row = "60%",
          col = "50%",
        },
      },
    },
  },
  -- stylua: ignore
  keys = {
    { "<M-CR>", function() require("noice").redirect(vim.fn.getcmdline()) end, mode = "c", desc = "Redirect Cmdline to split" },
    { "<leader>snl", function() require("noice").cmd("last") end, desc = "Noice Last Message" },
    { "<leader>snh", function() require("noice").cmd("history") end, desc = "Noice History" },
    { "<leader>sna", function() require("noice").cmd("all") end, desc = "Noice All" },
    { "<leader>snd", function() require("noice").cmd("dismiss") end, desc = "Noice Dismiss" },
    -- Moved from snacks/keymaps.lua (was Snacks.notifier.hide()).
    { "<leader>ttN", function() require("noice").cmd("dismiss") end, desc = "Dismiss All Notifications" },
    { "<c-f>", function() if not require("noice.lsp").scroll(4) then return "<c-f>" end end,  expr = true, desc = "Scroll forward" },
    { "<c-b>", function() if not require("noice.lsp").scroll(-4) then return "<c-b>" end end, expr = true, desc = "Scroll backward"},
  },
  config = function(_, opts)
    require("noice").setup(opts)
    -- Moved from snacks/init.lua (was Snacks.notifier.show_history()).
    vim.api.nvim_create_user_command("NotificationsNoice", function()
      require("noice").cmd("history")
    end, { desc = "Show notification history" })
  end,
}

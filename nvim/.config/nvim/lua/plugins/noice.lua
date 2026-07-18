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
      bottom_search = false, -- when true - use a classic bottom cmdline for search
      command_palette = true, -- position the cmdline and popupmenu together
      long_message_to_split = true, -- long messages will be sent to a split
      inc_rename = true, -- enables an input dialog for inc-rename.nvim
      lsp_doc_border = true, -- add a border to hover docs and signature help
    },
    views = {
      -- command_palette preset overrides row to 3 (near top); put it back to center.
      cmdline_popup = {
        position = {
          row = "50%",
          col = "50%",
        },
      },
    },
  },
  config = function(_, opts)
    local noice = require("noice")
    local noice_lsp = require("noice.lsp")
    noice.setup(opts)

    local map = vim.keymap.set
    -- stylua: ignore start
    map("c", "<M-CR>",       function() noice.redirect(vim.fn.getcmdline()) end, { desc = "Redirect Cmdline to split" })
    map("n", "<leader>snl",  function() noice.cmd("last") end,                   { desc = "Noice Last Message" })
    map("n", "<leader>snh",  function() noice.cmd("history") end,                { desc = "Noice History" })
    map("n", "<leader>sna",  function() noice.cmd("all") end,                    { desc = "Noice All" })
    map("n", "<leader>snd",  function() noice.cmd("dismiss") end,                { desc = "Noice Dismiss" })
    map("n", "<c-f>", function() if not noice_lsp.scroll(4)  then return "<c-f>" end end, { expr = true, desc = "Scroll forward" })
    map("n", "<c-b>", function() if not noice_lsp.scroll(-4) then return "<c-b>" end end, { expr = true, desc = "Scroll backward" })
    -- stylua: ignore end

    -- Moved from snacks/init.lua (was Snacks.notifier.show_history()).
    vim.api.nvim_create_user_command("NotificationsNoice", function()
      noice.cmd("history")
    end, { desc = "Show notification history" })
  end,
}

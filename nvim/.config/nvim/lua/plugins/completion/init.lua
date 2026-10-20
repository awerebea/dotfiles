return {
  {
    "saghen/blink.cmp",
    -- release builds download a prebuilt binary of the Rust fuzzy matcher
    version = "1.*",
    event = "InsertEnter",
    opts = function()
      local icons = require("config.icons")

      local function has_words_before()
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0
          and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s")
            == nil
      end

      -- neogen jumps between its own placeholders when it is loaded and has any
      local function neogen_jump(prev)
        return function()
          local neogen = package.loaded.neogen
          if neogen and neogen.jumpable(prev) then
            vim.schedule(function()
              if prev then
                neogen.jump_prev()
              else
                neogen.jump_next()
              end
            end)
            return true
          end
        end
      end

      ---@module 'blink.cmp'
      ---@type blink.cmp.Config
      return {
        keymap = {
          preset = "none",
          ["<C-Space>"] = { "select_and_accept", "fallback" },
          ["<CR>"] = { "accept", "fallback" },
          ["<C-e>"] = { "cancel", "fallback" },
          ["<Esc><Esc>"] = { "cancel", "fallback" },
          ["<C-b>"] = { "scroll_documentation_up", "fallback" },
          ["<C-f>"] = { "scroll_documentation_down", "fallback" },
          ["<C-j>"] = {
            "select_next",
            "snippet_forward",
            neogen_jump(false),
            function(cmp)
              if has_words_before() then
                return cmp.show()
              end
            end,
            "fallback",
          },
          ["<C-k>"] = { "select_prev", "snippet_backward", neogen_jump(true), "fallback" },
        },
        completion = {
          -- nothing selected or inserted until <C-j>/<C-k> (noinsert, noselect)
          list = { selection = { preselect = false, auto_insert = false } },
          menu = {
            border = "rounded",
            draw = {
              columns = {
                { "kind_icon" },
                { "label", "label_description", gap = 1 },
                { "source_name" },
              },
            },
          },
          documentation = { auto_show = true, window = { border = "rounded" } },
        },
        appearance = { kind_icons = icons.kind },
        sources = {
          default = { "lsp", "buffer", "path" },
          providers = {
            -- show buffer words next to LSP items, not only when LSP has none
            lsp = { name = "(LSP)", fallbacks = {} },
            buffer = { name = "(Buffer)" },
            path = { name = "(Path)" },
          },
        },
        -- signature help comes from noice and lsp_signature already
        signature = { enabled = false },
        -- the command line keeps the built-in completion
        cmdline = { enabled = false },
      }
    end,
  },
}

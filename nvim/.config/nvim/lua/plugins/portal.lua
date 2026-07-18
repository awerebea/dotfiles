-- portal.nvim: jump through location lists (jumplist, changelist, quickfix)
-- with labeled floating window previews instead of blind <c-o>/<c-i>.
--
-- Commands:
--   :Portal jumplist backward     open backward jumplist portals
--   :Portal jumplist forward      open forward jumplist portals
--   :Portal changelist backward   open backward changelist portals
--   :Portal changelist forward    open forward changelist portals
--   :Portal quickfix              open quickfix portals
--
-- After portals open, press one of the label keys (j/k/h/l by default)
-- to jump to that location. Press <esc> to close without jumping.
--
-- Tips:
--   - labels = {"j","k","h","l"} also caps max visible portals to 4.
--     Increase labels to see more results, e.g. {"1","2","3","4","5"}.
--   - select_first = true auto-jumps when there is only one result.
--   - lookback = 100 controls how far back the location list is scanned.
--   - Use filter to show only relevant jumps, e.g. same-buffer only:
--       require("portal.builtin").jumplist.tunnel_backward({
--         filter = function(v) return v.buffer == vim.fn.bufnr() end,
--       })
--   - Use slots to pin specific results to label positions:
--       require("portal.builtin").jumplist.tunnel_backward({
--         slots = {
--           function(v) return v.buffer == vim.fn.bufnr() end,   -- label j: same buffer
--           function(v) return vim.bo[v.buffer].modified end,     -- label k: modified bufs
--         },
--       })
--   - Compose multiple location lists into one portal session:
--       require("portal").tunnel({
--         require("portal.builtin").jumplist.query({ max_results = 2 }),
--         require("portal.builtin").quickfix.query({ max_results = 2 }),
--       })
--   - Highlight groups: PortalLabel, PortalTitle, PortalBorder, PortalNormal.

return {
  "cbochs/portal.nvim",
  cmd = "Portal",
  keys = {
    { "<leader>pb", "<cmd>Portal jumplist backward<cr>", desc = "Portal: jumplist backward" },
    { "<leader>pf", "<cmd>Portal jumplist forward<cr>", desc = "Portal: jumplist forward" },
    { "<leader>pc", "<cmd>Portal changelist backward<cr>", desc = "Portal: changelist backward" },
    { "<leader>pC", "<cmd>Portal changelist forward<cr>", desc = "Portal: changelist forward" },
    { "<leader>pq", "<cmd>Portal quickfix forward<cr>", desc = "Portal: quickfix" },
  },
  opts = {
    -- labels cap max visible portals; add more characters to see more results
    labels = { "j", "k", "h", "l" },
    select_first = false, -- set true to auto-jump when only one result exists
    lookback = 100, -- how far back to scan location lists
    window_options = {
      relative = "cursor",
      width = 80,
      height = 3,
      col = 2,
      border = "rounded",
      focusable = false,
      noautocmd = true,
    },
  },
}

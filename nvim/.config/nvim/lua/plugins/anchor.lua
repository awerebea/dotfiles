-- anchor.nvim: pin directories and jump into them via your fuzzy finder.
-- Slots 1-9 hold directories; slot 0 returns to the original cwd.
--
-- Commands:
--   :Anchor add           add current dir to the anchor list
--   :Anchor delete        remove a dir from the anchor list
--   :Anchor list          open anchor list in a floating buffer
--   :Anchor open {1-9}    open fuzzy finder rooted at anchored dir N
--   :Anchor open 0        return to original cwd
--   :Anchor grep {1-9}    live grep inside anchored dir N
--   :Anchor worktrees     open the git worktrees picker
--
-- Tips:
--   - Anchors are indexed 1-9; use <leader>a1-9 to jump to them directly.
--   - <leader>ag1-9 opens live grep inside the corresponding anchored dir.
--   - <leader>a0 always brings you back to the cwd nvim was launched from.
--   - <leader>aw lists all git worktrees in the current repo.
--   - picker = "auto" detects fzf-lua / telescope / snacks.picker automatically.
--   - grep keymaps require fzf-lua, telescope, mini.picks, or snacks.picker.
--   - relative_paths = true shows paths relative to HOME in the anchor list.
--   - excluded_dirs filters directories from fuzzy search (not from oil/netrw).
--   - Run :checkhealth anchor to verify the setup.

return {
  "zachyarbrough/anchor.nvim",
  cmd = "Anchor",
  keys = {
    {
      "<leader>aa",
      function()
        require("anchor").add()
      end,
      desc = "Anchor: add current dir",
    },
    {
      "<leader>ad",
      function()
        require("anchor").delete()
      end,
      desc = "Anchor: delete from list",
    },
    {
      "<leader>al",
      function()
        require("anchor").toggle_list()
      end,
      desc = "Anchor: toggle list",
    },
    {
      "<leader>aw",
      function()
        require("anchor").toggle_worktrees()
      end,
      desc = "Anchor: git worktrees",
    },
    {
      "<leader>a0",
      function()
        require("anchor").return_to_cwd()
      end,
      desc = "Anchor: return to original cwd",
    },
    {
      "<leader>a1",
      function()
        require("anchor").open(1)
      end,
      desc = "Anchor: open dir 1",
    },
    {
      "<leader>a2",
      function()
        require("anchor").open(2)
      end,
      desc = "Anchor: open dir 2",
    },
    {
      "<leader>a3",
      function()
        require("anchor").open(3)
      end,
      desc = "Anchor: open dir 3",
    },
    {
      "<leader>a4",
      function()
        require("anchor").open(4)
      end,
      desc = "Anchor: open dir 4",
    },
    {
      "<leader>a5",
      function()
        require("anchor").open(5)
      end,
      desc = "Anchor: open dir 5",
    },
    {
      "<leader>a6",
      function()
        require("anchor").open(6)
      end,
      desc = "Anchor: open dir 6",
    },
    {
      "<leader>a7",
      function()
        require("anchor").open(7)
      end,
      desc = "Anchor: open dir 7",
    },
    {
      "<leader>a8",
      function()
        require("anchor").open(8)
      end,
      desc = "Anchor: open dir 8",
    },
    {
      "<leader>a9",
      function()
        require("anchor").open(9)
      end,
      desc = "Anchor: open dir 9",
    },
    {
      "<leader>ag1",
      function()
        require("anchor").grep(1)
      end,
      desc = "Anchor: grep dir 1",
    },
    {
      "<leader>ag2",
      function()
        require("anchor").grep(2)
      end,
      desc = "Anchor: grep dir 2",
    },
    {
      "<leader>ag3",
      function()
        require("anchor").grep(3)
      end,
      desc = "Anchor: grep dir 3",
    },
    {
      "<leader>ag4",
      function()
        require("anchor").grep(4)
      end,
      desc = "Anchor: grep dir 4",
    },
    {
      "<leader>ag5",
      function()
        require("anchor").grep(5)
      end,
      desc = "Anchor: grep dir 5",
    },
    {
      "<leader>ag6",
      function()
        require("anchor").grep(6)
      end,
      desc = "Anchor: grep dir 6",
    },
    {
      "<leader>ag7",
      function()
        require("anchor").grep(7)
      end,
      desc = "Anchor: grep dir 7",
    },
    {
      "<leader>ag8",
      function()
        require("anchor").grep(8)
      end,
      desc = "Anchor: grep dir 8",
    },
    {
      "<leader>ag9",
      function()
        require("anchor").grep(9)
      end,
      desc = "Anchor: grep dir 9",
    },
  },
  opts = {
    picker = "auto",
    relative_paths = true,
    show_branches = true,
    winopts = {
      width = 80,
      height = 15,
      border = "rounded",
      title = "Anchor",
      numbers = "absolute",
    },
  },
}

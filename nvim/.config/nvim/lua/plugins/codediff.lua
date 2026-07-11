return {
  "esmuellert/codediff.nvim",
  cmd = "CodeDiff",
  keys = {
    { "<leader>ggs", "<cmd>CodeDiff<cr>",           desc = "CodeDiff: git status" },
    { "<leader>ggh", "<cmd>CodeDiff history %<cr>", desc = "CodeDiff: file history" },
    { "<leader>ggH", "<cmd>CodeDiff history<cr>",   desc = "CodeDiff: repo history" },
  },
  opts = {},
  -- Main commands:
  --   :CodeDiff                      git status explorer (staged/unstaged/conflicts)
  --   :CodeDiff HEAD~N               compare against N commits ago
  --   :CodeDiff <branch>             compare against branch / tag / commit
  --   :CodeDiff <ref> HEAD           compare two revisions
  --   :CodeDiff main...              PR-like diff (only your commits since branching)
  --   :CodeDiff history %            commit history for current file
  --   :CodeDiff history              repo commit history
  --   :CodeDiff file <a> <b>         compare two files
  --   :CodeDiff dir <a> <b>          compare two directories
  --   :CodeDiff --inline             force inline layout for the current invocation
  --   :CodeDiff install              download / update C library (run on first use)
  --
  -- Internal keymaps (buffer-local, active inside the diff view):
  --   q               quit / close
  --   t               toggle layout (side-by-side <-> inline)
  --   ]c / [c         next / prev hunk
  --   ]f / [f         next / prev file
  --   do / dp         diff get / diff put
  --   -               toggle stage for file / hunk
  --   <leader>hs      stage hunk
  --   <leader>hu      unstage hunk
  --   <leader>hr      discard hunk
  --   <leader>b       toggle explorer panel
  --   <leader>e       focus explorer panel
  --   gc              toggle compact context lines
  --   gm              align moves
  --   gf              open file in previous tab
  --   g?              show full keymap help
  --
  -- Explorer keymaps (inside the file explorer panel):
  --   <CR>            open file diff
  --   S / U           stage all / unstage all
  --   X               restore file
  --   R               refresh
  --
  -- Conflict keymaps (active inside conflict diff only):
  --   <leader>co / <leader>ct / <leader>cb   accept current / incoming / both
  --   <leader>cx                             discard conflict
  --   ]x / [x                               next / prev conflict
}

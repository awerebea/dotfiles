return {
  "MagicDuck/grug-far.nvim",
  cmd = { "GrugFar", "GrugFarWithin" },
  keys = {
    {
      "<leader>Sgg",
      function()
        require("grug-far").open()
      end,
      desc = "Grug-far: replace in workspace",
    },
    -- prefill search with the visual selection
    {
      "<leader>Sgg",
      mode = "x",
      function()
        require("grug-far").with_visual_selection()
      end,
      desc = "Grug-far: replace selection in workspace",
    },
    -- search current word
    {
      "<leader>Sgw",
      function()
        require("grug-far").open({ prefills = { search = vim.fn.expand("<cword>") } })
      end,
      desc = "Grug-far: replace word under cursor in workspace",
    },
    -- search in current file
    {
      "<leader>Sgf",
      function()
        require("grug-far").open({ prefills = { paths = vim.fn.expand("%") } })
      end,
      desc = "Grug-far: replace in current file",
    },
    -- search and replace only inside the selected lines
    {
      "<leader>Sgr",
      mode = "x",
      ":GrugFarWithin<CR>",
      desc = "Grug-far: replace within selected range",
    },
  },
  opts = {
    engines = {
      ripgrep = {
        -- match the shell rg alias; type --no-hidden in Flags to opt out
        extraArgs = "--hidden --glob=!.git/",
      },
    },
  },
}

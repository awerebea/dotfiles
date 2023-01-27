return {
  "akinsho/toggleterm.nvim",
  keys = { [[<leader>;]] },
  cmd = { "ToggleTerm", "TermExec" },
  opts = {
    size = function(term)
      if term.direction == "horizontal" then
        return 10
      elseif term.direction == "vertical" then
        return vim.o.columns * 0.4
      end
    end,
    autochdir = true, -- when neovim changes it current directory the terminal will change it's own when next it's opened
    hide_numbers = true,
    open_mapping = [[<leader>;]],
    shade_filetypes = {},
    shade_terminals = false,
    shading_factor = 0.3,
    start_in_insert = true,
    persist_size = true,
    direction = "horizontal",
    winbar = {
      enabled = false,
      name_formatter = function(term)
        return term.name
      end,
    },
  },
  config = function(_, opts)
    require("toggleterm").setup(opts)
    -- luacheck: push ignore set_terminal_keymaps
    SetTerminalKeymaps = function()
      local map_opts = { buffer = 0 }
      vim.keymap.set("t", "<leader><Esc>", [[<C-\><C-n>]], map_opts)
      vim.keymap.set("t", "<C-h>", [[<Cmd>wincmd h<CR>]], map_opts)
      vim.keymap.set("t", "<C-j>", [[<Cmd>wincmd j<CR>]], map_opts)
      vim.keymap.set("t", "<C-k>", [[<Cmd>wincmd k<CR>]], map_opts)
      vim.keymap.set("t", "<leader><C-l>", [[<Cmd>wincmd l<CR>]], map_opts) -- C-l is used to clear
    end

    -- if you only want these mappings for toggle term use term://*toggleterm#* instead
    vim.cmd "autocmd! TermOpen term://* lua SetTerminalKeymaps()"

    -- toggle all terminals at once
    vim.keymap.set(
      { "n", "t" },
      "<leader><leader>;",
      "<Cmd>ToggleTermToggleAll<CR>",
      { silent = true }
    )

    -- toggle vertical terminal
    vim.keymap.set("n", "<leader>v;", "<Cmd>ToggleTerm direction=vertical<CR>", { silent = true })

    vim.keymap.set("t", "<C-e>", [[<Cmd>WinResizerStartResize<CR>]], { silent = true })
  end,
}

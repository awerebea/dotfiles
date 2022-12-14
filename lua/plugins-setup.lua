-- auto install packer if not installed
local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({
      "git",
      "clone",
      "--depth",
      "1",
      "https://github.com/wbthomason/packer.nvim",
      install_path,
    })
    vim.cmd([[packadd packer.nvim]])
    return true
  end
  return false
end
local packer_bootstrap = ensure_packer() -- true if packer was just installed

-- autocommand that reloads neovim and installs/updates/removes plugins
-- when file is saved
vim.cmd([[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins-setup.lua source <afile> | PackerSync
  augroup end
]])

-- import packer safely
local status, packer = pcall(require, "packer")
if not status then
  return
end

-- add list of plugins to install
return packer.startup(function(use)
  -- packer can manage itself
  use("wbthomason/packer.nvim")

  use("nvim-lua/plenary.nvim") -- lua functions that many plugins use

  use("EdenEast/nightfox.nvim") -- preferred colorscheme

  use("christoomey/vim-tmux-navigator") -- tmux & split window navigation

  use("szw/vim-maximizer") -- maximizes and restores current window
  use("simeji/winresizer") -- easy resizing of vim windows

  use("folke/todo-comments.nvim") -- highlight TODO:, BUG:, NOTE: etc.

  use("norcalli/nvim-colorizer.lua") -- Neovim colorizer

  use("abecodes/tabout.nvim") -- tab out from parentheses, quotes, and similar contexts

  -- essential plugins
  use("tpope/vim-surround") -- add, delete, change surroundings (it's awesome)
  use("tpope/vim-repeat") -- enable repeating supported plugin maps with '.'
  use("tpope/vim-unimpaired") -- pairs of handy bracket mappings
  use("inkarkat/vim-ReplaceWithRegister") -- replace with register contents using motion (gr + motion)

  -- commenting with gc
  use("preservim/nerdcommenter")

  -- file explorer
  use("nvim-tree/nvim-tree.lua")
  use("kevinhwang91/rnvimr")

  -- vs-code like icons
  use("nvim-tree/nvim-web-devicons")

  -- statusline
  use("itchyny/lightline.vim")
  use("macthecadillac/lightline-gitdiff")
  use("josa42/nvim-lightline-lsp")
  use("Rigellute/rigel") -- Lightline theme (for cobalt2)

  -- Automatically save/restore current state of Vim
  use("rmagatti/auto-session")

  -- fuzzy finding w/ telescope
  use({ "nvim-telescope/telescope-fzf-native.nvim", run = "make" }) -- dependency for better sorting performance
  use({ "nvim-telescope/telescope.nvim", branch = "0.1.x" }) -- fuzzy finder

  use("ThePrimeagen/harpoon") -- getting you where you want with the fewest keystrokes

  use("kiyoon/telescope-insert-path.nvim") -- insert file path on the current buffer using telescope

  -- autocompletion
  use("hrsh7th/nvim-cmp") -- completion plugin
  use("hrsh7th/cmp-buffer") -- source for text in buffer
  use("hrsh7th/cmp-path") -- source for file system paths
  use("hrsh7th/cmp-cmdline") -- source for vim's cmdline
  use("f3fora/cmp-spell") -- source for spell dictionary

  -- snippets
  use("L3MON4D3/LuaSnip") -- snippet engine
  use("saadparwaiz1/cmp_luasnip") -- for autocompletion
  use("rafamadriz/friendly-snippets") -- useful snippets

  -- managing & installing lsp servers, linters & formatters
  use("williamboman/mason.nvim") -- in charge of managing lsp servers, linters & formatters
  use("williamboman/mason-lspconfig.nvim") -- bridges gap b/w mason & lspconfig

  -- configuring lsp servers
  use("neovim/nvim-lspconfig") -- easily configure language servers
  use("hrsh7th/cmp-nvim-lsp") -- for autocompletion
  use({ "glepnir/lspsaga.nvim", branch = "main" }) -- enhanced lsp uis
  use("jose-elias-alvarez/typescript.nvim") -- additional functionality for typescript server (e.g. rename file & update imports)
  use("onsails/lspkind.nvim") -- vs-code like icons for autocompletion

  -- formatting & linting
  use("jose-elias-alvarez/null-ls.nvim") -- configure formatters & linters
  use("jayp0521/mason-null-ls.nvim") -- bridges gap b/w mason & null-ls

  -- treesitter configuration
  use({
    "nvim-treesitter/nvim-treesitter",
    run = function()
      local ts_update = require("nvim-treesitter.install").update({ with_sync = true })
      ts_update()
    end,
  })
  use("nvim-treesitter/nvim-treesitter-textobjects")
  use("RRethy/nvim-treesitter-textsubjects")
  use("nvim-treesitter/nvim-treesitter-refactor")
  use("romgrk/nvim-treesitter-context")
  use("p00f/nvim-ts-rainbow")

  use({
    "mfussenegger/nvim-treehopper",
    config = function()
      vim.cmd([[omap     <silent> m :<C-U>lua require('tsht').nodes()<CR>]])
      vim.cmd([[vnoremap <silent> m :lua require('tsht').nodes()<CR>]])
    end,
  }) -- Region selection with hints on the AST nodes of a document powered by treesitter

  -- Indent lines
  use("lukas-reineke/indent-blankline.nvim")

  -- auto closing
  use("windwp/nvim-autopairs") -- autoclose parens, brackets, quotes, etc...
  use({ "windwp/nvim-ts-autotag", after = "nvim-treesitter" }) -- autoclose tags

  -- git integration
  use("lewis6991/gitsigns.nvim") -- show line modifications on left hand side
  use("itchyny/vim-gitbranch") -- get current git-branch name
  use("sindrets/diffview.nvim") -- easily cycling through diffs
  use("rhysd/git-messenger.vim")

  -- show buffers as tabs
  use("romgrk/barbar.nvim")
  use("tiagovla/scope.nvim")

  -- Neovim motions on speed!
  use("phaazon/hop.nvim")
  use("justinmk/vim-sneak")

  -- a faster version of filetype.vim
  use("nathom/filetype.nvim")

  -- easily manage multiple terminal windows
  use("akinsho/toggleterm.nvim")

  -- search and replace
  use("windwp/nvim-spectre")

  -- a pretty list for showing diagnostics, references, telescope results, quickfix, location lists
  use("folke/trouble.nvim")

  -- displays a popup with possible keybindings of the command you started typing
  use("folke/which-key.nvim")

  -- automatically highlighting other uses of the word under the cursor
  use("RRethy/vim-illuminate")

  use("davidgranstrom/nvim-markdown-preview") -- markdown preview

  use("SmiteshP/nvim-navic") -- winbar

  use("lewis6991/impatient.nvim") -- improve startup time for Neovim

  use({
    "nacro90/numb.nvim",
    config = function()
      require("numb").setup()
    end,
  }) -- peek lines just when you intend

  if packer_bootstrap then
    require("packer").sync()
  end
end)

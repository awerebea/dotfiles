local status, _ = pcall(vim.cmd, "silent echo gitbranch#name()")
if not status then
  print("vim-gibranch plugin not installed!")
  return
end

vim.g.rigel_lightline = 1

vim.g.lightline = {
  enable = {
    tabline = 0,
  },
  colorscheme = "tokyonight",
  active = {
    left = {
      {
        "mode",
        "paste",
      },
      {
        "gitbranch",
        "gitstatus",
      },
      {
        "filename",
        "modified",
      },
    },
    right = {
      {
        "lineinfo",
      },
      {
        "percent",
      },
      {
        "filetype",
        "fileformat",
        "fileencoding",
        "spell",
        "indent",
        "linter_hints",
        "linter_errors",
        "linter_warnings",
        "linter_infos",
        "linter_ok",
      },
    },
  },
  inactive = {
    left = {
      {
        "filename",
        "modified",
      },
    },
  },
  tab_component_function = {
    filename = "LightlineTabname",
  },
  component_function = {
    filename = "LightlineFileName",
    gitbranch = "LightlineGitbranch",
    fileformat = "LightlineFileformat",
    filetype = "LightlineFiletype",
    fileencoding = "LightlineFileencoding",
    indent = "LightlineIndent",
    lineinfo = "LightlineLineinfo",
    percent = "LightlinePercent",
    spell = "LightlineSpell",
  },
  component = {
    gitstatus = "%<%{lightline_gitdiff#get_status()}",
  },
  component_visible_condition = {
    gitstatus = 'lightline_gitdiff#get_status() !=# ""',
  },
  component_expand = {
    linter_hints = "lightline#lsp#hints",
    linter_infos = "lightline#lsp#infos",
    linter_warnings = "lightline#lsp#warnings",
    linter_errors = "lightline#lsp#errors",
    linter_ok = "lightline#lsp#ok",
  },
  component_type = {
    readonly = "error",
    gitdiff = "middle",
    linter_hints = "right",
    linter_infos = "right",
    linter_warnings = "warning",
    linter_errors = "error",
    linter_ok = "right",
  },
  -- mode_map copied from:
  -- https://github.com/nvim-lualine/lualine.nvim/blob/5113cdb32f9d9588a2b56de6d1df6e33b06a554a/lua/lualine/utils/mode.lua
  mode_map = {
    ["n"] = "N",
    ["no"] = "O-PENDING",
    ["nov"] = "O-PENDING",
    ["noV"] = "O-PENDING",
    ["no\22"] = "O-PENDING",
    ["niI"] = "N",
    ["niR"] = "N",
    ["niV"] = "N",
    ["nt"] = "N",
    ["v"] = "V",
    ["vs"] = "V",
    ["V"] = "VL",
    ["Vs"] = "VL",
    ["\22"] = "VB",
    ["\22s"] = "VB",
    ["s"] = "SELECT",
    ["S"] = "SL",
    ["\19"] = "SB",
    ["i"] = "I",
    ["ic"] = "I",
    ["ix"] = "I",
    ["R"] = "R",
    ["Rc"] = "R",
    ["Rx"] = "R",
    ["Rv"] = "V-REP",
    ["Rvc"] = "V-REP",
    ["Rvx"] = "V-REP",
    ["c"] = "C",
    ["cv"] = "EX",
    ["ce"] = "EX",
    ["r"] = "R",
    ["rm"] = "MORE",
    ["r?"] = "CONFIRM",
    ["!"] = "SHELL",
    ["t"] = "T",
  },
}

-- {{{ Lightline additional settings
-- lightline lsp indicators
-- vim.g["lightline#lsp#indicator_hints"] = ""
-- vim.g["lightline#lsp#indicator_infos"] = ""
-- vim.g["lightline#lsp#indicator_warnings"] = ""
-- vim.g["lightline#lsp#indicator_errors"] = ""
-- vim.g["lightline#lsp#indicator_ok"] = ""

-- lightline_gitdiff indicators
vim.g["lightline_gitdiff#indicator_added"] = "+"
vim.g["lightline_gitdiff#indicator_deleted"] = "-"
vim.g["lightline_gitdiff#indicator_modified"] = "~"
vim.g["lightline_gitdiff#min_winwidth"] = "88"

vim.cmd([[
  function! LightlineFileName()
    let filename = expand('%:p:h:t') . '/' . expand('%:t')

    if &filetype == 'nerdtree' || &filetype == 'NvimTree'
      return ''
    else
      if filename ==# ''
        return '[No Name]'
      endif

      let parts = split(filename, ':')

      " Show the shell with full path as filename
      if parts[0] ==# 'term'
        return parts[-1]
      endif

      return filename
    endif
  endfunction

  function! LightlinePercent() abort
        return winwidth(0) > 50 ? (100 * line('.') / line('$')) . '%' : ''
  endfunction

  function! LightlineLineinfo() abort
      if winwidth(0) > 50
        let l:current_line = printf('%2s', line('.'))
        let l:max_line = printf('%-2s', line('$'))
        let l:current_col = col('.')
        let l:current_virt_col = virtcol('.')
        let l:total_col = col('$')
        let l:total_virt_col = virtcol('$')
        if l:current_col != l:current_virt_col
          let l:col_num = printf('%2s(%s)', l:current_col, l:current_virt_col)
        else
          let l:col_num = printf('%2s', l:current_col)
        endif
        if l:total_col != l:total_virt_col
          let l:total_col = printf('%s(%s)', l:total_col, l:total_virt_col)
        else
          let l:total_col = printf('%-2s', l:total_col)
        endif
        let l:lineinfo = l:current_line . '/' . l:max_line . ' ' . l:col_num . '/' . l:total_col
        return l:lineinfo
      else
        return ''
      endif
  endfunction

  function! LightlineTabname(n) abort
    let bufnr = tabpagebuflist(a:n)[tabpagewinnr(a:n) - 1]
    let fname = expand('#' . bufnr . ':t')
    return fname =~ '__Tagbar__' ? 'Tagbar' :
          \ fname =~ 'NERD_tree' ? 'NERDTree' :
          \ fname =~ 'NvimTree' ? 'NvimTree' :
          \ ('' != fname ? fname : '[No Name]')
  endfunction

  function! LightlineIndent()
      if winwidth(0) < 91
          return ''
      elseif &tabstop == &softtabstop && &tabstop == &shiftwidth && !&expandtab
        return '⇆'.&tabstop."↹"
      elseif &tabstop && !&softtabstop && !&shiftwidth && !&expandtab
        return '⇆'.&tabstop."↹"
      elseif &tabstop && !&softtabstop && &tabstop == &shiftwidth && !&expandtab
        return '⇆'.&tabstop."↹"
      elseif &tabstop && !&softtabstop && !&shiftwidth && &expandtab
        return '⇆'.&tabstop."␣"
      elseif &tabstop == &softtabstop && &shiftwidth == &softtabstop && &expandtab
        return '⇆'.&tabstop."␣"
      elseif &tabstop != &softtabstop && &shiftwidth && &expandtab
        return '⇆'.&shiftwidth."␣"
      elseif &tabstop != &softtabstop && !&shiftwidth && &expandtab
        return '⇆'.&tabstop."␣"
      elseif &tabstop != &softtabstop && &shiftwidth && !&expandtab
        return '⇆'.&shiftwidth."␣".&tabstop."↹"
      endif
  endfunction

  function! LightlineFileformat()
    return winwidth(0) > 130 ? &fileformat : ''
  endfunction

  function! LightlineFiletype()
    return winwidth(0) > 110 ? (&filetype !=# '' ? &filetype : 'no ft') : ''
  endfunction

  function! LightlineFileencoding()
    return winwidth(0) > 120 ? (&fileencoding !=# '' ? &fileencoding : &enc) : ''
  endfunction

  function! LightlineGitbranch()
    if winwidth(0) > 85 || &filetype == 'nerdtree' || &filetype == 'NvimTree'
      return gitbranch#name()
    endif
    return ''
  endfunction

  function! LightlineSpell()
    if &spell
      if &spelllang == 'ru_yo,en_us' || &spelllang == 'ru_ru,en_us'
        return 'ru,en'
      elseif &spelllang == 'en_us,ru_yo' || &spelllang == 'en_us,ru_ru'
        return 'en,ru'
      elseif &spelllang == 'en_us' || &spelllang == 'en_uk'
      \ || &spelllang == 'en_en'
        return 'en'
      elseif &spelllang == 'ru_yo' || &spelllang == 'ru_ru'
        return 'ru'
      endif
        return &spelllang
    else
      return ''
    endif
  endfunction
]])
-- }}}

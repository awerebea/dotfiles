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
  colorscheme = "rigel",
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
        "fileformat",
        "filetype",
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
}

-- TODO Change indicators
-- {{{ Lightline additional settings
vim.cmd([[
  let g:lightline.mode_map = {
  \   'n' : 'N',
  \   'i' : 'I',
  \   'R' : 'R',
  \   'v' : 'V',
  \   'V' : 'VL',
  \   "\<C-v>": 'VB',
  \   'c' : 'C',
  \   's' : 'S',
  \   'S' : 'SL',
  \   "\<C-s>": 'SB',
  \   't' : 'T',
  \ }
]])
-- let g:lightline#lsp#indicator_hints = "\uf002"
-- let g:lightline#lsp#indicator_infos = "\uf129"
-- let g:lightline#lsp#indicator_warnings = "\uf071"
-- let g:lightline#lsp#indicator_errors = "\uf05e"
-- let g:lightline#lsp#indicator_ok = "\u2713"

-- lightline_gitdiff indicators
vim.cmd([[
let g:lightline_gitdiff#indicator_added = '+'
let g:lightline_gitdiff#indicator_deleted = '-'
let g:lightline_gitdiff#indicator_modified = '~'
let g:lightline_gitdiff#min_winwidth = '88'
]])

vim.cmd([[
  function! LightlineFileName()
    let filename = expand('%:p:h:t') . '/' . expand('%:t')

    if &filetype !=? 'nerdtree' && filename !=? 'ControlP'

      if filename ==# ''
        return '[No Name]'
      endif

      let parts = split(filename, ':')

      " Show the shell with full path as filename
      if parts[0] ==# 'term'
        return parts[-1]
      endif

      return filename
    else
      return ''
    endif
  endfunction

  function! LightlinePercent() abort
        return winwidth(0) > 50 ? (100 * line('.') / line('$')) . '%' : ''
  endfunction

  function! LightlineLineinfo() abort
      if winwidth(0) > 50
        let l:current_line = printf('%2s', line('.'))
        let l:max_line = printf('%-2s', line('$'))
        let l:current_col = printf('%3s', col('.'))
        let l:virt_col = printf('%-2s', virtcol('.'))
        let l:lineinfo = l:current_line . '/' . l:max_line . ' '
    \ . l:current_col . '/' . l:virt_col
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
    return winwidth(0) > 110 ? &fileformat : ''
  endfunction

  function! LightlineFiletype()
    return winwidth(0) > 90 ? (&filetype !=# '' ? &filetype : 'no ft') : ''
  endfunction

  function! LightlineFileencoding()
    return winwidth(0) > 90 ? (&fileencoding !=# '' ? &fileencoding : &enc) : ''
  endfunction

  function! LightlineGitbranch()
    if winwidth(0) > 85 || &filetype == 'nerdtree'
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

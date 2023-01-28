return {
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",

    config = function()
      vim.cmd [[
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
      ]]

      local components = require "plugins.statusline.components"

      require("lualine").setup {
        options = {
          icons_enabled = true,
          theme = "auto",
          component_separators = {},
          section_separators = {},
          disabled_filetypes = {
            statusline = { "alpha", "lazy" },
            winbar = {
              "help",
              "alpha",
              "lazy",
            },
          },
          always_divide_middle = true,
          globalstatus = true,
        },
        sections = {
          lualine_a = {
            {
              "mode",
              fmt = function(str)
                return str:sub(1, 1)
              end,
            },
          },
          -- lualine_b = { components.git_repo, "branch" },
          lualine_b = { "branch" },
          lualine_c = {
            components.diff,
            components.diagnostics,
            components.noice_command,
            components.noice_mode,
            components.separator,
            components.lsp_client,
          },
          lualine_x = {
            "LightlineFileName",
            "LightlineSpell",
            "LightlineIndent",
            "encoding",
            "fileformat",
            "filetype",
          },
          lualine_y = {
            "progress",
          },
          lualine_z = { "LightlineLineinfo" },
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = { "filename" },
          lualine_x = { "location" },
          lualine_y = {},
          lualine_z = {},
        },
        extensions = { "nvim-tree", "toggleterm", "quickfix" },
      }
    end,
  },
}

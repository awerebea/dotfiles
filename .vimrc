set nocompatible              " be iMproved, required

" Install vim-plug if not found
let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent !export GIT_SSL_NO_VERIFY=true
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim
  \ --create-dirs
  \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" Run PlugInstall if there are missing plugins
autocmd VimEnter * if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
  \| PlugInstall --sync | source $MYVIMRC
  \| endif

" Specify a directory for plugins {{{
" - For Neovim: stdpath('data') . '/plugged'
" - Avoid using standard Vim directory names like 'plugin'
call plug#begin('~/.vim/plugged')
" Improved incremental searching
Plug 'haya14busa/incsearch.vim'
" Vim motions on speed!
Plug 'easymotion/vim-easymotion'
" Integration between 'haya14busa/incsearch.vim' 'easymotion/vim-easymotion'
Plug 'haya14busa/incsearch-easymotion.vim'
" Plugin to toggle, display and navigate marks
Plug 'kshenoy/vim-signature'
" Easy swapping of text in Vim
Plug 'kurkale6ka/vim-swap'
" Increase/decrease visually selected regions of text using key combinations
Plug 'landock/vim-expand-region'
" Turns default register into a stack, and lets cycle through the items in the
" stack after doing a paste
Plug 'maxbrunsfeld/vim-yankstack'
" A Vim plugin that adds a :Qargs utility command, for populating the argument
" list from the files in the quickfix list
Plug 'nelstrom/vim-qargs'
" Automatic trigger complete popup menu
Plug 'othree/vim-autocomplpop'
" Easy comment/uncomment lines
Plug 'preservim/nerdcommenter'
" Efficient way of using Vim as a Git mergetool
Plug 'samoshkin/vim-mergetool'
" Make terminal vim and tmux work better together
Plug 'benmills/vimux'
Plug 'christoomey/vim-tmux-navigator'
" Easy text exchange operator
Plug 'tommcdo/vim-exchange'
" This plugin lets users define 'temporary keymaps', with the function
Plug 'tomtom/tinykeymap_vim'
" Easy move and resize windows
Plug 'simeji/winresizer'
" Interpret a file by function and cache file automatically
Plug 'MarcWeber/vim-addon-mw-utils'
" Libraries provides some utility functions (autocomplpop dependency)
Plug 'vim-scripts/L9'
" Smart substitution and easy change case styles
" (fooBar, foo_bar, foo-bar, boo.bar, foo bar, Foo Bar)
Plug 'tpope/vim-abolish'
" Vim sugar for the UNIX shell commands that need it the most
Plug 'tpope/vim-eunuch'
" Enable repeating supported plugin maps with '.'
Plug 'tpope/vim-repeat'
" Easy 'surroundings': parentheses, brackets, quotes, XML tags, and more
Plug 'tpope/vim-surround'
" Pairs of handy bracket mappings.
Plug 'tpope/vim-unimpaired'
" File system explorers
Plug 'preservim/nerdtree'
Plug 'francoiscabrol/ranger.vim'
" Explore buffers
Plug 'jlanzarotta/bufexplorer'
" Plugin to integrate various grep like search tools with Vim
Plug 'yegappan/grep'
" Run Git commands from Vim
Plug 'tpope/vim-fugitive'
Plug 'junegunn/gv.vim'
" Vim Git runtime files
Plug 'tpope/vim-git'
" A Vim plugin which shows a git diff in the sign column
Plug 'airblade/vim-gitgutter'
if has('nvim') || has('patch-8.0.902')
  Plug 'mhinz/vim-signify'
else
  Plug 'mhinz/vim-signify', { 'branch': 'legacy' }
endif
" A light and configurable statusline/tabline plugin for Vim
Plug 'itchyny/lightline.vim'
Plug 'macthecadillac/lightline-gitdiff'
" Automatically save/restore current state of Vim
Plug 'tpope/vim-obsession'
Plug 'dhruvasagar/vim-prosession'
Plug 'vim-scripts/restore_view.vim'
" Colorschemes
" Plug 'joshdick/onedark.vim'
" Plug 'crusoexia/vim-monokai'
Plug 'GlennLeo/cobalt2'
Plug 'Rigellute/rigel' " Lightline theme (for cobalt2)
" Plug 'morhetz/gruvbox'
" Plug 'shinchu/lightline-gruvbox.vim'
" A solid language pack for Vim syntax highlighting
Plug 'sheerun/vim-polyglot'
" Syntax highlighting, matching rules and mappings for Markdown
Plug 'godlygeek/tabular'
Plug 'plasticboy/vim-markdown'
" Markdown live preview
Plug 'iamcco/markdown-preview.nvim',
      \ { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug']}
" Text objects for the last searched pattern
Plug 'kana/vim-textobj-lastpat'
" Create your own text objects
Plug 'kana/vim-textobj-user'
" Rainbow Parentheses
Plug 'luochen1990/rainbow'
" A Narrow Region Plugin for vim
Plug 'chrisbra/NrrwRgn'
" Color hex codes and color names
Plug 'chrisbra/Colorizer'
" Distraction-free writing in Vim
Plug 'junegunn/goyo.vim'
" This script implements transparent editing of gpg encrypted files
Plug 'jamessan/vim-gnupg'
" A command-line fuzzy finder in Vim
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
" Interactive command execution in Vim
Plug 'Shougo/vimproc.vim'
" Terraform
Plug 'hashivim/vim-terraform'

" Syntax checker
Plug 'dense-analysis/ale'
Plug 'maximbaz/lightline-ale'
let check_result = system("command -v node")
if v:shell_error == 0
  Plug 'neoclide/coc.nvim', {'branch': 'release'}
  Plug 'tjdevries/coc-zsh'
endif
Plug 'pearofducks/ansible-vim'
" Snippets (code blocks) handling
" Plug 'garbas/vim-snipmate'
" Plug 'honza/vim-snippets'
" Plug 'tomtom/tlib_vim'
" Automatically folding
Plug 'pseewald/vim-anyfold'
" Vim plugins for visually displaying indent levels in code
Plug 'Yggdroot/indentLine'
Plug 'nathanaelkane/vim-indent-guides'
" Tabs
Plug 'ap/vim-buftabline'
" A Vim alignment plugin
Plug 'junegunn/vim-easy-align'
" Plugin that shows keybindings in popup
Plug 'liuchengxu/vim-which-key'
" Find and replace
Plug 'brooth/far.vim'

if executable('xkb-switch')
  " Automatic keyboard layout switching in insert mode
  Plug 'lyokha/vim-xkbswitch'
endif

if executable('ctags')
  " The Ctags generator for Vim
  Plug 'szw/vim-tags'
  " A class outline viewer for Vim
  Plug 'majutsushi/tagbar'
  " Plugin provides an overview of the structure of source code files
  Plug 'vim-scripts/taglist.vim'
  " Viewer & Finder for LSP symbols and tags
  Plug 'liuchengxu/vista.vim'
  " Vimprj is a Vim plugin that helps you manage options for multiple
  " projects.
  " Useful for automatically tags generation and update in projects.
  Plug 'vim-scripts/DfrankUtil'
  Plug 'vim-scripts/indexer.tar.gz'
  Plug 'vim-scripts/vimprj'
endif

" Initialize plugin system
call plug#end()
" }}}

set hidden
runtime macros/matchit.vim
filetype plugin indent on    " required

" Put your non-Plugin stuff after this line

set laststatus=2
set noshowmode
" Show non-visible white spaces
set listchars=eol:¬,tab:▸—,trail:~,extends:»,precedes:«,space:·
set list
" Turn off sound bell
set noerrorbells
set visualbell
set t_vb=
set scrolloff=2 " always show minimum n lines after current line

" Set <space> as leader key
let g:mapleader = "\<Space>"
" let g:maplocalleader = ','

" Always use 10-base numbers
set nrformats=

" Wildmenu completion " {{{
set wildmenu
set wildmode=full

set wildignore+=.hg,.git,.svn                    " Version control
set wildignore+=*.aux,*.out,*.toc                " LaTeX intermediate files
set wildignore+=*.jpg,*.bmp,*.gif,*.png,*.jpeg   " binary images
set wildignore+=*.o,*.obj,*.exe,*.dll,*.manifest " compiled object files
set wildignore+=*.spl                            " compiled spelling word list
set wildignore+=*.sw?                            " Vim swap files
set wildignore+=*.DS_Store                       " OSX bullshit
set wildignore+=*.luac                           " Lua byte code
set wildignore+=migrations                       " Django migrations
set wildignore+=go/pkg                           " Go static files
set wildignore+=go/bin                           " Go bin files
set wildignore+=go/bin-vagrant                   " Go bin-vagrant files
set wildignore+=*.pyc                            " Python byte code
set wildignore+=*.orig                           " Merge resolution files
" }}}

" tabs settings " {{{
function! TabsNoExpandByFourSpaces()
  setlocal tabstop=4
  setlocal shiftwidth=4
  setlocal softtabstop=4
  setlocal noexpandtab
endfunction
command TabsC call TabsNoExpandByFourSpaces()

function! TabsExpandByFourSpaces()
  setlocal tabstop=4
  setlocal shiftwidth=4
  setlocal softtabstop=4
  setlocal expandtab
endfunction
command TabsPython call TabsExpandByFourSpaces()
command TabsBash call TabsExpandByFourSpaces()

function! TabsExpandByTwoSpaces()
  setlocal tabstop=2
  setlocal shiftwidth=2
  setlocal softtabstop=2
  setlocal expandtab
endfunction

if has("autocmd")
  autocmd FileType ruby
        \ setlocal tabstop=2 softtabstop=2 shiftwidth=2 expandtab
  autocmd FileType sh
        \ setlocal tabstop=4 softtabstop=4 shiftwidth=4 expandtab
  autocmd FileType vim
        \ setlocal tabstop=2 softtabstop=2 shiftwidth=2 expandtab
  autocmd FileType zsh
        \ setlocal tabstop=2 softtabstop=2 shiftwidth=2 expandtab
  autocmd FileType tmux
        \ setlocal tabstop=2 softtabstop=2 shiftwidth=2 expandtab
  autocmd FileType conf
        \ setlocal tabstop=2 softtabstop=2 shiftwidth=2 expandtab
  autocmd FileType nginx
        \ setlocal tabstop=2 softtabstop=2 shiftwidth=2 expandtab
  autocmd FileType json*
        \ setlocal tabstop=4 softtabstop=4 shiftwidth=4 expandtab
  autocmd FileType javascript
        \ setlocal tabstop=4 softtabstop=4 shiftwidth=4 noexpandtab
  autocmd FileType c
        \ setlocal tabstop=4 softtabstop=4 shiftwidth=4 noexpandtab
  autocmd FileType dockerfile
        \ setlocal tabstop=4 softtabstop=4 shiftwidth=4 expandtab
  autocmd FileType make
        \ setlocal tabstop=4 softtabstop=4 shiftwidth=4 noexpandtab
  autocmd FileType cmake
        \ setlocal tabstop=4 softtabstop=4 shiftwidth=4 expandtab
  autocmd FileType cpp
        \ setlocal tabstop=4 softtabstop=4 shiftwidth=4 noexpandtab
  autocmd BufEnter **/cpp.snippets
        \ setlocal tabstop=4 softtabstop=4 shiftwidth=4 noexpandtab
  autocmd FileType gitcommit
        \ setlocal tabstop=2 softtabstop=2 shiftwidth=2 expandtab
  autocmd FileType gitignore
        \ setlocal tabstop=4 softtabstop=4 shiftwidth=4 noexpandtab
  autocmd FileType gitconfig
        \ setlocal tabstop=4 softtabstop=4 shiftwidth=4 noexpandtab
endif
" }}}

if !has('nvim')
  set ttymouse=xterm2
endif
set mouse=a
set mousehide
set showcmd
set number relativenumber

" toggle relativenumber
augroup SmartRelativenumbers
  autocmd!
  autocmd InsertEnter * :set norelativenumber
  autocmd InsertLeave * :set relativenumber
  autocmd BufLeave * :set norelativenumber
  autocmd BufEnter * :set relativenumber
augroup END

function! ToggleSmartRelativenumbers()
  if !exists('#SmartRelativenumbers#InsertEnter')
    set relativenumber
    augroup SmartRelativenumbers
      autocmd!
      autocmd InsertEnter * :set norelativenumber
      autocmd InsertLeave * :set relativenumber
      autocmd BufLeave * :set norelativenumber
      autocmd BufEnter * :set relativenumber
    augroup END
else
    set relativenumber!
    augroup SmartRelativenumbers
      autocmd!
    augroup END
  endif
endfunction

nnoremap <leader><leader>rn :call ToggleSmartRelativenumbers()<CR>

" ESC button remap
" inoremap kj <esc>
" cnoremap kj <C-C>

set encoding=utf-8      " default file encoding
set fileencodings=utf8,cp1251
set t_Co=256
set autowrite           " Automatically save before commands :next and :make
set updatetime=100      " Interface update timeout

" Word wrap " {{{
set wrapmargin=0
set colorcolumn=+1
set wrap linebreak
" Toggle word wrap for current buffer
nmap <leader>ww :setlocal wrap!<CR>
" Toggle wrap at 80 column
nmap <leader>aw :call AutoWrapToggle()<CR>
function! AutoWrapToggle()
  if &formatoptions =~ 't'
    setlocal textwidth=0
    setlocal fo-=t
    setlocal colorcolumn=
  else
    if (&filetype=='python')
      setlocal textwidth=79
    else
      setlocal textwidth=80
    endif
    setlocal fo+=t
    setlocal colorcolumn=+1
  endif
endfunction
" }}}

" More natural split opening. Open new split panes to right and bottom
set splitbelow
set splitright

" Easy navigation between splits to save a keystroke.
" So instead of ctrl-w then j, use just ctrl-j:
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

" Always move by screen lines instead of virtual lines with 'j' and 'k'
nnoremap j gj
nnoremap k gk

:set viminfo='1000,<1000,s200,h		" Increasing the buffer size

" Copy to 'clipboard registry'
vmap <C-c> "+y

let uname = substitute(system('uname'), '\n', '', '')
" Example values: Linux, Darwin, MINGW64_NT-10.0, MINGW32_NT-6.1

if uname == 'Linux'
  set clipboard=unnamedplus
elseif uname == 'Darwin'
  set clipboard=unnamed
else " windows
  set clipboard=unnamed
endif

set autoread " reread modified files automatically

set backspace=indent,eol,start
set sessionoptions=curdir,buffers,tabpages
set undolevels=2048
" move cursor to the next line when move with keystrokes below
set whichwrap=b,<,>,[,],l,h
set pastetoggle= " keep indent when pasting test

" Text selection highlighting
highlight Visual cterm=BOLD ctermbg=238 ctermfg=NONE
  \ gui=BOLD guibg=#ffffff guifg=NONE
" set syntax=c
" Enable syntax highlighting
if has("syntax")
  syntax on
endif

" Launch 'Goyo' style
nmap <leader>go :Goyo<CR>
let g:goyo_width = 86
" Toggle show non-visible white spaces
nmap <leader>ll :set list!<CR>
" Highlight trailing spaces
au BufNewFile,BufRead * let b:mtrailingws=matchadd('ErrorMsg', '\s\+$', -1)
" Highlight tabs between spaces
au BufNewFile,BufRead * let b:mtabbeforesp=matchadd('ErrorMsg',
  \ '\v(\t+)\ze( +)', -1)
au BufNewFile,BufRead * let b:mtabaftersp=matchadd('ErrorMsg',
  \ '\v( +)\zs(\t+)', -1)

" " cobalt2 theme settings
colorscheme cobalt2

" " gruvbox theme settings
" original gruvbox colorcheme
" let g:gruvbox_number_column = 'bg0' "default 'bg0'
" let g:gruvbox_sign_column = 'bg0' "default 'bg1'
" let g:gruvbox_bold = '0' "default '1'
" let g:gruvbox_contrast_dark = 'hard' "default 'medium'
" set background=dark
" colorscheme gruvbox

" " onedark theme settings
" let g:onedark_hide_endofbuffer=0
" let g:onedark_color_overrides = {
"   \ "black": {"gui": "#1D2229", "cterm": "234", "cterm16": "0" },
"   \}
" let g:onedark_termcolors=256
" colorscheme onedark
" highlight ColorColumn ctermbg=235 guibg=#262626

" monokai theme settings
" colorscheme monokai

" Common colorschemes settings
" Transparent background
highlight Normal          guibg=NONE ctermbg=NONE
" Transparent line number column
highlight LineNr          guibg=NONE ctermbg=NONE
" Transparent sign (Git/mark) column
highlight SignColumn      guibg=NONE ctermbg=NONE
" Transparent sign fold column
highlight FoldColumn      guibg=NONE ctermbg=NONE
" Color of word-wrap column
highlight ColorColumn     ctermbg=238 guibg=#444444
" Color of non-printable white spaces, with transparent background
highlight SpecialKey      term=bold ctermfg=241 guifg=#626262
                          \ ctermbg=NONE guibg=NONE
highlight NonText       term=bold ctermfg=241 guifg=#626262

" GitGutter settings
autocmd BufWritePost * GitGutter
" disable signs, use signify instead
let g:gitgutter_signs = 0
" " toggle signs
" nmap <leader>gg :GitGutterSignsToggle<CR>
" nmap <leader>ga :GitGutterAll<CR>
" [c / ]c - go to previous/next hunk
nmap ghp <Plug>(GitGutterPreviewHunk)
nmap ghs <Plug>(GitGutterStageHunk)
nmap ghu <Plug>(GitGutterUndoHunk)
" " Use fontawesome icons as signs
let g:gitgutter_sign_added = '+'
let g:gitgutter_sign_modified = '~'
let g:gitgutter_sign_removed = '_'
let g:gitgutter_sign_removed_first_line = '^'
let g:gitgutter_sign_modified_removed = '~_'

" Signify settings
" show current/total hunk when jump to it
autocmd User SignifyHunk call s:show_current_hunk()
function! s:show_current_hunk() abort
  let h = sy#util#get_hunk_stats()
  if !empty(h)
    echo printf('[Hunk %d/%d]', h.current_hunk, h.total_hunks)
  endif
endfunction
" toggle signs
nmap <leader>gg :SignifyToggle<CR>
" signs colors
highlight SignifySignAdd
  \ term=bold ctermfg=156 ctermbg=NONE guifg=#9cf087 guibg=NONE
highlight SignifySignChange
  \ term=bold ctermfg=44 ctermbg=NONE  guifg=#ffc500 guibg=NONE
highlight SignifySignChangeDelete
  \ term=bold ctermfg=44 ctermbg=NONE  guifg=#ffc500 guibg=NONE
highlight SignifySignDelete
  \ term=bold ctermfg=167 ctermbg=NONE guifg=#c43060 guibg=NONE
highlight SignifySignDeleteFirstLine
  \ term=bold ctermfg=167 ctermbg=NONE guifg=#c43060 guibg=NONE
" Signs
let g:signify_sign_add = '+'
let g:signify_sign_change = '~'
let g:signify_sign_delete = '_'
let g:signify_sign_delete_first_line = '^'
let g:signify_sign_change_delete = '~_'

" Use italic font for comments
" iTerm compatibility {{{
let &t_ZH="\e[3m"
let &t_ZR="\e[23m" " }}}
highlight Comment cterm=italic gui=italic

" NERDCommenter
" Add spaces after comment delimiters
let g:NERDSpaceDelims = 1
" custom formats or override the defaults
let g:NERDCustomDelimiters = { 'c': { 'left': '/*','right': '*/' } }
let g:NERDCustomDelimiters = { 'vim': { 'left': '"','right': '' } }
" let g:NERDCustomDelimiters = { 'cpp': { 'left': '/*','right': '*/' } }
let g:NERDCustomDelimiters = { 'Jenkinsfile': { 'left': '//','right': '' } }
" Align line-wise comment delimiters flush left instead of following code
" indentation (left/both)
let g:NERDDefaultAlign = 'both'
" Allow commenting and inverting empty lines (useful when commenting a region)
" let g:NERDCommentEmptyLines = 1
" Use compact syntax for prettified multi-line comments
let g:NERDCompactSexyComs = 0
" Enable trimming of trailing whitespace when uncommenting
let g:NERDTrimTrailingWhitespace = 1
let g:NERDDisableTabsInBlockComm = 1
nmap <Leader>c<space> <Plug>NERDCommenterToggle
vmap <Leader>c<space> <Plug>NERDCommenterToggle<CR>gv
" VSCode-like keymaps for comments
nmap <C-_> <Plug>NERDCommenterToggle
vmap <C-_> <Plug>NERDCommenterToggle<CR>gv

" Tagbar " {{{
" JS
let g:tagbar_type_javascript = {
  \   'ctagsbin' : '/path/to/jsctags'
  \ }

" CSS
let g:tagbar_type_css = {
  \ 'ctagstype' : 'Css',
  \ 'kinds'     : [
  \   'c:classes',
  \   's:selectors',
  \   'i:identities'
  \   ]
  \ }

" Google Go
let g:tagbar_type_go = {
  \ 'ctagstype': 'go',
  \ 'kinds' : [
  \   'p:package',
  \   'f:function',
  \   'v:variables',
  \   't:type',
  \   'c:const'
  \   ]
  \ }
" }}}

" Rainbow brackets settings " {{{
let g:rainbow_active = 1
let g:rainbow_conf = {
  \   'guifgs': ['darkorange', 'lightblue', 'lightyellow', 'lightcyan',
  \ 'lightmagenta', 'seagreen3', 'firebrick'],
  \   'ctermfgs': ['lightblue', 'lightyellow', 'lightcyan', 'lightmagenta'],
  \   'guis': [''],
  \   'cterms': [''],
  \   'operators': '_,_',
  \   'parentheses': ['start=/(/ end=/)/ fold', 'start=/\[/ end=/\]/ fold',
  \ 'start=/{/ end=/}/ fold'],
  \   'separately': {
  \       '*': {},
  \       'markdown': {
  \           'parentheses_options': 'containedin=markdownCode contained',
  \       },
  \       'lisp': {
  \           'guifgs': ['royalblue3', 'darkorange3', 'seagreen3',
  \ 'firebrick', 'darkorchid3'],
  \       },
  \       'haskell': {
  \           'parentheses': ['start=/(/ end=/)/ fold',
  \ 'start=/\[/ end=/\]/ fold', 'start=/\v\{\ze[^-]/ end=/}/ fold'],
  \       },
  \       'vim': {
  \           'parentheses_options': 'containedin=vimFuncBody',
  \       },
  \       'perl': {
  \           'syn_name_prefix': 'perlBlockFoldRainbow',
  \       },
  \       'stylus': {
  \           'parentheses': ['start=/{/ end=/}/
  \ fold contains=@colorableGroup'],
  \       },
  \       'css': 0,
  \   }
  \ }
" }}}

" lightline-gitdiff
let g:lightline_gitdiff#indicator_added = '+'
let g:lightline_gitdiff#indicator_deleted = '-'
let g:lightline_gitdiff#indicator_modified = '~'
let g:lightline_gitdiff#min_winwidth = '88'

"lightline " {{{
" Reload
function LightlineReload()
  call lightline#init()
  call lightline#colorscheme()
  call lightline#update()
endfunction
command LightlineReload call LightlineReload()
  " \ 'colorscheme': 'default',
  " \ 'colorscheme': 'wombat',
  " \ 'colorscheme': 'onedark',
  " \ 'colorscheme': 'rigel',
let g:rigel_lightline = 1
let g:lightline = {
  \ 'colorscheme': 'rigel',
  \ 'active': {
  \   'left': [['mode', 'paste'], ['gitbranch', 'gitstatus'],
  \             ['filename', 'modified']],
  \   'right': [['lineinfo'], ['percent'], ['fileformat',
  \ 'filetype', 'fileencoding', 'charvaluehex', 'spell', 'indent',
  \ 'linter_checking', 'linter_errors', 'linter_warnings', 'linter_infos',
  \ 'linter_ok']]
  \ },
  \ 'inactive': {
  \   'left': [ [ 'filename', 'modified' ] ],
  \ },
  \ 'mode_map' : {
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
  \ },
  \ 'tab_component_function': {
  \   'filename': 'LightlineTabname',
  \ },
  \ 'component_function': {
  \   'filename': 'LightlineFileName',
  \   'gitbranch': 'LightlineGitbranch',
  \   'fileformat': 'LightlineFileformat',
  \   'filetype': 'LightlineFiletype',
  \   'fileencoding': 'LightlineFileencoding',
  \   'charvaluehex': 'LightlineCharvaluehex',
  \   'indent': 'LightlineIndent',
  \   'lineinfo': 'LightlineLineinfo',
  \   'percent': 'LightlinePercent',
  \   'spell': 'LightlineSpell',
  \ },
  \   'component': {
  \     'gitstatus': '%<%{lightline_gitdiff#get_status()}',
  \   },
  \   'component_visible_condition': {
  \     'gitstatus': 'lightline_gitdiff#get_status() !=# ""',
  \   },
  \ 'component_expand': {
  \   'linter_checking': 'lightline#ale#checking',
  \   'linter_infos': 'lightline#ale#infos',
  \   'linter_warnings': 'lightline#ale#warnings',
  \   'linter_errors': 'lightline#ale#errors',
  \   'linter_ok': 'lightline#ale#ok',
  \ },
  \ 'component_type': {
  \   'readonly': 'error',
  \   'gitdiff': 'middle',
  \   'linter_checking': 'middle',
  \   'linter_infos': 'middle',
  \   'linter_warnings': 'warning',
  \   'linter_errors': 'error',
  \   'linter_ok': 'middle',
  \ },
  \ }

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
endfunction

augroup lightline_update
  autocmd!
  if has('patch-7.4.786') " 17 Jul 2015 with fixes in 7.4.888, 8.0.0974
    autocmd OptionSet tabstop,shiftwidth,expandtab :call lightline#update()
  endif
  autocmd Filetype * :call lightline#update()
augroup END

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
    elseif &tabstop && !&softtabstop && &tabstop == &shiftwidth
  \ && !&expandtab
      return '⇆'.&tabstop."↹"
    elseif &tabstop && !&softtabstop && !&shiftwidth && &expandtab
      return '⇆'.&tabstop."␣"
    elseif &tabstop == &softtabstop && &shiftwidth == &softtabstop
  \ && &expandtab
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
    return fugitive#head()
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

function! LightlineCharvaluehex()
  if winwidth(0) > 110
    let l:char = char2nr(getline('.')[col('.')-1])
    let l:fmt = l:char > 0xFF ? '0x%04X' : '0x%02X'
    return printf(l:fmt, l:char)
  endif
  return ''
endfunction

autocmd User ALELint call s:MaybeUpdateLightline()

" " Update and show lightline but only if it's visible (e.g., not in Goyo)
function! s:MaybeUpdateLightline()
  if exists('#lightline')
    call lightline#update()
  end
endfunction
nmap <leader>llu :Goyo<CR>:Goyo<CR>
" }}}

" Change cursor view:
"set ttimeoutlen=10       " Keystrokes timeout
let &t_SI.="\e[5 q"      " SI = Insert mode
let &t_SR.="\e[3 q"      " SR = Replace mode
let &t_EI.="\e[1 q"      " EI = Normal mode
" 1 - blink block
" 2 - block
" 3 - blink underscore
" 4 - underscore
" 5 - blink vertical line
" 6 - vertical line

" Vimux
" Prompt for a command to run
map <leader>vp :VimuxPromptCommand<CR>
" Run last command executed by VimuxRunCommand
map <leader>vl :VimuxRunLastCommand<CR>

" Tags handling (ctags, ctrlP, tagbar, vim-tags)
" vim-tags
let g:vim_tags_auto_generate = 0
let g:vim_tags_ignore_files = ['.gitignore', '.svnignore', '.cvsignore',
  \ '.ctagsignore']
"let vim_tags_ctags_binary = /usr/local/bin/ctags "for macOS only
nnoremap <f8> :TagsGenerate!<cr>
" :nnoremap <F8> :!ctags -R --fields=+l --tag-relative=yes --exclude=.git
"  \ --exclude=.gitignore -f .git/tags 2>/dev/null<CR>
nnoremap <silent> <leader>tb :TagbarToggle<CR>

" TagList
map <F10> :TlistToggle<cr>
vmap <F10> <esc>:TlistToggle<cr>
imap <F10> <esc>:TlistToggle<cr>

" 'ale' syntax error checker
let g:ale_linters = {'cpp': ['cppcheck', 'clang'], 'c': ['cppcheck', 'gcc'],
  \ 'python': ['flake8', 'mypy', 'pylint', 'pyright', 'pydocstyle'],
  \ 'sh': ['bashate', 'language_server', 'shell', 'shellcheck'],
  \ }

" Yankstack
nmap <leader>p <Plug>yankstack_substitute_older_paste
nmap <leader>P <Plug>yankstack_substitute_newer_paste

" Vim-indent-guides
let g:indent_guides_guide_size = 1
let g:indent_guides_color_change_percent = 3
let g:indent_guides_enable_on_vim_startup = 0

" Folding settings " {{{
" zc                          fold block
" zo                          unfold block
" zM                          fold all blocks
" zR                          unfold all blocks
" za                          toggle folding
" zf                          check :set foldmethod=manual
" set foldenable              " turn on folding
set nofoldenable            " turn off folding
" set foldmethod=syntax     " fold based on syntax
" set foldmethod=indent       " fold based on indent
set foldmethod=manual       " manual folding
" set foldmethod=marker     " fold based on markers
" set foldmarker=bigin,end  " set markers of start and end of the block
set foldcolumn=3            " show fold column left on the screen
set foldlevel=2             " fold levels opened at file opens
set foldlevelstart=99
" set foldopen=all            " autoopen fold when enter it
set foldnestmax=5           " max level of fold

let g:anyfold_fold_display=1
let g:anyfold_fold_toplevel=1
" hi Folded guibg=#272c33
" hi Folded guifg=#707784
hi Folded guibg=NONE
hi Folded guifg=#726e5c

if has("autocmd")
  autocmd BufEnter * if &filetype ==# 'vim' | setlocal foldmethod=marker
  \ foldmarker={{{,}}} | endif
  autocmd FileType javascript setlocal foldmethod=expr
  autocmd FileType javascript setlocal foldexpr=JSFolds()
  autocmd Filetype c          AnyFoldActivate
  autocmd Filetype cpp        AnyFoldActivate
  autocmd Filetype python     AnyFoldActivate
endif

function! JSFolds()
  let thisline = getline(v:lnum)
  if thisline =~? '\v^\s*$'
    return '-1'
  endif

  if thisline =~ '^import.*$'
    return 1
  else
    return indent(v:lnum) / &shiftwidth
  endif
endfunction

" Define folds automatically by indent level, but folds may be also created
" manually
augroup vimrc
  au BufReadPre * setlocal foldmethod=indent
  au BufWinEnter * if &fdm == 'indent' | setlocal foldmethod=manual | endif
augroup END
" }}}

" vim-buftabline colors
hi TabLineSel term=bold ctermfg=0 ctermbg=31 guifg=#000000 guibg=#ffc500

" Easy Align
" Start interactive EasyAlign in visual mode (e.g. vipga)
xmap ga <Plug>(EasyAlign)
" Start interactive EasyAlign for a motion/text object (e.g. gaip)
nmap ga <Plug>(EasyAlign)

set ignorecase
set smartcase
set hlsearch
set incsearch
" Search visually selected text
vnoremap <silent>* <ESC>:call VisualSearch()<CR>/<C-R>/<CR>
vnoremap <silent># <ESC>:call VisualSearch()<CR>?<C-R>/<CR>

" <leader> F3 - recursive search with grep.vim
nnoremap <leader><F3> :Rgrep<cr>
" <F3> - search in all opened buffers
nnoremap <F3> :GrepBuffer<cr>

" Enable true color
if exists('+termguicolors')
  let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
  set termguicolors
endif

" Fix to vim-surround 'S' keybin works with yankstack plug
call yankstack#setup()

" Turn off search highlight by presing space
nnoremap <silent> <leader>/ :<C-u>nohlsearch<CR><C-l>
nnoremap <Esc><Esc> :<C-u>nohlsearch<CR><C-l>

" List buffers keybinds " {{{
if v:version < 802 && !has('nvim')
  nnoremap <silent> <leader><Enter> :BufExplorer<CR>
else
  nnoremap <silent> <leader><Enter> :Buffers<CR>
  nnoremap <silent> <leader><leader><Enter> :BufExplorer<CR>
endif
nmap <F5> :BufExplorer<CR>
" }}}

" Past current buffer path instead %% in Ex editor line
cnoremap <expr> %% getcmdtype() == ':' ? expand('%:h').'/' : '%%'

" Easymotion {{{
let g:EasyMotion_smartcase = 1
" incsearch
map /  <Plug>(incsearch-forward)
map ?  <Plug>(incsearch-backward)
map g/ <Plug>(incsearch-stay)
map z/ <Plug>(incsearch-easymotion-/)
map z? <Plug>(incsearch-easymotion-?)
map zg/ <Plug>(incsearch-easymotion-stay)
nmap <leader><leader>S <Plug>(easymotion-s2)
nmap <leader><leader>2s <Plug>(easymotion-s2)
nmap <leader><leader>d <Plug>(easymotion-s2)
nmap <leader><leader>T <Plug>(easymotion-t2)
nmap <leader><leader>2t <Plug>(easymotion-t2)
map  <leader><leader>/ <Plug>(easymotion-sn)
omap <leader><leader>/ <Plug>(easymotion-tn)
" }}}

set autoindent
set pastetoggle=<F4>

" autopairing " {{{
inoremap {<CR> {<CR>}<ESC>O
inoremap {;<CR> {<CR>};<ESC>O
" }}}

" INFO Enable <ALT + p> keymap in the terminal
" execute "set <M-p>=\ep"

" Tabs navigation " {{{
" nnoremap gz :bdelete<CR>
" Open all buffers in tab
nnoremap <leader>o :tab sball<CR>
set switchbuf=usetab,newtab
" Switch to last tab
if !exists('g:lasttab')
  let g:lasttab = 1
endif
nmap <leader>tt :exe "tabn ".g:lasttab<CR>
au TabLeave * let g:lasttab = tabpagenr()
" Switch tab
nmap <leader><Left> :tabprevious<cr>
nmap <leader><Right> :tabnext<cr>
nnoremap <leader>th :tabfirst<CR>
nnoremap <leader>tn :tabnext<CR>
nnoremap <leader>tp :tabprev<CR>
nnoremap <leader>tl :tablast<CR>
nnoremap <leader>tt :tabedit<Space>
nnoremap <leader>tn :tabnext<Space>
nnoremap <leader>tm :tabmove<Space>
nnoremap <leader>td :tabclose<CR>
nnoremap <leader>to :tabonly<CR>

" Smart buffers/tabs switch
let s:tab_switcher_mode="buffers"
nnoremap <Tab> :bnext<CR>
nnoremap <S-Tab> :bprevious<CR>
function! ToggleTabSwitcherMode()
  if s:tab_switcher_mode == "buffers"
    nnoremap <Tab> :tabnext<CR>
    nnoremap <S-Tab> :tabprevious<CR>
    let s:tab_switcher_mode="tabs"
    echo "Switch tabs"
  else
    nnoremap <Tab> :bnext<CR>
    nnoremap <S-Tab> :bprevious<CR>
    let s:tab_switcher_mode="buffers"
    echo "Switch buffers"
  endif
endfunction
nnoremap <silent> <leader><Tab> :call ToggleTabSwitcherMode()<CR>
" }}}

" Search for the Current Selection
xnoremap * :<C-u>call <SID>VSetSearch('/')<CR>/<C-R>=@/<CR><CR>
xnoremap # :<C-u>call <SID>VSetSearch('?')<CR>?<C-R>=@/<CR><CR>
function! s:VSetSearch(cmdtype)
let temp = @s
norm! gv"sy
let @/ = '\V' . substitute(escape(@s, a:cmdtype.'\'), '\n', '\\n', 'g')
let @s = temp
endfunction

" Repeat the last substitution with preserved flags
nnoremap & :&&<CR>
xnoremap & :&&<CR>

" Send changed text segment to blackhole
nnoremap c "_c

" Save file as sudo on files that require root permission
cnoremap w!! execute 'silent! write !sudo tee % >/dev/null' <bar> edit!

" Turns off highlighting on the bits of code that are changed, so the line
" that is changed is highlighted but the actual text that has changed stands
" out on the line and is readable.
if &diff
    highlight! link DiffText MatchParen
endif

" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made. " {{{
" Only define it when not defined already.
if !exists(":DiffOrig")
  command DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis
        \ | wincmd p | diffthis
endif

" Replace the current buffer with the given new file. That means a new file
" will be open in a buffer while the old one will be deleted
com! -nargs=1 -complete=file Breplace edit <args>| bdelete #

function! DeleteInactiveBufs()
  "From tabpagebuflist() help, get a list of all buffers in all tabs
  let tablist = []
  for i in range(tabpagenr('$'))
    call extend(tablist, tabpagebuflist(i + 1))
  endfor

  "Below originally inspired by Hara Krishna Dara and Keith Roberts
  "http://tech.groups.yahoo.com/group/vim/message/56425
  let nWipeouts = 0
  for i in range(1, bufnr('$'))
    if bufexists(i) && !getbufvar(i,"&mod") && index(tablist, i) == -1
      " bufno exists AND isn't modified AND isn't in the list of buffers open
      " in windows and tabs
      silent exec 'bwipeout' i
      let nWipeouts = nWipeouts + 1
    endif
  endfor
  echomsg nWipeouts . ' buffer(s) wiped out'
endfunction
" }}}

command! Ball :call DeleteInactiveBufs()

" NERDTree
let NERDTreeShowHidden=1
let NERDTreeShowBookmarks=1
let NERDTreeIgnore=['\.pyc$', '\.vim$', '\~$', '\.git$', '.DS_Store']
" Close nerdtree and vim on close file
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType")
  \ && b:NERDTreeType == "primary") | q | endif
noremap <F2> :NERDTreeToggle<CR>
noremap <leader><F2> :NERDTreeFind<cr>

" Ranger integration
let g:ranger_map_keys = 0
let g:NERDTreeHijackNetrw = 0 " add this line if you use NERDTree
let g:ranger_replace_netrw = 1 " open ranger when vim open a directory
map <leader>rr :Ranger<CR>
map <leader>rt :RangerCurrentFileExistingOrNewTab<CR>
map <leader>rw :RangerWorkingDirectory<CR>
map <leader>re :RangerWorkingDirectoryExistingOrNewTab<CR>
let s:uname_host = system("echo -n \"$(uname -n)\"")

" Avoid unintentional switches to Ex mode.
nmap Q q

" Backup and Swap files settings " {{{
" Save your backup files to a less annoying place than the current directory.
" If you have .vim-backup in the current directory, it'll use that.
" Otherwise it saves it to ~/.vim/backup or .
set backup
set backupdir-=.
set backupdir+=.
set backupdir-=~/
if isdirectory($HOME . '/.vim/backup') == 0
  :silent !mkdir -p ~/.vim/backup >/dev/null 2>&1
endif
set backupdir^=~/.vim/backup//
set writebackup

" Save your swap files to a less annoying place than the current directory.
" If you have .vim-swap in the current directory, it'll use that.
" Otherwise it saves it to ~/.vim/swap, ~/tmp or .
set swapfile
set updatecount=100
if isdirectory($HOME . '/.vim/swap') == 0
  :silent !mkdir -p ~/.vim/swap >/dev/null 2>&1
endif
set directory^=~/.vim/swap//

" Viminfo stores the the state of your previous editing session
if has('nvim')
  set viminfo+=n~/.vim/nviminfo
else
  set viminfo+=n~/.vim/viminfo
endif

if exists("+undofile")
  " Undofile - This allows you to use undos after exiting and restarting
  " This, like swap and backup files, uses .vim-undo first, then ~/.vim/undo
  " :help undo-persistence
  " This is only present in 7.3+
  set undofile
  if has('nvim')
    if isdirectory($HOME . '/.vim/undo-nvim') == 0
      :silent !mkdir -p ~/.vim/undo-nvim > /dev/null 2>&1
    endif
    set undodir^=~/.vim/undo-nvim//
  else
    if isdirectory($HOME . '/.vim/undo-vim') == 0
      :silent !mkdir -p ~/.vim/undo-vim > /dev/null 2>&1
    endif
    set undodir^=~/.vim/undo-vim//
  endif
endif

" Viewdir
if isdirectory($HOME . '/.vim/view') == 0
  :silent !mkdir -p ~/.vim/view >/dev/null 2>&1
endif
set viewdir=~/.vim/view
" }}}

" Highlight TODO, FIXME, NOTE, etc. " {{{
let g:my_todo_highlight_config = {
\  'FIXME': {
\    'gui_fg_color': '#ffffff',
\    'gui_bg_color': '#bd1314',
\    'cterm': 'bold',
\    'cterm_fg_color': 'white',
\    'cterm_bg_color': '204'
\  },
\  'BUG': {
\    'gui_fg_color': '#ffffff',
\    'gui_bg_color': '#bd1314',
\    'cterm': 'bold',
\    'cterm_fg_color': 'white',
\    'cterm_bg_color': '204'
\  },
\  'WARN': {
\    'gui_fg_color': '#ffffff',
\    'gui_bg_color': '#bd1314',
\    'cterm': 'bold',
\    'cterm_fg_color': 'white',
\    'cterm_bg_color': '204'
\  },
\  'XXX': {
\    'gui_fg_color': '#ffffff',
\    'gui_bg_color': '#bd1314',
\    'cterm': 'bold',
\    'cterm_fg_color': 'white',
\    'cterm_bg_color': '204'
\  },
\  'TODO': {
\    'gui_fg_color': '#ffffff',
\    'gui_bg_color': '#ff6524',
\    'cterm': 'bold',
\    'cterm_fg_color': 'white',
\    'cterm_bg_color': '214'
\  },
\  'INFO': {
\    'gui_fg_color': '#ffffff',
\    'gui_bg_color': '#ff6524',
\    'cterm': 'bold',
\    'cterm_fg_color': 'white',
\    'cterm_bg_color': '214'
\  },
\  'DEBUG': {
\    'gui_fg_color': '#ffffff',
\    'gui_bg_color': '#a048ff',
\    'cterm': 'bold',
\    'cterm_fg_color': 'white',
\    'cterm_bg_color': '214'
\  },
\  'QUESTION': {
\    'gui_fg_color': '#ffffff',
\    'gui_bg_color': '#ff6524',
\    'cterm': 'bold',
\    'cterm_fg_color': 'white',
\    'cterm_bg_color': '214'
\  },
\  'NOTE': {
\    'gui_fg_color': '#ffffff',
\    'gui_bg_color': '#1791c2',
\    'cterm': 'bold',
\    'cterm_fg_color': 'white',
\    'cterm_bg_color': '214'
\  },
\  'CHANGED': {
\    'gui_fg_color': '#ffffff',
\    'gui_bg_color': '#1791c2',
\    'cterm': 'bold',
\    'cterm_fg_color': 'white',
\    'cterm_bg_color': '214'
\  },
\  'IDEA': {
\    'gui_fg_color': '#ffffff',
\    'gui_bg_color': '#59932b',
\    'cterm': 'bold',
\    'cterm_fg_color': 'white',
\    'cterm_bg_color': '214'
\  },
\  'HACK': {
\    'gui_fg_color': '#ffffff',
\    'gui_bg_color': '#59932b',
\    'cterm': 'bold',
\    'cterm_fg_color': 'white',
\    'cterm_bg_color': '214'
\  },
\  'TRICKY': {
\    'gui_fg_color': '#ffffff',
\    'gui_bg_color': '#59932b',
\    'cterm': 'bold',
\    'cterm_fg_color': 'white',
\    'cterm_bg_color': '214'
\  },
\ }
" Creates annotation group and highlight it according to the config
function! s:MyCreateAnnotationGroup(annotation, config)
  " Set group name -> my_annotation
  let l:group_name = 'my_' . tolower(a:annotation)

  " Make group for annotation where its pattern matches and is inside comment
  execute 'augroup ' . l:group_name
    autocmd!
    execute 'autocmd Syntax * syntax match ' . l:group_name .
      \ ' /\v\C\_.<' . a:annotation . '(:|>)/hs=s+1 containedin=.*Comment.*'
  augroup END

  " Highlight the group according to the config
  if has('termguicolors')
    execute 'hi ' l:group_name .
      \ ' guifg = ' . get(a:config, 'gui_fg_color', '#ffffff') .
      \ ' guibg = ' . get(a:config, 'gui_bg_color', '#ef9c3f') .
      \ ' cterm = ' . get(a:config, 'cterm', '')
  else
    execute 'hi ' l:group_name .
      \ ' ctermfg = ' . get(a:config, 'cterm_fg_color', 'white') .
      \ ' ctermbg = ' . get(a:config, 'cterm_bg_color', '214')
      \ ' cterm = ' . get(a:config, 'cterm', '')
  endif
endfunction

" Highlights the user specified custom annotation groups
if exists("g:my_todo_highlight_config")
  for [annotation, config] in items(g:my_todo_highlight_config)
    call s:MyCreateAnnotationGroup(annotation, config)
  endfor
endif
" }}}

" Colors highlighting
let g:colorizer_auto_color=0
" Highlight colors toggle
noremap <leader>ct :ColorToggle<CR>

" Indexer settings
let g:indexer_disableCtagsWarning=1

" FZF settings " {{{
" Ignore files ignored in .gitignore but show hidden
let $FZF_DEFAULT_COMMAND = 'ag --hidden --ignore .git -g ""'
let $FZF_DEFAULT_OPTS .= ' --inline-info'
" let g:fzf_preview_window = ['right:50%', 'ctrl-/']
" let g:fzf_preview_window = ['up:40%:hidden', 'ctrl-/']
let g:fzf_preview_window = ['up:50%', 'ctrl-/']
" let g:fzf_preview_window = []

" if exists('$TMUX')
"   let g:fzf_layout = { 'tmux': '-p90%,60%' }
" else
"   let g:fzf_layout = { 'window': { 'width': 0.9, 'height': 0.6 } }
" endif
let g:fzf_layout = { 'window': { 'width': 1.0, 'height': 1.0 } }

" All files
command! -nargs=? -complete=dir AF
  \ call fzf#run(fzf#wrap(fzf#vim#with_preview({
  \ 'source': 'fd --type f --hidden --follow --exclude .git --no-ignore .
  \ '.expand(<q-args>)
  \ })))

let g:fzf_colors =
\ { 'fg':      ['fg', 'Normal'],
  \ 'bg':      ['bg', 'Normal'],
  \ 'hl':      ['fg', 'Comment'],
  \ 'fg+':     ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
  \ 'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
  \ 'hl+':     ['fg', 'Statement'],
  \ 'info':    ['fg', 'PreProc'],
  \ 'border':  ['fg', 'Ignore'],
  \ 'prompt':  ['fg', 'Conditional'],
  \ 'pointer': ['fg', 'Exception'],
  \ 'marker':  ['fg', 'Keyword'],
  \ 'spinner': ['fg', 'Label'],
  \ 'header':  ['fg', 'Comment'] }

" Terminal buffer options for fzf
autocmd! FileType fzf
autocmd  FileType fzf set noshowmode noruler nonu

if v:version >= 802 || has('nvim')
  nnoremap <silent> <leader>f        :Files<CR>
  nnoremap <silent> <C-p>            :Files<CR>
  nnoremap <silent> <leader>C        :Colors<CR>
  nnoremap <silent> <leader>l        :Lines<CR>
  " nnoremap <silent> <leader>ag       :Ag <C-R><C-W><CR>
  " nnoremap <silent> <leader>AG       :Ag <C-R><C-A><CR>
  " xnoremap <silent> <leader>ag       y:Ag <C-R>"<CR>
  nnoremap <silent> <leader>rg       :FZFRg<CR>
  nnoremap <silent> <leader>RG       :FZFRg <C-R><C-W><CR>
  xnoremap <silent> <leader>rg       y:FZFRg <C-R>"<CR>
  nnoremap <silent> <leader>`        :Marks<CR>
  nnoremap <silent> q:               :History:<CR>
  nnoremap <silent> q/               :History/<CR>
  nnoremap <silent> <leader>h        :History<CR>

  " inoremap <expr> <c-x><c-t> fzf#complete('tmuxwords.rb --all-but-current
  "   \ --scroll 498 --min 5')
  " map <c-x><c-k> <plug>(fzf-complete-word)
  imap <c-x><c-f> <plug>(fzf-complete-path)
  inoremap <expr> <c-x><c-d> fzf#vim#complete#path('blsd')
  imap <c-x><c-j> <plug>(fzf-complete-file-ag)
  imap <c-x><c-l> <plug>(fzf-complete-line)

  " nmap <leader><tab> <plug>(fzf-maps-n)
  " xmap <leader><tab> <plug>(fzf-maps-x)
  " omap <leader><tab> <plug>(fzf-maps-o)
endif

function! s:plug_help_sink(line)
  let dir = g:plugs[a:line].dir
  for pat in ['doc/*.txt', 'README.md']
    let match = get(split(globpath(dir, pat), "\n"), 0, '')
    if len(match)
      execute 'tabedit' match
      return
    endif
  endfor
  tabnew
  execute 'Explore' dir
endfunction

command! PlugHelp call fzf#run(fzf#wrap({
  \ 'source': sort(keys(g:plugs)),
  \ 'sink':   function('s:plug_help_sink')}))

function! RipgrepFzf(query, fullscreen)
  let command_fmt = 'rg --column --line-number --no-heading
  \ --color=always --smart-case %s || true'
  let initial_command = printf(command_fmt, shellescape(a:query))
  let reload_command = printf(command_fmt, '{q}')
  let options = {'options': ['--phony', '--query', a:query, '--bind',
  \ 'change:reload:'.reload_command]}
  let options = fzf#vim#with_preview(options, 'right', 'ctrl-/')
  call fzf#vim#grep(initial_command, 1, options, a:fullscreen)
endfunction

command! -nargs=* -bang FZFRG call RipgrepFzf(<q-args>, <bang>0)

command! -bang -nargs=* FZFRg
  \ call fzf#vim#grep(
  \ "rg --colors 'match:bg:yellow' --colors 'match:fg:black'
  \ --colors 'match:style:nobold' --colors 'path:fg:cyan'
  \ --colors 'path:style:bold' --colors 'line:fg:yellow'
  \ --colors 'line:style:bold' --line-number --no-heading
  \ --color=always --smart-case --trim -- ".shellescape(<q-args>), 1,
  \ fzf#vim#with_preview('up:50%', 'ctrl-/'), <bang>0)

command! -bang -nargs=* Ag
  \ call fzf#vim#ag(<q-args>, '--column --numbers --smart-case --color
  \ --color-path "36;1" --color-match "30;43" --color-line-number "33;1"',
  \ fzf#vim#with_preview('up:50%', 'ctrl-/'), <bang>0)
" }}}

" Quickly edit/reload this configuration file
nnoremap <leader>ve :edit $MYVIMRC<CR>
nnoremap <leader>vs :source $MYVIMRC<CR>

" Autoclose preview window after autocompletion is done
autocmd CompleteDone * pclose

" Autoclose location list before window change
map <c-h> :lclose<CR><C-w>h
map <c-j> :lclose<CR><C-w>j
map <c-k> :lclose<CR><C-w>k
map <c-l> :lclose<CR><C-w>l

" Set the file type for files that are in use on the system but do not yet
" have a type.
augroup filetypedetect
  au BufRead,BufNewFile .tmux.conf*       setlocal ft=tmux
  au BufRead,BufNewFile conkyrc*          setlocal ft=conf
  au BufRead,BufNewFile webserv.conf*     setlocal ft=nginx
augroup END

" Delete a buffer without closing the window, create a scratch buffer if no
" buffers left " {{{
function s:Kwbd(kwbdStage)
  if(a:kwbdStage == 1)
    if(&modified)
      let answer = confirm("This buffer has been modified.
  \ Are you sure you want to delete it?", "&Yes\n&No", 2)
      if(answer != 1)
        return
      endif
    endif
    if(!buflisted(winbufnr(0)))
      bd!
      return
    endif
    let s:kwbdBufNum = bufnr("%")
    let s:kwbdWinNum = winnr()
    windo call s:Kwbd(2)
    execute s:kwbdWinNum . 'wincmd w'
    let s:buflistedLeft = 0
    let s:bufFinalJump = 0
    let l:nBufs = bufnr("$")
    let l:i = 1
    while(l:i <= l:nBufs)
      if(l:i != s:kwbdBufNum)
        if(buflisted(l:i))
          let s:buflistedLeft = s:buflistedLeft + 1
        else
          if(bufexists(l:i) && !strlen(bufname(l:i)) && !s:bufFinalJump)
            let s:bufFinalJump = l:i
          endif
        endif
      endif
      let l:i = l:i + 1
    endwhile
    if(!s:buflistedLeft)
      if(s:bufFinalJump)
        windo if(buflisted(winbufnr(0))) | execute "b! " . s:bufFinalJump
  \ | endif
      else
        enew
        let l:newBuf = bufnr("%")
        windo if(buflisted(winbufnr(0))) | execute "b! " . l:newBuf | endif
      endif
      execute s:kwbdWinNum . 'wincmd w'
    endif
    if(buflisted(s:kwbdBufNum) || s:kwbdBufNum == bufnr("%"))
      execute "bd! " . s:kwbdBufNum
    endif
    if(!s:buflistedLeft)
      set buflisted
      set bufhidden=delete
      set buftype=
      setlocal noswapfile
    endif
  else
    if(bufnr("%") == s:kwbdBufNum)
      let prevbufvar = bufnr("#")
      if(prevbufvar > 0 && buflisted(prevbufvar)
  \ && prevbufvar != s:kwbdBufNum)
        b #
      else
        bn
      endif
    endif
  endif
endfunction

command! Kwbd call s:Kwbd(1)
nnoremap <silent> <Plug>Kwbd :<C-u>Kwbd<CR>
nmap gz <Plug>Kwbd
" }}}

" Tinykeymap settings (faster win resize)
" let g:tinykeymaps_default=['buffers', 'diff', 'filter', 'folds',
"       \ 'lines', 'loc', 'qfl', 'tabs', 'undo', 'windows']
call tinykeymap#EnterMap('windows', '<C-w>', {'name': 'windows mode'})

" GPG settings " {{{
if has("autocmd")
  " Tell the GnuPG plugin to armor new files.
  let g:GPGPreferArmor=1

  " Tell the GnuPG plugin to sign new files.
  let g:GPGPreferSign=1

  " Use gpg(2) to take advantage of the agent.
  let g:GPGExecutable="/usr/bin/gpg2"

  " Take advantage of the running agent
  let g:GPGUseAgent=1

  " Override default set of file patterns
  let g:GPGFilePattern='*.\(gpg\|asc\|pgp\|pw\)'

  augroup GnuPGExtra
    " Set extra file options.
    autocmd BufReadCmd,FileReadCmd *.\(pw\) call SetGPGOptions()

    " Automatically close unmodified files after inactivity.
    autocmd CursorHold *.\(pw\) quit
  augroup END
  function SetGPGOptions()
    " Set the filetype for syntax highlighting.
    set filetype=gpgpass

    " Set updatetime to 5 minutes.
    set updatetime=300000

    " Fold at markers.
    set foldmethod=marker

    " Automatically close all folds.
    set foldclose=all

    " Only open folds with insert commands.
    set foldopen=insert
  endfunction
endif " has ("autocmd")
" }}}

" Close quickfix window
noremap <leader>zc :cclose<CR><C-l>
" Close location window
noremap <leader>zl :lclose<CR><C-l>
" Close preview window
noremap <leader>zp :pclose<CR><C-l>

" Prosession settings
let g:prosession_tmux_title = 0
let g:prosession_tmux_title_format = "vim - @@@"

" Terminal in vim buffer settings
" make terminal window in vim buffer inactive
if has('nvim')
  nnoremap <leader>t :split term://zsh<CR>
  tnoremap <C-x> <C-\><C-n>:q!<CR>
else
  nnoremap <leader>t :term<CR>
  tnoremap <C-x> <C-w>N:bdelete!<CR>
endif

" Indexer settings (fix ctags generation for vimprj plugin)
let g:indexer_ctagsCommandLineOptions =
  \ '-R --fields=+iaSl --c++-kinds=+p --extra=+q'

" Vim-mergetool settings " {{{
nmap <leader>mt <plug>(MergetoolToggle)

nmap <expr> <S-Left> &diff? '<Plug>(MergetoolDiffExchangeLeft)' : '<S-Left>'
nmap <expr> <S-Right> &diff? '<Plug>(MergetoolDiffExchangeRight)' :'<S-Right>'
nmap <expr> <S-Down> &diff? '<Plug>(MergetoolDiffExchangeDown)' : '<S-Down>'
nmap <expr> <S-Up> &diff? '<Plug>(MergetoolDiffExchangeUp)' : '<S-Up>'
nmap <expr> <Up> &diff ? '[c' : '<Up>'
nmap <expr> <Down> &diff ? ']c' : '<Down>'

" (m) - for working tree version of MERGED file
" (r) - for 'remote' revision
" (b) - for 'base', common ancestor of two branches
" (R) - for REMOTE
" (L) - for LOCAL
" (B) - BASE (what diffirence with 'b' - ?)
" (,) - make split horisontal instead vertical (default)
let g:mergetool_layout = 'mr'

" Possible values: 'local' (default), 'remote', 'base', 'unmodified'
let g:mergetool_prefer_revision = 'local'

" Turn off syntax and spell checking highlighting for all splits
function s:on_mergetool_set_layout(split)
  set wrap
  set syntax=off
  set nospell
  if a:split["layout"] ==# 'mr,b' && a:split["split"] ==# 'b'
    set nodiff
    set syntax=on
    resize 15
  endif
endfunction
let g:MergetoolSetLayoutCallback = function('s:on_mergetool_set_layout')

" Smart quit window in merge mode
function s:QuitWindow()
  " If we're in merge mode, exit
  if get(g:, 'mergetool_in_merge_mode', 0)
    call mergetool#stop()
    return
  endif
  if &diff
    " Quit diff mode intelligently...
  endif
  quit
endfunction
command QuitWindow call s:QuitWindow()
nnoremap <silent> <leader>q :QuitWindow<CR>
" }}}

" Restore_view settings
" Views of some files not to be saved
" let g:loaded_restore_view = ['*/.vimrc']

" Diff mode toggle (with SmartRelativenumbers support) {{{
function ToggleDiff ()
  if (&diff)
    if get(g:, 'SmartRelativenumbersBckp', 0)
      call ToggleSmartRelativenumbers()
      let g:SmartRelativenumbersBckp = 0
    endif
    set nodiff noscrollbind
    if get(g:, 'WrapBckp', 0)
      set wrap
    endif
    if get(g:, 'RltvNumberBckp', 0)
      set relativenumber
    endif
    wincmd w
    if get(g:, 'WrapBckp', 0)
      set wrap
    endif
    if get(g:, 'RltvNumberBckp', 0)
      set relativenumber
    endif
    wincmd w
  else
    " Enable diff options in both windows; balance the sizes, too
    if exists('#SmartRelativenumbers#InsertEnter')
      let g:SmartRelativenumbersBckp = 1
      call ToggleSmartRelativenumbers()
    endif
    let g:WrapBckp = (&wrap)
    let g:RltvNumberBckp = (&relativenumber)
    wincmd =
    set diff scrollbind number norelativenumber nowrap
    wincmd w
    set diff scrollbind number norelativenumber nowrap
    wincmd w
  endif
endfunction
nnoremap <silent> <leader><F9> :call ToggleDiff()<CR>
" }}}

" Dictionary and completion settings " {{{
set complete=.,k,w,b,u,t,i,kspell
set shortmess+=c
set shortmess-=S
set completeopt=menuone,longest,preview
" set dictionary+=$GIT_WORKSPACE/vim/vimdict

" Autocomplpop settings
let g:acp_enableAtStartup = 1
let g:acp_mappingDriven = 0
let g:acp_ignorecaseOption = 1
" let g:acp_behaviorSnipmateLength = 3
let g:acp_completeOption = '.,k,w,b,u,t,i,kspell'

" Navigate the complete menu items like CTRL+n / CTRL+p would.
inoremap <expr> <Down> pumvisible() ? "<C-n>" :"<Down>"
inoremap <expr> <Up> pumvisible() ? "<C-p>" : "<Up>"
inoremap <expr> <C-j> pumvisible() ? "<C-N>" : "<C-j>"
inoremap <expr> <C-k> pumvisible() ? "<C-p>" : "<C-k>"
" Select the complete menu item like CTRL+y would.
inoremap <expr> <Right> pumvisible() ? "<C-y>" : "<Right>"
inoremap <expr> <CR> pumvisible() ? "<C-y>" :"<CR>"
" Cancel the complete menu item like CTRL+e would.
inoremap <expr> <Left> pumvisible() ? "<C-e>" : "<Left>"

" Re-create spl files for additional vocabularies
for d in glob('~/.vim/spell/*.add', 1, 1)
  if filereadable(d) && (!filereadable(d . '.spl') || getftime(d) >
  \ getftime(d . '.spl'))
    exec 'mkspell! ' . fnameescape(d)
  endif
endfor

" Toggle spell checking
map <leader>ssa :setlocal spell! spelllang=en_us,ru_yo<cr>
map <leader>sse :setlocal spell! spelllang=en_us<cr>
map <leader>ssr :setlocal spell! spelllang=ru_yo<cr>

" Enable spell checking by default
" set spell spelllang=en_us,ru_yo

" Vim-xkbswitch settings (auto switch to English keyboard layout in Normal and
" command mode {{{
let g:XkbSwitchEnabled = 1
let s:uname = system("echo -n \"$(uname)\"")
let s:uname_host = system("echo -n \"$(uname -n)\"")
if !v:shell_error && s:uname == "Linux" && (s:uname_host == "pc-home"
  \ || s:uname_host == "laptop-acer")
  let g:XkbSwitchLib = "/usr/lib/libxkbswitch.so"
elseif !v:shell_error && s:uname == "Darwin" && s:uname_host == "pc-home"
  let g:XkbSwitchLib = "/Users/awerebea/.local/lib/libxkbswitch.dylib"
elseif !v:shell_error && s:uname == "Linux" && system("echo -n \"$(whoami)\"")
  \ == "root"
  let g:XkbSwitchLib = "/usr/lib/libxkbswitch.so"
endif
" }}}

" Colors for words that failed spell check {{{
" Word not recognized
hi clear SpellBad
hi SpellBad cterm=underline ctermfg=blue
hi SpellBad gui=underline guifg=DeepSkyBlue
" Word not capitalized
hi clear SpellCap
hi SpellCap cterm=underline ctermfg=red
hi SpellCap gui=underline guifg=firebrick3
" Word is rare
hi clear SpellRare
hi SpellRare cterm=underline ctermfg=green
hi SpellRare gui=underline guifg=LimeGreen
" Wrong spelling for selected region
hi clear SpellLocal
hi SpellLocal cterm=underline ctermfg=yellow
hi SpellLocal gui=underline guifg=DarkGoldenrod1
" }}}

inoremap <expr> <c-x><c-k> SpellCheck("\<c-x>\<c-k>")
nnoremap z= :<c-u>call SpellCheck()<cr>z=
function! SpellCheck(...)
  let s:spell_restore = &spell
  set spell
  augroup restore_spell_option
    autocmd!
    autocmd CursorMoved,CompleteDone <buffer> let &spell = s:spell_restore |
          \ autocmd! restore_spell_option
  augroup END
  return a:0 ? a:1 : ''
endfunction
" }}}

" settings (Ultisnips, SnipMate) {{{
" Trigger configuration. You need to change this to something other than <tab>
" if you use one of the following:
" - https://github.com/Valloric/YouCompleteMe
" - https://github.com/nvim-lua/completion-nvim
" let g:UltiSnipsExpandTrigger="<tab>"
" let g:UltiSnipsJumpForwardTrigger="<tab>"
" let g:UltiSnipsJumpBackwardTrigger="<s-tab>"
let g:UltiSnipsEditSplit="vertical"
let g:UltiSnipsSnippetsDir="~/.vim/UltiSnips"
nnoremap <leader>sne :UltiSnipsEdit<cr>
let g:snipMate = {}
let g:snipMate.snippet_version = 1
imap <s-tab> <Plug>snipMateShow
" }}}

" Run/compile from vim {{{
if has("autocmd")
  if has('nvim')
    autocmd FileType python map <buffer> <F9>
          \ :w!<CR>:sp term://python3 %<CR>a
    autocmd FileType python imap <buffer> <F9>
          \ <esc>:w!<CR>:sp term://python3 %<CR>a
  else
    autocmd FileType python map <buffer> <F9>
          \ :w<CR>:exec '!clear; python3' shellescape(@%, 1)<CR>
    autocmd FileType python imap <buffer> <F9>
          \ <esc>:w<CR>:exec '!clear; python3' shellescape(@%, 1)<CR>
  endif
  autocmd FileType markdown map <buffer> <F9>
        \ :CocCommand markdown-preview-enhanced.openPreview<CR>
  autocmd FileType cpp map <buffer> <F9> :make<CR>
  autocmd FileType c map <buffer> <F9> :make<CR>
endif
" }}}

" Quick launch last used macros
nnoremap <leader>2 @@

" Write read only-file trick
cnoremap w!! execute 'silent! write !sudo tee % >/dev/null' <bar> edit!

" Like gJ, but always remove spaces
fun! s:join_spaceless()
    execute 'normal! gJ'
    " Remove character under the cursor if it's whitespace.
    if matchstr(getline('.'), '\%' . col('.') . 'c.') =~ '\s'
        execute 'normal! dw'
    endif
endfun
" Map it to a key
nnoremap <Leader>J :call <SID>join_spaceless()<CR>

" Use underscore as word separator
set iskeyword-=_

" ale settings {{{
" lightline-ale icons
let g:lightline#ale#indicator_checking = "\uf110"
let g:lightline#ale#indicator_infos = "\uf129"
let g:lightline#ale#indicator_warnings = "\uf071"
let g:lightline#ale#indicator_errors = "\uf05e"
let g:lightline#ale#indicator_ok = "\uf00c"

" enable(1)/disable(0) ale at startup
let g:ale_enabled = 1
" disable ale LSP to work with coc.nvim simultaneously
" let g:ale_disable_lsp = 1

if has('popupwin') || has('nvim')
  " use floating windows for errors and warnings
  let g:ale_floating_preview = 1
  let g:ale_floating_window_border = ['│', '─', '╭', '╮', '╯', '╰']
  " autopopup detail window with cursor on the line
  let g:ale_cursor_detail = 0
endif

" enable/disable completion
let g:ale_completion_enabled = 0

" toggle ale linting
nnoremap <leader>at :ALEToggle<cr>
" show full message in split window
nnoremap <leader>ad :ALEDetail<cr>

nmap <silent> [g <Plug>(ale_previous_wrap)
nmap <silent> ]g <Plug>(ale_next_wrap)

" go-to keymaps
nmap <silent> gd :ALEGoToDefinition<cr>
nmap <silent> gy :ALEGoToTypeDefinition<cr>
nmap <silent> gr :ALEFindReferences<cr>

" coc settings {{{
let check_result = system("command -v node")
if v:shell_error == 0
  " Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
  " delays and poor user experience.
  set updatetime=300

  " Don't pass messages to |ins-completion-menu|.
  set shortmess+=c

  " Give more space for displaying messages.
  " set cmdheight=2

  " Always show the signcolumn, otherwise it would shift the text each time
  " diagnostics appear/become resolved.
  " if has("nvim-0.5.0") || has("patch-8.1.1564")
  "   " Recently vim can merge signcolumn and number column into one
  "   set signcolumn=number
  " else
  "   set signcolumn=yes
  " endif

  " Use tab for trigger completion with characters ahead and navigate.
  " NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
  " other plugin before putting this into your config.
  " inoremap <silent><expr> <TAB>
  "       \ pumvisible() ? "\<C-n>" :
  "       \ <SID>check_back_space() ? "\<TAB>" :
  "       \ coc#refresh()
  " inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

  function! s:check_back_space() abort
    let col = col('.') - 1
    return !col || getline('.')[col - 1]  =~# '\s'
  endfunction

  " Disable Coc suggestions by default, use manual trigger.
  autocmd BufEnter * let b:coc_suggest_disable = 1

  " Use <c-space> to trigger completion.
  if has('nvim')
    inoremap <silent><expr> <c-space> coc#refresh()
  else
    inoremap <silent><expr> <c-@> coc#refresh()
  endif

  " Make <CR> auto-select the first completion item and notify coc.nvim to
  " format on enter, <cr> could be remapped by other vim plugin
  inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm()
                                \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

  " Use `[g` and `]g` to navigate diagnostics (use ale instead)
  " nmap <silent> [g <Plug>(coc-diagnostic-prev)
  " nmap <silent> ]g <Plug>(coc-diagnostic-next)

  " GoTo code navigation.
  nmap <silent> gd <Plug>(coc-definition)
  nmap <silent> gy <Plug>(coc-type-definition)
  nmap <silent> gr <Plug>(coc-references)
  nmap <silent> gi <Plug>(coc-implementation)

  " Use K to show documentation in preview window.
  nnoremap <silent> K :call <SID>show_documentation()<CR>

  function! s:show_documentation()
    if (index(['vim','help'], &filetype) >= 0)
      execute 'h '.expand('<cword>')
    elseif (coc#rpc#ready())
      call CocActionAsync('doHover')
    else
      execute '!' . &keywordprg . " " . expand('<cword>')
    endif
  endfunction

  " Highlight the symbol and its references when holding the cursor.
  " autocmd CursorHold * silent call CocActionAsync('highlight')

  " Symbol renaming.
  nmap <leader>rn <Plug>(coc-rename)

  " Formatting selected code.
  xmap <leader>cf  <Plug>(coc-format-selected)
  nmap <leader>cf  <Plug>(coc-format-selected)

  augroup mygroup
    autocmd!
    " Setup formatexpr specified filetype(s).
    autocmd FileType typescript,json
          \ setl formatexpr=CocAction('formatSelected')
    " Update signature help on jump placeholder.
    autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
  augroup end

  " Applying codeAction to the selected region.
  " Example: `<leader>aap` for current paragraph
  xmap <leader>a  <Plug>(coc-codeaction-selected)
  nmap <leader>a  <Plug>(coc-codeaction-selected)

  " Remap keys for applying codeAction to the current buffer.
  nmap <leader>ac  <Plug>(coc-codeaction)
  " Apply AutoFix to problem on the current line.
  nmap <leader>qf  <Plug>(coc-fix-current)

  " Map function and class text objects
  " NOTE: Requires 'textDocument.documentSymbol' supportfrom the language
  " server.
  xmap if <Plug>(coc-funcobj-i)
  omap if <Plug>(coc-funcobj-i)
  xmap af <Plug>(coc-funcobj-a)
  omap af <Plug>(coc-funcobj-a)
  xmap ic <Plug>(coc-classobj-i)
  omap ic <Plug>(coc-classobj-i)
  xmap ac <Plug>(coc-classobj-a)
  omap ac <Plug>(coc-classobj-a)

  " Remap <C-f> and <C-b> for scroll float windows/popups.
  if has('nvim-0.4.0') || has('patch-8.2.0750')
    nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ?
          \ coc#float#scroll(1) : "\<C-f>"
    nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ?
          \ coc#float#scroll(0) : "\<C-b>"
    inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ?
          \ "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
    inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ?
          \ "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
    vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ?
          \ coc#float#scroll(1) : "\<C-f>"
    vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ?
          \ coc#float#scroll(0) : "\<C-b>"
  endif

  " Use CTRL-S for selections ranges.
  " Requires 'textDocument/selectionRange' support of language server.
  nmap <silent> <C-s> <Plug>(coc-range-select)
  xmap <silent> <C-s> <Plug>(coc-range-select)

  " Add `:Format` command to format current buffer.
  command! -nargs=0 Format :call CocAction('format')

  " Add `:Fold` command to fold current buffer.
  command! -nargs=? Fold :call CocAction('fold', <f-args>)

  " Add `:OR` command for organize imports of the current buffer.
  command! -nargs=0 OR :call CocAction('runCommand',
        \ 'editor.action.organizeImport')

  " Add (Neo)Vim's native statusline support.
  " NOTE: Please see `:h coc-status` for integrations with external plugins
  " that provide custom statusline: lightline.vim, vim-airline.
  " set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

  " Mappings for CoCList
  " Show all diagnostics.
  nnoremap <silent><nowait> \ca  :<C-u>CocList diagnostics<cr>
  " Manage extensions.
  nnoremap <silent><nowait> \ce  :<C-u>CocList extensions<cr>
  " Show commands.
  nnoremap <silent><nowait> \cc  :<C-u>CocList commands<cr>
  " Find symbol of current document.
  nnoremap <silent><nowait> \co  :<C-u>CocList outline<cr>
  " Search workspace symbols.
  nnoremap <silent><nowait> \cs  :<C-u>CocList -I symbols<cr>
  " Do default action for next item.
  nnoremap <silent><nowait> \cj  :<C-u>CocNext<CR>
  " Do default action for previous item.
  nnoremap <silent><nowait> \ck  :<C-u>CocPrev<CR>
  " Resume latest coc list.
  nnoremap <silent><nowait> \cp  :<C-u>CocListResume<CR>

  " root patterns (for go to definition)
  " autocmd FileType python let b:coc_root_patterns = ['*.py', '.git', '.env']

  " coc-explorer
  nnoremap <leader>e :CocCommand explorer<CR>
endif
" }}}

" lightline-gitdiff settings
let g:lightline#gitdiff#indicator_added = '+'
let g:lightline#gitdiff#indicator_deleted = '-'
let g:lightline#gitdiff#indicator_modified = '~'
let g:lightline#gitdiff#separator = ' '

" identline settings
let g:indentLine_char = '│'

" vim-indent-guides settings
" let g:indent_guides_enable_on_vim_startup = 1
let g:indent_guides_auto_colors = 0
let g:indent_guides_guide_size = 1
autocmd VimEnter,Colorscheme * :hi IndentGuidesOdd
      \ guibg=#303030 guifg=#626262 ctermbg=236 ctermfg=241
autocmd VimEnter,Colorscheme * :hi IndentGuidesEven
      \ guibg=#303030 guifg=#626262 ctermbg=236 ctermfg=241

" vim-which-key
set timeoutlen=500       " Keystrokes timeout
nnoremap <silent> <leader> :WhichKey '<Space>'<CR>

" far.vim (find and replace)
let g:far#enable_undo=1
" Improve scrolling performance when navigating through large results
set lazyredraw
" Use old regexp engine
" set regexpengine=1
" Ignore case only when the pattern contains no capital letters
set ignorecase smartcase
" Shortcut for far.vim find
nnoremap <silent> <leader>ff :Farf<cr>
vnoremap <silent> <leader>ff :Farf<cr>
" Shortcut for far.vim replace
nnoremap <silent> <leader>fr :Farr<cr>
vnoremap <silent> <leader>fr :Farr<cr>

" vim-markdown
let g:vim_markdown_conceal = 0
let g:vim_markdown_conceal_code_blocks = 0

" vim-terraform
let g:terraform_fmt_on_save =  1
let g:terraform_align = 1

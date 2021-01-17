set nocompatible              " be iMproved, required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" let Vundle manage Vundle, required
" {{{
Plugin 'VundleVim/Vundle.vim'
Plugin 'preservim/nerdtree'
Plugin 'rstacruz/sparkup', {'rtp': 'vim/'}
Plugin 'davidhalter/jedi-vim'
Plugin 'szw/vim-tags'
Plugin 'majutsushi/tagbar'
Plugin 'plasticboy/vim-markdown.git'
Plugin 'Shougo/neocomplcache.vim'
Plugin 'vim-syntastic/syntastic'
Plugin 'pbondoer/vim-42header'
Plugin 'luochen1990/rainbow'
Plugin 'chrisbra/NrrwRgn'
Plugin 'simeji/winresizer'
Plugin 'airblade/vim-gitgutter'
Plugin 'tpope/vim-fugitive'
Plugin 'morhetz/gruvbox'
Plugin 'christoomey/vim-tmux-navigator'
Plugin 'benmills/vimux'
Plugin 'tmux-plugins/vim-tmux-focus-events'
Plugin 'roxma/vim-tmux-clipboard'
Plugin 'preservim/nerdcommenter'
Plugin 'tpope/vim-surround'
Plugin 'othree/vim-autocomplpop'
Plugin 'vim-scripts/L9'
Plugin 'sheerun/vim-polyglot'
Plugin 'kshenoy/vim-signature'
Plugin 'junegunn/goyo.vim'
Plugin 'Shougo/unite.vim'
Plugin 'Shougo/vimproc.vim'
Plugin 'maxbrunsfeld/vim-yankstack'
Plugin 'easymotion/vim-easymotion'
Plugin 'haya14busa/incsearch.vim'
Plugin 'haya14busa/incsearch-easymotion.vim'
Plugin 'nathanaelkane/vim-indent-guides'
Plugin 'vim-scripts/taglist.vim'
Plugin 'tpope/vim-eunuch'
Plugin 'yegappan/grep'
Plugin 'jlanzarotta/bufexplorer'
Plugin 'tpope/vim-repeat'
Plugin 'tpope/vim-git'
Plugin 'kana/vim-textobj-user'
Plugin 'kana/vim-textobj-lastpat'
Plugin 'tpope/vim-abolish'
Plugin 'nelstrom/vim-qargs'
Plugin 'liuchengxu/vista.vim'
Plugin 'tpope/vim-unimpaired'
Plugin 'itchyny/lightline.vim'
Plugin 'shinchu/lightline-gruvbox.vim'
Plugin 'vim-scripts/restore_view.vim'
Plugin 'xavierd/clang_complete'
Plugin 'chrisbra/Colorizer'
Plugin 'vim-scripts/indexer.tar.gz'
Plugin 'vim-scripts/vimprj'
Plugin 'vim-scripts/DfrankUtil'
Plugin 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plugin 'junegunn/fzf.vim'
Plugin 'francoiscabrol/ranger.vim'
Plugin 'tomtom/tinykeymap_vim'
Plugin 'jamessan/vim-gnupg'
Plugin 'neomutt/neomutt.vim'
Plugin 'vim-scripts/a.vim'
Plugin 'vim-scripts/c.vim'
Plugin 'python-mode/python-mode', { 'for': 'python', 'branch': 'develop' }
Plugin 'tpope/vim-obsession'
Plugin 'dhruvasagar/vim-prosession'
Plugin 'samoshkin/vim-mergetool'
Plugin 'SirVer/ultisnips'
Plugin 'honza/vim-snippets'
Plugin 'MarcWeber/vim-addon-mw-utils'
Plugin 'tomtom/tlib_vim'
Plugin 'garbas/vim-snipmate'
Plugin 'lyokha/vim-xkbswitch'
" Plugin 'tomasr/molokai'
" Plugin 'ErichDonGubler/vim-sublime-monokai'
" Plugin 'jeffkreeftmeijer/vim-numbertoggle'
" Plugin 'terryma/vim-multiple-cursors'
" Plugin 'ap/vim-css-color'
" Plugin 'Shougo/deoplete.nvim'
" Plugin 'ryanoasis/vim-devicons'
" Plugin 'git://git.wincent.com/command-t.git'
" Plugin 'tomtom/tcomment_vim'
" Plugin 'myusuf3/numbers.vim'
" Plugin 'jiangmiao/auto-pairs'
" Plugin 'Raimondi/delimitMate'
" Plugin 'brookhong/cscope.vim'
" Plugin 'junegunn/vim-easy-align'
" }}}

" All of your Plugins must be added before the following line
call vundle#end()            " required
set hidden
runtime macros/matchit.vim
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on

" Brief help
" :PluginList       - lists configured plugins
" installs plugins; append `!` to update or just :PluginUpdate
" :PluginInstall
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" confirms removal of unused plugins; append `!` to auto-approve removal
" :PluginClean
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line

let $USER = 'awerebea'
let $MAIL = 'awerebea@student.21-school.ru'
set laststatus=2
set noshowmode
" show non-visible white spaces
set listchars=eol:¬,tab:▸—,trail:~,extends:»,precedes:«,space:·
set list
" Отключение звукового сигнала
set noerrorbells
set visualbell
set t_vb=

" always use 10-base numbers
set nrformats=

" Wildmenu completion
" {{{
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

" tabs settings
" {{{
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

function! TabsExpandByTwoSpaces()
  setlocal tabstop=2
  setlocal shiftwidth=2
  setlocal softtabstop=2
  setlocal expandtab
endfunction
command TabsBash call TabsExpandByTwoSpaces()

if has("autocmd")
  autocmd FileType ruby       setlocal ts=2 sts=2 sw=2 expandtab
  autocmd FileType sh         setlocal ts=2 sts=2 sw=2 expandtab
  autocmd FileType vim        setlocal ts=2 sts=2 sw=2 expandtab
  autocmd FileType zsh        setlocal ts=2 sts=2 sw=2 expandtab
  autocmd FileType tmux       setlocal ts=2 sts=2 sw=2 expandtab
  autocmd FileType conf       setlocal ts=2 sts=2 sw=2 expandtab
  autocmd FileType javascript setlocal ts=4 sts=4 sw=4 noet
  autocmd FileType c          setlocal ts=4 sts=4 sw=4 noet
  autocmd FileType dockerfile setlocal ts=4 sts=4 sw=4 noet
  autocmd FileType make       setlocal ts=4 sts=4 sw=4 noet
  autocmd FileType cpp        setlocal ts=4 sts=4 sw=4 noet
  autocmd FileType cpp        setlocal ts=4 sts=4 sw=4 noet
  autocmd BufEnter **/cpp.snippets setlocal ts=4 sts=4 sw=4 noet
  autocmd FileType gitcommit  setlocal ts=4 sts=4 sw=4 noet
  autocmd FileType gitignore  setlocal ts=4 sts=4 sw=4 noet
  autocmd FileType gitconfig  setlocal ts=4 sts=4 sw=4 noet
endif
" }}}

set ttymouse=xterm2
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

nnoremap <leader>rn :call ToggleSmartRelativenumbers()<CR>

" esc button remap
" inoremap kj <esc>
" cnoremap kj <C-C>
" Note: In command mode Ctrl-C

set encoding=utf-8	" default file encoding
set fileencodings=utf8,cp1251
set t_Co=256
set autowrite		" Automatically save before commands like :next and :make
set updatetime=2000	" gitgutter update delay

" word wrap
" {{{
set wrapmargin=0
set colorcolumn=+1
highlight ColorColumn ctermbg=235 guibg=#262626
set wrap linebreak
" set cursorline " А так мы можем подсвечивать строку с курсором
" wrap toggle
nmap <leader>aw :call AutoWrapToggle()<CR>
function! AutoWrapToggle()
  if &formatoptions =~ 't'
    setlocal textwidth=0
    setlocal fo-=t
    setlocal colorcolumn=
  else
    setlocal textwidth=80
    setlocal fo+=t
    setlocal colorcolumn=+1
  endif
endfunction
" }}}

" More natural split opening. Open new split panes to right and bottom.
set splitbelow
set splitright

" Easy navigation between splits to save a keystroke.
" So instead of ctrl-w then j, use just ctrl-j:
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

:set viminfo='1000,<1000,s200,h		" Increasing the buffer size

" Copy to 'clipboard registry'
vmap <C-c> "+y

if has('mac')
  set clipboard=unnamed
elseif has('windows')
  set clipboard=unnamed
elseif has('unix')
  " language en_US.utf8
  set clipboard=unnamedplus
endif

set autoread " перечитывать изменённые файлы автоматически
" Автоматически перечитывать конфигурацию VIM после сохранения
autocmd! bufwritepost $MYVIMRC source $MYVIMRC

set backspace=indent,eol,start " backspace обрабатывает отступы, концы строк
" опции сессий - перейти в текущую директорию, использовать буферы и табы
set sessionoptions=curdir,buffers,tabpages
set undolevels=2048 " хранить историю изменений числом N
" перемещать курсор на следующую строку при нажатии на клавиши вправо-влево
" и пр.
set whichwrap=b,<,>,[,],l,h
set pastetoggle= " при вставке фрагмента сохраняет отступ

" text selection highlighting
highlight Visual cterm=BOLD ctermbg=238 ctermfg=NONE
" set syntax=c
" Syntax highlighting enables.
if has("syntax")
  syntax on
endif

" Быстрый вызов команды `set GitGutterSingsToggle`
nmap <leader>gg :GitGutterSignsToggle<CR>
" убрать элементы интерфейса vim
nmap <leader>go :Goyo<CR>
let g:goyo_width = 86
" toggle show non-visible white spaces
nmap <leader>ll :set list!<CR>
" highlight trailing spaces
au BufNewFile,BufRead * let b:mtrailingws=matchadd('ErrorMsg', '\s\+$', -1)
" highlight tabs between spaces
au BufNewFile,BufRead * let b:mtabbeforesp=matchadd('ErrorMsg',
  \ '\v(\t+)\ze( +)', -1)
au BufNewFile,BufRead * let b:mtabaftersp=matchadd('ErrorMsg',
  \ '\v( +)\zs(\t+)', -1)

"colorscheme sublimemonokai
"color molokai
"let g:molokai_original = 1

" original gruvbox colorcheme
let g:gruvbox_number_column = 'bg0' "default 'bg0'
let g:gruvbox_sign_column = 'bg0' "default 'bg1'
let g:gruvbox_bold = '0' "default '1'
let g:gruvbox_contrast_dark = 'hard' "default 'medium'
set background=dark
colorscheme gruvbox

" NERDCommenter
" Add spaces after comment delimiters
let g:NERDSpaceDelims = 1
" custom formats or override the defaults
let g:NERDCustomDelimiters = { 'c': { 'left': '/*','right': '*/' } }
" let g:NERDCustomDelimiters = { 'cpp': { 'left': '/*','right': '*/' } }
" Align line-wise comment delimiters flush left instead of following code
" indentation (left/both)
let g:NERDDefaultAlign = 'both'
" Allow commenting and inverting empty lines (useful when commenting a region)
"let g:NERDCommentEmptyLines = 1
" Use compact syntax for prettified multi-line comments
let g:NERDCompactSexyComs = 0
" Enable trimming of trailing whitespace when uncommenting
let g:NERDTrimTrailingWhitespace = 1

" Tagbar
" {{{
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

" Rainbow brackets settings
" {{{
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

"lightline
" {{{
let g:lightline = {
  \ 'colorscheme': 'default',
  \ 'active': {
  \   'left': [['mode', 'paste'], ['gitbranch'], ['filename', 'modified']],
  \   'right': [['lineinfo'], ['percent'], ['fileformat', 'filetype',
  \ 'fileencoding', 'charvaluehex', 'spell', 'indent']]
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
  \ 'component_type': {
  \   'readonly': 'error',
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
  if winwidth(0) > 90 || &filetype == 'nerdtree'
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
" function! s:MaybeUpdateLightline()
"   if exists('#lightline')
"     call lightline#update()
"   end
" endfunction
nmap <leader>llu :Goyo<CR>:Goyo<CR>
" }}}

"... для изменения курсора в разных режимах используйте это:
"set ttimeoutlen=10 "Понижаем задержку ввода escape последовательностей
"let &t_SI.="\e[5 q" "SI = режим вставки
"let &t_SR.="\e[3 q" "SR = режим замены
"let &t_EI.="\e[1 q" "EI = нормальный режим
"Где 1 - это мигающий прямоугольник
"2 - обычный прямоугольник
"3 - мигающее подчёркивание
"4 - просто подчёркивание
"5 - мигающая вертикальная черта
"6 - просто вертикальная черта

"vimux
" Prompt for a command to run
map <leader>vp :VimuxPromptCommand<CR>
" Run last command executed by VimuxRunCommand
map <leader>vl :VimuxRunLastCommand<CR>

"работа тегами (ctags, ctrlP, tagbar, vim-tags)
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

" vim-syntastic
" {{{
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 0
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
" nnoremap <leader>e :Errors<Cr>
function! ToggleSyntastic()
  for i in range(1, winnr('$'))
    let bnum = winbufnr(i)
    if getbufvar(bnum, '&buftype') == 'quickfix'
      lclose
      return
    endif
  endfor
  Errors
endfunction
nnoremap <leader>e :call ToggleSyntastic()<CR>
" }}}

" Unite
"nnoremap <leader>p :Unite file_rec/async<cr>
nnoremap <space>/ :Unite grep:.<cr>
"let g:unite_source_history_yank_enable = 1
"nnoremap <space>y :Unite history/yank<cr>
nnoremap <space>s :Unite -auto-preview -quick-match buffer<cr>

" yankstack
nmap <leader>p <Plug>yankstack_substitute_older_paste
nmap <leader>P <Plug>yankstack_substitute_newer_paste

" vim-indent-guides
" let g:indent_guides_guide_size = 1
" let g:indent_guides_color_change_percent = 3
" let g:indent_guides_enable_on_vim_startup = 1

" Multi cursors
" {{{
let g:multi_cursor_use_default_mapping=0
" default mapping
let g:multi_cursor_start_word_key      = '<C-n>'
" let g:multi_cursor_select_all_word_key = '<A-n>'
" let g:multi_cursor_start_key           = 'g<C-n>'
" let g:multi_cursor_select_all_key      = 'g<A-n>'
let g:multi_cursor_next_key            = '<C-n>'
" let g:multi_cursor_prev_key            = '<C-p>'
" let g:multi_cursor_skip_key            = '<C-x>'
let g:multi_cursor_quit_key            = '<Esc>'
" }}}

" Folding settings
" {{{
" zc                          fold block
" zo                          unfold block
" zM                          fold all blocks
" zR                          unfold all blocks
" za                          toggle folding
" zf                          check :set foldmethod=manual
" set foldenable            " turn on folding
set nofoldenable           " turn off folding
" set foldmethod=syntax     " fold based on syntax
set foldmethod=indent      " fold based on indent
" set foldmethod=manual     " manual folding
" set foldmethod=marker     " fold based on markers
" set foldmarker=bigin,end  " set markers of start and end of the block
set foldcolumn=3            " show fold column left on the screen
set foldlevel=2             " fold levels opened at file opens
set foldlevelstart=99
" set foldopen=all          " autoopen fold when enter it
set foldnestmax=5           " max level of fold

if has("autocmd")
  autocmd FileType vim setlocal foldmethod=marker foldmarker={{{,}}}
  autocmd FileType javascript setlocal foldmethod=expr
  autocmd FileType javascript setlocal foldexpr=JSFolds()
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
" }}}

" Easy Align
" Start interactive EasyAlign in visual mode (e.g. vipga)
xmap ga <Plug>(EasyAlign)
" Start interactive EasyAlign for a motion/text object (e.g. gaip)
nmap ga <Plug>(EasyAlign)

set ignorecase " ics - поиск без учёта регистра символов
set smartcase		" Do smart case matching
set hlsearch " подсветка результатов поиска
set incsearch " поиск фрагмента по мере его набора
" поиск выделенного текста (начинать искать фрагмент при его выделении)
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

" fix to vim-surround 'S' keybin works with yankstack plug
call yankstack#setup()

" turn off search highlight by presing space
:noremap <silent> <Space> :<C-u>nohlsearch<CR><C-l>

" list buffers keybinds
" {{{
nnoremap [b :bprevious<CR>
nnoremap ]b :bnext<CR>
nnoremap [B :bfirst<CR>
nnoremap ]B :blast<CR>
map <F6> :bprevious<CR>
imap <F6> <ESC>:bprevious<CR>i
map <F7> :bnext<CR>
imap <F7> <ESC>:bnext<CR>i
" F5 - просмотр списка буферов
" nmap <F5> :BufExplorerVerticalSplit<CR>
nmap <F5> :BufExplorer<CR>
nnoremap <silent> <leader><leader><Enter> :BufExplorer<CR>
" }}}

" past current buffer path instead %% in Ex editor line
cnoremap <expr> %% getcmdtype() == ':' ? expand('%:h').'/' : '%%'

" easymotion TEST!!!!!!!
" {{{
let g:bufExplorerDisableDefaultKeyMapping = 1
map <leader><leader>w <Plug>(easymotion-bd-w)
nmap <leader><leader>w <Plug>(easymotion-overwin-w)
nmap <leader>w <Plug>(easymotion-w)
nmap <leader>b <Plug>(easymotion-b)
map <leader>j <Plug>(easymotion-j)
map <leader>k <Plug>(easymotion-k)
let g:EasyMotion_startofline = 0 " keep cursor column when JK motion"
let g:EasyMotion_smartcase = 1
" incsearch
map /  <Plug>(incsearch-forward)
map ?  <Plug>(incsearch-backward)
map g/ <Plug>(incsearch-stay)
map z/ <Plug>(incsearch-easymotion-/)
map z? <Plug>(incsearch-easymotion-?)
map zg/ <Plug>(incsearch-easymotion-stay)
" }}}

set autoindent
set pastetoggle=<F4>

" autopairing
" inoremap " ""<left>
" inoremap ' ''<left>
" inoremap ( ()<left>
" inoremap [ []<left>
" inoremap { {}<left>
inoremap {<CR> {<CR>}<ESC>O
inoremap {;<CR> {<CR>};<ESC>O

" tabs navigation
" {{{
" nnoremap gz :bdelete<CR>
nnoremap <leader>o :tab sball<CR>
set switchbuf=usetab,newtab
" switch to last tab
if !exists('g:lasttab')
	let g:lasttab = 1
endif
nmap <leader>tt :exe "tabn ".g:lasttab<CR>
au TabLeave * let g:lasttab = tabpagenr()
" Переключение табов (вкладок) (rxvt-style)
nmap <leader><Left> :tabprevious<cr>
nmap <leader><Right> :tabnext<cr>
nnoremap th :tabfirst<CR>
nnoremap tj :tabnext<CR>
nnoremap tk :tabprev<CR>
nnoremap tl :tablast<CR>
nnoremap tt :tabedit<Space>
nnoremap tn :tabnext<Space>
nnoremap tm :tabm<Space>
nnoremap td :tabclose<CR>
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

" repeat the last substitution with preserved flags
nnoremap & :&&<CR>
xnoremap & :&&<CR>

" send changed text segment to blackhole
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
" file it was loaded from, thus the changes you made.
" {{{
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
" " autoopen NERDTree when vim starts up and no files were specified
" autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
" autocmd StdinReadPre * let s:std_in=1
" " close Vim if NerdTree is last opened buffer
" autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree")
"  \ && b:NERDTree.isTabTree()) | q | endif

" Ranger integration
let g:ranger_map_keys = 0
let g:NERDTreeHijackNetrw = 0 " add this line if you use NERDTree
let g:ranger_replace_netrw = 1 " open ranger when vim open a directory
map <leader>rr :Ranger<CR>
map <leader>rt :RangerCurrentFileExistingOrNewTab<CR>
map <leader>rw :RangerWorkingDirectory<CR>
map <leader>re :RangerWorkingDirectoryExistingOrNewTab<CR>
let s:uname_host = system("echo -n \"$(uname -n)\"")
if !v:shell_error && s:uname_host =~ "21-school"
  let g:ranger_choice_file = '/Users/awerebea/.ranger_choice_file'
endif

" Avoid unintentional switches to Ex mode.
nmap Q q

" clang_complete
" {{{
let s:uname = system("echo -n \"$(uname)\"")
let s:uname_host = system("echo -n \"$(uname -n)\"")
if !v:shell_error && s:uname_host =~ "21-school"
  let g:clang_library_path='/Library/Developer/CommandLineTools/usr/lib/'
elseif !v:shell_error && s:uname == "Linux" && (s:uname_host == "pc-home"
  \ || s:uname_host == "laptop-acer")
  let g:clang_library_path='/usr/lib/'
elseif !v:shell_error && s:uname == "Linux" && system("echo -n \"$(whoami)\"")
  \ == "root"
  let g:clang_library_path='/usr/lib/clang/'
endif
let g:clang_snippets=1
let g:clang_trailing_placeholder=1
let g:clang_complete_optional_args_in_snippets=1
let g:clang_auto_select=1
" unset the default keymappings to provide compatibility with ctags
" let g:clang_make_default_keymappings=0
let g:clang_jumpto_declaration_key="<leader><C-]>"
let g:clang_jumpto_declaration_in_preview_key="<leader><leader><C-]>"
" let g:clang_jumpto_back_key=""
let g:clang_complete_auto=1
" }}}

" backup and swap files settings
" {{{
" Save your backup files to a less annoying place than the current directory.
" If you have .vim-backup in the current directory, it'll use that.
" Otherwise it saves it to ~/.vim/backup or .
if isdirectory($HOME . '/.vim/backup') == 0
  :silent !mkdir -p ~/.vim/backup >/dev/null 2>&1
endif
set backup
set backupdir-=.
set backupdir+=.
set backupdir-=~/
set backupdir^=~/.vim/backup//
set backupdir^=./.vim-backup//
set writebackup

" Save your swap files to a less annoying place than the current directory.
" If you have .vim-swap in the current directory, it'll use that.
" Otherwise it saves it to ~/.vim/swap, ~/tmp or .
if isdirectory($HOME . '/.vim/swap') == 0
  :silent !mkdir -p ~/.vim/swap >/dev/null 2>&1
endif
set swapfile
set updatecount=100
set directory=./.vim-swap//
set directory+=~/.vim/swap//
set directory+=~/tmp//
set directory+=.

" viminfo stores the the state of your previous editing session
set viminfo+=n~/.vim/viminfo

if exists("+undofile")
  " undofile - This allows you to use undos after exiting and restarting
  " This, like swap and backup files, uses .vim-undo first, then ~/.vim/undo
  " :help undo-persistence
  " This is only present in 7.3+
  if isdirectory($HOME . '/.vim/undo') == 0
    :silent !mkdir -p ~/.vim/undo > /dev/null 2>&1
  endif
  set undofile
  set undodir=./.vim-undo//
  set undodir+=~/.vim/undo//
endif

" viewdir
if isdirectory($HOME . '/.vim/view') == 0
  :silent !mkdir -p ~/.vim/view >/dev/null 2>&1
endif
set viewdir=~/.vim/view
" }}}

" " Highlight TODO, FIXME, NOTE, etc.
" {{{
" if has('autocmd') && v:version > 701
"   augroup todo
"     autocmd!
"     autocmd Syntax * call matchadd(
"       \ 'Debug',
"       \ '\v\W\zs<(NOTE|INFO|IDEA|TODO|FIXME|CHANGED|XXX|BUG|HACK|TRICKY)>'
"       \ )
"   augroup END
" endif

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
" creates annotation group and highlight it according to the config
function! s:MyCreateAnnotationGroup(annotation, config)
  " set group name -> my_annotation
  let l:group_name = 'my_' . tolower(a:annotation)

  " make group for annotation where its pattern matches and is inside comment
  execute 'augroup ' . l:group_name
    autocmd!
    execute 'autocmd Syntax * syntax match ' . l:group_name .
      \ ' /\v\C\_.<' . a:annotation . '(:|>)/hs=s+1 containedin=.*Comment.*'
  augroup END

  " highlight the group according to the config
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

" highlights the user specified custom annotation groups
if exists("g:my_todo_highlight_config")
  for [annotation, config] in items(g:my_todo_highlight_config)
    call s:MyCreateAnnotationGroup(annotation, config)
  endfor
endif
" }}}

" Colors highlighting
"au BufEnter * :ColorHighlight<CR> " highlight colors on startup for all files
" :let g:colorizer_auto_filetype='css,html,cpp,vim,python'
:let g:colorizer_auto_color=0
" highlight colors toggle
" noremap <leader>ct :ColorToggle<CR> " conflict with c.vim keybinds

" Indexer settings
let g:indexer_disableCtagsWarning=1

" ============================================================================
" FZF
" ============================================================================
" {{{
" ignore files ignored in .gitignore but show hidden
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

" nnoremap <silent> <leader>f :Files<CR>
nnoremap <silent> <expr> <leader>f (expand('%') =~
  \ 'NERD_tree' ? "\<c-w>\<c-w>" : '').":Files\<cr>"
nnoremap <silent> <leader>C        :Colors<CR>
nnoremap <silent> <leader><Enter>  :Buffers<CR>
nnoremap <silent> <leader>l        :Lines<CR>
" nnoremap <silent> <leader>ag       :Ag <C-R><C-W><CR>
" nnoremap <silent> <leader>AG       :Ag <C-R><C-A><CR>
" xnoremap <silent> <leader>ag       y:Ag <C-R>"<CR>
nnoremap <silent> <leader>rg       :FZFRg<CR>
nnoremap <silent> <leader>RG       :FZFRg <C-R><C-A><CR>
xnoremap <silent> <leader>rg       y:FZFRg <C-R>"<CR>
nnoremap <silent> <leader>`        :Marks<CR>
" nnoremap <silent> q: :History:<CR>
" nnoremap <silent> q/ :History/<CR>

inoremap <expr> <c-x><c-t> fzf#complete('tmuxwords.rb --all-but-current
  \ --scroll 498 --min 5')
" map <c-x><c-k> <plug>(fzf-complete-word)
imap <c-x><c-f> <plug>(fzf-complete-path)
inoremap <expr> <c-x><c-d> fzf#vim#complete#path('blsd')
imap <c-x><c-j> <plug>(fzf-complete-file-ag)
imap <c-x><c-l> <plug>(fzf-complete-line)

" nmap <leader><tab> <plug>(fzf-maps-n)
" xmap <leader><tab> <plug>(fzf-maps-x)
" omap <leader><tab> <plug>(fzf-maps-o)

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
  \ --colors 'line:style:bold' --column --line-number --no-heading
  \ --color=always --smart-case -- ".shellescape(<q-args>), 1,
  \ fzf#vim#with_preview('up:50%', 'ctrl-/'), <bang>0)

command! -bang -nargs=* Ag
  \ call fzf#vim#ag(<q-args>, '--column --numbers --smart-case --color
  \ --color-path "36;1" --color-match "30;43" --color-line-number "33;1"',
  \ fzf#vim#with_preview('up:50%', 'ctrl-/'), <bang>0)
" }}}

" Quickly edit/reload this configuration file
nnoremap <leader>ve :edit $MYVIMRC<CR>
nnoremap <leader>vs :source $MYVIMRC<CR>

" autoclose preview window after autocompletion is done
autocmd CompleteDone * pclose

" autoclose location list before window change
map <c-h> :lclose<CR><C-w>h
map <c-j> :lclose<CR><C-w>j
map <c-k> :lclose<CR><C-w>k
map <c-l> :lclose<CR><C-w>l

" Set the file type for files that are in use on the system but do not yet
" have a type.
augroup filetypedetect
  au BufRead,BufNewFile .tmux.conf.local  setlocal ft=tmux
  au BufRead,BufNewFile conkyrc*          setlocal ft=conf
  au BufRead,BufNewFile webserv.conf*     setlocal ft=nginx
augroup END

" Delete a buffer without closing the window,
" create a scratch buffer if no buffers left
" {{{
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

" Keymaps to create horizontal and vertical window splits
map <silent> <leader><leader>s :split<CR>
map <silent> <leader><leader>v :vsplit<CR>

" tinykeymap settings (faster win resize)
call tinykeymap#EnterMap('windows', '<C-W>', {'name': 'Windows mode'})

" GPG settings
" {{{
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

" Pymode settings
" {{{
let g:pymode_run_bind = '<leader>r'
let g:pymode_breakpoint_bind = '<leader>b'

let g:pymode_rope = 1
let g:pymode_rope_complete_on_dot = 0
let g:pymode_rope_show_doc_bind = '<leader>pd'
let g:pymode_rope_goto_definition_bind = '<leader>pg'
let g:pymode_rope_goto_definition_cmd = 'new'
let g:pymode_rope_rename_bind = '<leader>pr'
let g:pymode_rope_module_to_package_bind = '<leader>p1p'
let g:pymode_rope_extract_method_bind = '<leader>pm'
let g:pymode_rope_extract_variable_bind = '<leader>pl'
let g:pymode_rope_use_function_bind = '<leader>pu'
let g:pymode_rope_move_bind = '<leader>pv'
let g:pymode_rope_change_signature_bind = '<leader>ps'

let g:pymode_options_max_line_length = 80
let g:pymode_options_colorcolumn = 1
" }}}

" C-support plugin (c.vim) settings
" change <leader> key for all keybinds to <leader><leader>
let g:C_MapLeader = '\\'
let g:C_Ctrl_j = 'off'
" Alternate file (a.vim) plugin settings
" Suppress the creation of a new header file if it's not exist
let g:alternateNoDefaultAlternate = 1
let g:C_UseTool_cmake = 'yes'
" let g:C_UseTool_doxygen = 'yes'
" :A switches to the header file corresponding to the current file being
" edited (or vise versa)
noremap <leader>a :A<CR>
inoremap <leader>a <C-C>:A<CR>
" :AS splits and switches
noremap <leader>as :AS<CR>
inoremap <leader>as <C-C>:AS<CR>
" :AV vertical splits and switches
noremap <leader>av :AV<CR>
inoremap <leader>av <C-C>:AV<CR>
" :AT new tab and switches
noremap <leader>at :AT<CR>
inoremap <leader>at <C-C>:AT<CR>
" :AN cycles through matches
noremap <leader>an :AN<CR>
inoremap <leader>an <C-C>:AN<CR>

" prosession settings
let g:prosession_tmux_title = 0
let g:prosession_tmux_title_format = "vim - @@@"

" Terminal in vim buffer settings
" make terminal window in vim buffer inactive
nnoremap T :term<CR>
tnoremap <C-t> <C-w>N

" indexer settings (fix ctags generation for vimprj plugin)
let g:indexer_ctagsCommandLineOptions =
  \ '-R --fields=+iaSl --c++-kinds=+p --extra=+q'

" vim-mergetool settings
" {{{
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

" possible values: 'local' (default), 'remote', 'base', 'unmodified'
let g:mergetool_prefer_revision = 'local'

" turn off syntax and spell checking highlighting for all splits
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

" smart quit window in merge mode
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

" remap native commands '(q)uit' and '(w)rite(q)uit' to 'MergetoolStop'
" in diff mode only
" cnoremap <expr> q (mergetool_in_merge_mode ? 'MergetoolStop' : 'q')
" cnoremap <expr> wq (mergetool_in_merge_mode ? 'MergetoolStop' : 'q')
" }}}

" restore_view settings
" views of some files not to be saved
" let g:loaded_restore_view = ['*/.vimrc']

" diff mode toggle (with SmartRelativenumbers support)
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
    " enable diff options in both windows; balance the sizes, too
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
inoremap <silent> <leader><F9> <C-O>:call ToggleDiff()<CR>

" dictionary and completion settings
" {{{
set complete=.,k,w,b,u,t,i,kspell
set shortmess+=c
set shortmess-=S
set completeopt=menuone,longest,preview
" set dictionary+=$GIT_WORKSPACE/vim/vimdict

" autocomplpop settings
let g:acp_enableAtStartup = 1
let g:acp_mappingDriven = 0
let g:acp_ignorecaseOption = 1
" let g:acp_behaviorSnipmateLength = 3
let g:acp_completeOption = '.,k,w,b,u,t,i,kspell'

" Navigate the complete menu items like CTRL+n / CTRL+p would.
inoremap <expr> <Down> pumvisible() ? "<C-n>" :"<Down>"
inoremap <expr> <Up> pumvisible() ? "<C-p>" : "<Up>"
" Select the complete menu item like CTRL+y would.
inoremap <expr> <Right> pumvisible() ? "<C-y>" : "<Right>"
inoremap <expr> <CR> pumvisible() ? "<C-y>" :"<CR>"
" Cancel the complete menu item like CTRL+e would.
inoremap <expr> <Left> pumvisible() ? "<C-e>" : "<Left>"

" re-create spl files for additional vocabularies
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

"enable spell checking by default
" set spell spelllang=en_us,ru_yo

" vim-xkbswitch settings (auto switch to English keyboard layout in Normal and
" Command mode
let g:XkbSwitchEnabled = 1
let s:uname = system("echo -n \"$(uname)\"")
let s:uname_host = system("echo -n \"$(uname -n)\"")
if !v:shell_error && s:uname_host =~ "21-school"
  let g:XkbSwitchLib = "/Users/awerebea/.local/lib/libxkbswitch.so"
elseif !v:shell_error && s:uname == "Linux" && (s:uname_host == "pc-home"
  \ || s:uname_host == "laptop-acer")
  let g:XkbSwitchLib = "/usr/lib/libxkbswitch.so"
elseif !v:shell_error && s:uname == "Linux" && system("echo -n \"$(whoami)\"")
  \ == "root"
  let g:XkbSwitchLib = "/usr/lib/libxkbswitch.so"
endif

" Colors for words that failed spell check
" Word not recognized
hi clear SpellBad
hi SpellBad cterm=underline ctermfg=blue
" Word not capitalized
hi clear SpellCap
hi SpellCap cterm=underline ctermfg=red
" Word is rare
hi clear SpellRare
hi SpellRare cterm=underline ctermfg=green
" Wrong spelling for selected region
hi clear SpellLocal
hi SpellLocal cterm=underline ctermfg=yellow

inoremap <expr> <c-x><c-k> SpellCheck("\<c-x>\<c-k>")
nnoremap z= :<c-u>call SpellCheck()<cr>z=
function! SpellCheck(...)
  let s:spell_restore = &spell
  set spell
  augroup restore_spell_option
    autocmd!
    autocmd CursorMoved,CompleteDone <buffer> let &spell = s:spell_restore | autocmd! restore_spell_option
  augroup END
  return a:0 ? a:1 : ''
endfunction
" }}}

" ultisnips settings
" Trigger configuration. You need to change this to something other than <tab>
" if you use one of the following:
" - https://github.com/Valloric/YouCompleteMe
" - https://github.com/nvim-lua/completion-nvim
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsJumpForwardTrigger="<tab>"
let g:UltiSnipsJumpBackwardTrigger="<s-tab>"
let g:UltiSnipsEditSplit="vertical"
let g:UltiSnipsSnippetsDir="~/.vim/UltiSnips"
nnoremap <leader>sne :UltiSnipsEdit<cr>
let g:snipMate = {}
let g:snipMate.snippet_version = 1

" run/compile from vim
if has("autocmd")
  autocmd FileType python map <buffer> <F9> :w<CR>
  \ :exec '!clear; python3' shellescape(@%, 1)<CR>
  autocmd FileType python imap <buffer> <F9> <esc>:w<CR>
  \ :exec '!clear; python3' shellescape(@%, 1)<CR>
  autocmd FileType cpp map <buffer> <F9> :make<CR>
  autocmd FileType c map <buffer> <F9> :make<CR>
endif

set nocompatible              " be iMproved, required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" let Vundle manage Vundle, required
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
Plugin 'tomasr/molokai'
Plugin 'morhetz/gruvbox'
Plugin 'ErichDonGubler/vim-sublime-monokai'
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
Plugin 'terryma/vim-multiple-cursors'
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
" Plugin 'Shougo/deoplete.nvim'
" Plugin 'ryanoasis/vim-devicons'
" Plugin 'git://git.wincent.com/command-t.git'
" Plugin 'tomtom/tcomment_vim'
" Plugin 'myusuf3/numbers.vim'
" Plugin 'jiangmiao/auto-pairs'
" Plugin 'Raimondi/delimitMate'
" Plugin 'brookhong/cscope.vim'
" Plugin 'ctrlpvim/ctrlp.vim'
" Plugin 'tacahiroy/ctrlp-funky'
" Plugin 'junegunn/vim-easy-align'

" All of your Plugins must be added before the following line
call vundle#end()            " required
set hidden
runtime macros/matchit.vim
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on

" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
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
set wildmenu
set wildmode=full

set wildignore+=.hg,.git,.svn                    " Version control
set wildignore+=*.aux,*.out,*.toc                " LaTeX intermediate files
set wildignore+=*.jpg,*.bmp,*.gif,*.png,*.jpeg   " binary images
set wildignore+=*.o,*.obj,*.exe,*.dll,*.manifest " compiled object files
set wildignore+=*.spl                            " compiled spelling word lists
set wildignore+=*.sw?                            " Vim swap files
set wildignore+=*.DS_Store                       " OSX bullshit
set wildignore+=*.luac                           " Lua byte code
set wildignore+=migrations                       " Django migrations
set wildignore+=go/pkg                           " Go static files
set wildignore+=go/bin                           " Go bin files
set wildignore+=go/bin-vagrant                   " Go bin-vagrant files
set wildignore+=*.pyc                            " Python byte code
set wildignore+=*.orig                           " Merge resolution files

" tabs settings
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
  autocmd FileType conf       setlocal ts=2 sts=2 sw=2 expandtab
  autocmd FileType javascript setlocal ts=4 sts=4 sw=4 noet
  autocmd FileType c          setlocal ts=4 sts=4 sw=4 noet
  autocmd FileType dockerfile setlocal ts=4 sts=4 sw=4 noet
  autocmd FileType make       setlocal ts=4 sts=4 sw=4 noet
  autocmd FileType cpp        setlocal ts=4 sts=4 sw=4 noet
  autocmd FileType gitcommit  setlocal ts=4 sts=4 sw=4 noet
  autocmd FileType gitignore  setlocal ts=4 sts=4 sw=4 noet
  autocmd FileType gitconfig  setlocal ts=4 sts=4 sw=4 noet
endif

set ttymouse=xterm2
set mouse=a
set mousehide
set showcmd
set number norelativenumber

" relativenumber toggle
nmap <leader>rn :set relativenumber!<CR>

" esc button remap
inoremap kj <esc>
cnoremap kj <C-C>
" Note: In command mode Ctrl-C

set encoding=utf-8	" default file encoding
set fileencodings=utf8,cp1251
set t_Co=256
set smartcase		" Do smart case matching
set autowrite		" Automatically save before commands like :next and :make
set updatetime=2000	" gitgutter update delay

" word wrap
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

" More natural split opening. Open new split panes to right and bottom.
set splitbelow
set splitright

" We can use different key mappings for easy navigation between splits to save a
" keystroke. So instead of ctrl-w then j, it’s just ctrl-j:
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

:set viminfo='1000,<1000,s200,h		" Increasing the buffer size

" Copy to 'clipboard registry'
vmap <C-c> "+y

if has('mac')
  set clipboard=unnamed
elseif has('unix')
  " language en_US.utf8
  set clipboard=unnamedplus
endif

set autoread " перечитывать изменённые файлы автоматически
autocmd! bufwritepost $MYVIMRC source $MYVIMRC " Автоматически перечитывать конфигурацию VIM после сохранения

set backspace=indent,eol,start " backspace обрабатывает отступы, концы строк
set sessionoptions=curdir,buffers,tabpages " опции сессий - перейти в текущую директорию, использовать буферы и табы
set undolevels=2048 " хранить историю изменений числом N
set whichwrap=b,<,>,[,],l,h " перемещать курсор на следующую строку при нажатии на клавиши вправо-влево и пр.
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
au BufNewFile,BufRead * let b:mtabbeforesp=matchadd('ErrorMsg', '\v(\t+)\ze( +)', -1)
au BufNewFile,BufRead * let b:mtabaftersp=matchadd('ErrorMsg', '\v( +)\zs(\t+)', -1)

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

" выключить подсветку поиска
" map <leader>nh :nohlsearch<CR>
map <leader>nh :<C-u>nohlsearch<CR><C-l>

" NERDCommenter
" Add spaces after comment delimiters
let g:NERDSpaceDelims = 1
" custom formats or override the defaults
let g:NERDCustomDelimiters = { 'c': { 'left': '/*','right': '*/' } }
" let g:NERDCustomDelimiters = { 'cpp': { 'left': '/*','right': '*/' } }
" Align line-wise comment delimiters flush left instead of following code indentation (left/both)
let g:NERDDefaultAlign = 'both'
" Allow commenting and inverting empty lines (useful when commenting a region)
"let g:NERDCommentEmptyLines = 1
" Use compact syntax for prettified multi-line comments
let g:NERDCompactSexyComs = 0
" Enable trimming of trailing whitespace when uncommenting
let g:NERDTrimTrailingWhitespace = 1

" Tagbar
" JS
let g:tagbar_type_javascript = {
    \ 'ctagsbin' : '/path/to/jsctags'
	\ }

" CSS
let g:tagbar_type_css = {
			\ 'ctagstype' : 'Css',
    \ 'kinds'     : [
        \ 'c:classes',
        \ 's:selectors',
        \ 'i:identities'
    \ ]
	\ }

" Google Go
let g:tagbar_type_go = {
    \ 'ctagstype': 'go',
    \ 'kinds' : [
        \'p:package',
        \'f:function',
        \'v:variables',
        \'t:type',
        \'c:const'
    \]
	\}

" Rainbow brackets settings
let g:rainbow_active = 1
let g:rainbow_conf = {
\   'guifgs': ['darkorange', 'lightblue', 'lightyellow', 'lightcyan', 'lightmagenta', 'seagreen3', 'firebrick'],
\   'ctermfgs': ['lightblue', 'lightyellow', 'lightcyan', 'lightmagenta'],
\   'guis': [''],
\   'cterms': [''],
\   'operators': '_,_',
\   'parentheses': ['start=/(/ end=/)/ fold', 'start=/\[/ end=/\]/ fold', 'start=/{/ end=/}/ fold'],
\   'separately': {
\       '*': {},
\       'markdown': {
\           'parentheses_options': 'containedin=markdownCode contained',
\       },
\       'lisp': {
\           'guifgs': ['royalblue3', 'darkorange3', 'seagreen3', 'firebrick', 'darkorchid3'],
\       },
\       'haskell': {
\           'parentheses': ['start=/(/ end=/)/ fold', 'start=/\[/ end=/\]/ fold', 'start=/\v\{\ze[^-]/ end=/}/ fold'],
\       },
\       'vim': {
\           'parentheses_options': 'containedin=vimFuncBody',
\       },
\       'perl': {
\           'syn_name_prefix': 'perlBlockFoldRainbow',
\       },
\       'stylus': {
\           'parentheses': ['start=/{/ end=/}/ fold contains=@colorableGroup'],
\       },
\       'css': 0,
\   }
\}

"lightline
let g:lightline = {
\ 'colorscheme': 'default',
\ 'active': {
\   'left': [['mode', 'paste'], ['gitbranch'], ['filename', 'modified']],
\   'right': [['lineinfo'], ['percent'], ['fileformat', 'filetype', 'fileencoding', 'charvaluehex', 'spell', 'indent']]
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
\ },
\ 'component_type': {
\   'readonly': 'error',
\ },
\ }

" let g:lightline.component = {
"         \ 'mode': '%{lightline#mode()}',
"         \ 'absolutepath': '%F',
"         \ 'relativepath': '%f',
"         \ 'filename': '%t',
"         \ 'modified': '%M',
"         \ 'bufnum': '%n',
"         \ 'paste': '%{&paste?"PASTE":""}',
"         \ 'readonly': '%R',
"         \ 'charvalue': '%b',
"         \ 'charvaluehex': '%B',
"         \ 'fileencoding': '%{&fenc!=#""?&fenc:&enc}',
"         \ 'fileformat': '%{&ff}',
"         \ 'filetype': '%{&ft!=#""?&ft:"no ft"}',
"         \ 'percent': '%3p%%',
"         \ 'percentwin': '%P',
"         \ 'spell': '%{&spell?&spelllang:""}',
"         \ 'lineinfo': '%3l:%-2c',
"         \ 'line': '%l',
"         \ 'column': '%c',
"         \ 'close': '%999X X ',
"         \ 'winnr': '%{winnr()}' }

" \ 'lineinfo': '%2.(%l%)/%-2.(%L%) %3.(%c%)/%-2.(%v%)%<' }
" \   'lineinfo': 'LightlineLineInfo',

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
      let l:lineinfo = l:current_line . '/' . l:max_line . ' ' . l:current_col . '/' . l:virt_col
      return l:lineinfo
    else
      return ''
endfunction

augroup lightline_update
  autocmd!
  if has('patch-7.4.786') " 17 Jul 2015 with fixes in 7.4.888, 8.0.0736, 8.0.0974
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
  if winwidth(0) > 90 || &filetype == 'nerdtree'
    return fugitive#head()
  endif
  return ''
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
map <Leader>vp :VimuxPromptCommand<CR>
" Run last command executed by VimuxRunCommand
map <Leader>vl :VimuxRunLastCommand<CR>

"работа тегами (ctags, ctrlP, tagbar, vim-tags)
" vim-tags
let g:vim_tags_auto_generate = 0
let g:vim_tags_ignore_files = ['.gitignore', '.svnignore', '.cvsignore', '.ctagsignore']
"let vim_tags_ctags_binary = /usr/local/bin/ctags "for macOS only
nnoremap <f8> :TagsGenerate!<cr>
" :nnoremap <F8> :!ctags -R --fields=+l --tag-relative=yes --exclude=.git --exclude=.gitignore -f .git/tags 2>/dev/null<CR>
nnoremap <silent> <Leader>tb :TagbarToggle<CR>
" nnoremap <leader>l :call ToggleLocationList()<CR>

" TagList
map <F10> :TlistToggle<cr>
vmap <F10> <esc>:TlistToggle<cr>
imap <F10> <esc>:TlistToggle<cr>

" " CScope
" set csto=0
" nnoremap <leader>fa :call CscopeFindInteractive(expand('<cword>'))<CR>
" let g:cscope_silent = 1
" set cscopetag

" " CtrlP
" nnoremap <Leader>fu :CtrlPFunky<Cr>
" " narrow the list down with a word under cursor
" nnoremap <Leader>fU :execute 'CtrlPFunky ' . expand('<cword>')<Cr>
" let g:ctrlp_show_hidden = 1
" set wildignore+=*.a,*.o,*.bmp,*.gif,*.jpg,*.jpeg,*.ico,*.png,*.DS_Store,.git,.hg,.svn,*.swp,*.tmp
" nnoremap <leader>. :CtrlPTag<cr>

" vim-syntastic
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 0
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
nnoremap <Leader>e :Errors<Cr>

" Unite
"nnoremap <Leader>p :Unite file_rec/async<cr>
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

"НАСТРОЙКИ СВОРАЧИВАНИЯ БЛОКОВ ТЕКСТА (фолдинг)
"zc                        свернуть блок
"zo                        развернуть блок
"zM                        закрыть все блоки
"zR                        открыть все блоки
"za                        инвертирование
"zf                        см :set foldmethod=manual
" set foldenable            "включить свoрачивание
:set foldenable!           " turn off folding
" set foldmethod=syntax     "сворачивание на основе синтаксиса
:set foldmethod=indent    "сворачивание на основе отступов
":set foldmethod=manual    "выделяем участок с помощью v и говорим zf
":set foldmethod=marker    "сворачивание на основе маркеров в тексте
":set foldmarker=bigin,end "задаем маркеры начала и конца блока
set foldcolumn=2 " показать полосу для управления сворачиванием
" set foldlevel=5 " кол-во открытых уровней вложенности при открытии файла
set foldlevelstart=99
" set foldopen=all " автоматическое открытие сверток при заходе в них
set foldnestmax=1

" Easy Align
" Start interactive EasyAlign in visual mode (e.g. vipga)
xmap ga <Plug>(EasyAlign)
" Start interactive EasyAlign for a motion/text object (e.g. gaip)
nmap ga <Plug>(EasyAlign)

"НАСТРОЙКИ ПОИСКА ТЕКСТА В ОТКРЫТЫХ ФАЙЛАХ

set ignorecase " ics - поиск без учёта регистра символов
set smartcase " - если искомое выражения содержит символы в верхнем регистре - ищет с учётом регистра, иначе - без учёта
set hlsearch " подсветка результатов поиска
set incsearch " поиск фрагмента по мере его набора
" поиск выделенного текста (начинать искать фрагмент при его выделении)
vnoremap <silent>* <ESC>:call VisualSearch()<CR>/<C-R>/<CR>
vnoremap <silent># <ESC>:call VisualSearch()<CR>?<C-R>/<CR>

"НАСТРОЙКИ ГОРЯЧИХ КЛАВИШ
" <leader> F3 - рекурсивный поиск по файлам (плагин grep.vim)
nnoremap <leader><F3> :Rgrep<cr>
" <F3> - поиск в открытых буферах
nnoremap <F3> :GrepBuffer<cr>

" Enable true color
if exists('+termguicolors')
  let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
  set termguicolors
endif

call yankstack#setup() " fix to vim-surround 'S' keybin works with yankstack plug

" turn off search highlight by presing space
" :noremap <silent> <Space> :nohlsearch<Bar>:echo<CR>
:noremap <silent> <Space> :<C-u>nohlsearch<CR><C-l>

" list buffers keybinds
nnoremap [b :bprevious
nnoremap ]b :bnext
nnoremap [B :bfirst
nnoremap ]B :blast
map <F6> :bprevious<cr>
vmap <F6> <esc>:bprevious<cr>i
imap <F6> <esc>:bprevious<cr>i
map <F7> :bnext<cr>
vmap <F7> <esc>:bnext<cr>i
imap <F7> <esc>:bnext<cr>i
" F5 - просмотр списка буферов
" nmap <F5> :BufExplorerVerticalSplit<CR>
nmap <F5> :BufExplorer<CR>

" past current buffer path instead %% in Ex editor line
cnoremap <expr> %% getcmdtype() == ':' ? expand('%:h').'/' : '%%'

" jump to next/previous search match and center current line on screen
noremap <Leader>n nzz
noremap <Leader>N Nzz

" easymotion TEST!!!!!!!
let g:bufExplorerDisableDefaultKeyMapping = 1
map <Leader><Leader>w <Plug>(easymotion-bd-w)
nmap <Leader><Leader>w <Plug>(easymotion-overwin-w)
nmap <Leader>w <Plug>(easymotion-w)
nmap <Leader>b <Plug>(easymotion-b)
map <Leader>j <Plug>(easymotion-j)
map <Leader>k <Plug>(easymotion-k)
let g:EasyMotion_startofline = 0 " keep cursor column when JK motion"
let g:EasyMotion_smartcase = 1
" incsearch
map /  <Plug>(incsearch-forward)
map ?  <Plug>(incsearch-backward)
map g/ <Plug>(incsearch-stay)
map z/ <Plug>(incsearch-easymotion-/)
map z? <Plug>(incsearch-easymotion-?)
map zg/ <Plug>(incsearch-easymotion-stay)

set autoindent
set pastetoggle=<f4>

" autopairing
" inoremap " ""<left>
" inoremap ' ''<left>
" inoremap ( ()<left>
" inoremap [ []<left>
" inoremap { {}<left>
inoremap {<CR> {<CR>}<ESC>O
inoremap {;<CR> {<CR>};<ESC>O

" tabs navigation
nnoremap gz :bdelete<CR>
nnoremap <Leader>o :tab sball<CR>
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

" Turns off highlighting on the bits of code that are changed, so the line that is changed is highlighted but the actual text that has changed stands out on the line and is readable.
if &diff
    highlight! link DiffText MatchParen
endif

" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made.
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
      "bufno exists AND isn't modified AND isn't in the list of buffers open in windows and tabs
      silent exec 'bwipeout' i
      let nWipeouts = nWipeouts + 1
    endif
  endfor
  echomsg nWipeouts . ' buffer(s) wiped out'
endfunction

command! Ball :call DeleteInactiveBufs()

" NERDTree
" For toggling
" nmap <C-n> :NERDTreeToggle<CR>
" noremap <Leader>n :NERDTreeToggle<cr>
" noremap <Leader>f :NERDTreeFind<cr>
let NERDTreeShowHidden=1
let NERDTreeIgnore=['\.pyc$', '\.vim$', '\~$', '\.git$', '.DS_Store']
" Close nerdtree and vim on close file
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif
map <F2> :NERDTreeToggle<CR>
" autoopen NERDTree when vim starts up and no files were specified
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
autocmd StdinReadPre * let s:std_in=1
" close Vim if NerdTree is last opened buffer
" autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

" Avoid unintentional switches to Ex mode.
nmap Q q

" clang_complete
let s:uname = system("echo -n \"$(uname)\"")
let s:uname_host = system("echo -n \"$(uname -n)\"")
if !v:shell_error && s:uname_host =~ "21-school"
  let g:clang_library_path='/Library/Developer/CommandLineTools/usr/lib/'
elseif !v:shell_error && s:uname == "Linux" && (s:uname_host == "pc-home" || s:uname_host == "laptop-acer")
  let g:clang_library_path='/usr/lib/'
elseif !v:shell_error && s:uname == "Linux" && system("echo -n \"$(whoami)\"") == "root"
  let g:clang_library_path='/usr/lib/clang/'
endif
let g:clang_snippets=1
let g:clang_trailing_placeholder=1
let g:clang_complete_optional_args_in_snippets=1
let g:clang_auto_select=1

" backup and swap files settings
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

" templates
function! CanClassHPP()
  r~/.vim/templates/CanClass.class.hpp
endfunction
command CanClassHPP call CanClassHPP()

function! CanClassCPP()
  r~/.vim/templates/CanClass.class.cpp
endfunction
command CanClassCPP call CanClassCPP()

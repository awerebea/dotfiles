set nocompatible              " be iMproved, required

" {{{ Set the list of hosts to use the full-featured configuration
let hosts_list = ["thinkpad", "air.local"]
" Determine current hostname
let current_host = substitute(system('hostname'), '\n', '', '')
" Check if the current host is in the list and set the flag variable if it is
if index(hosts_list, current_host) >= 0
  let use_feature = 'true'
endif
unlet hosts_list current_host
" }}}

" {{{ Install vim-plug if not found
let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent !export GIT_SSL_NO_VERIFY=true
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim
  \ --create-dirs
  \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif
" ]}}

" {{{ Run PlugInstall if there are missing plugins
if has("autocmd")
  augroup installMissedPlugins
    autocmd!
    autocmd VimEnter * if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
      \| PlugInstall --sync | source $MYVIMRC | endif
  augroup END
endif
" }}}

" {{{ Specify a directory for plugins
" - For Neovim: stdpath('data') . '/plugged'
" - Avoid using standard Vim directory names like 'plugin'
call plug#begin('~/.vim/plugged')
" Vim motions on speed!
Plug 'asvetliakov/vim-easymotion'
" Easy comment/uncomment lines
Plug 'preservim/nerdcommenter'
" Easy 'surroundings': parentheses, brackets, quotes, XML tags, and more
Plug 'tpope/vim-surround'
" Pairs of handy bracket mappings.
Plug 'tpope/vim-unimpaired'
" This script implements transparent editing of gpg encrypted files
Plug 'jamessan/vim-gnupg'
" A command-line fuzzy finder in Vim
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'
" Terraform
Plug 'hashivim/vim-terraform'
if exists('use_feature')
" Syntax highlighting for Kitty terminal config files
Plug 'fladson/vim-kitty'
endif
" Vim plugins for visually displaying indent levels in code
Plug 'Yggdroot/indentLine'
" Turns default register into a stack, and lets cycle through the items in the
" stack after doing a paste
Plug 'maxbrunsfeld/vim-yankstack'

" Initialize plugin system
call plug#end()
" }}}

set hidden
runtime macros/matchit.vim
filetype plugin indent on    " required

" Put your non-Plugin stuff after this line

" Set <space> as leader key
let g:mapleader = "\<Space>"

:set viminfo='1000,<1000,s200,h   " Increasing the buffer size

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

set undolevels=2048

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

" Yankstack
nmap <leader>p <Plug>yankstack_substitute_older_paste
nmap <leader>P <Plug>yankstack_substitute_newer_paste

set ignorecase
set smartcase
set hlsearch
set incsearch
" Search visually selected text
vnoremap <silent>* <ESC>:call VisualSearch()<CR>/<C-R>/<CR>
vnoremap <silent># <ESC>:call VisualSearch()<CR>?<C-R>/<CR>

" FIXME

" Fix to vim-surround 'S' keybin works with yankstack plug
call yankstack#setup()

" Turn off search highlight by presing space
nnoremap <silent> <leader>/ :<C-u>nohlsearch<CR><C-l>
nnoremap <Esc><Esc> :<C-u>nohlsearch<CR><C-l>


" {{{ Easymotion
let g:EasyMotion_smartcase = 1
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

" {{{ Tabs navigation
" Switch tab
nmap <leader><Left> :tabprevious<CR>
nmap <leader><Right> :tabnext<CR>
nmap <leader>th :tabfirst<CR>
nmap <leader>tn :tabnext<CR>
nmap <leader>tp :tabprev<CR>
nmap <leader>tl :tablast<CR>
nmap <leader>td :tabclose<CR>
nmap <leader>to :tabonly<CR>
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


" {{{ Backup and Swap files settings
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


" Quick launch last used macros
nnoremap <leader>2 @@

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

" identline settings
let g:indentLine_char = '│'

" vim-which-key
set timeoutlen=500       " Keystrokes timeout
nnoremap <silent> <leader> :call VSCodeNotify('whichkey.show')<CR>

" Search and replace selected test
vnoremap <leader><leader>re "hy:%s/<C-r>h//gc<left><left><left>

" Rename symbol
nnoremap <silent> <leader>rn :call VSCodeNotify('editor.action.rename')<CR>
" Show symbols in file
nnoremap <silent> <leader>t :call VSCodeNotify('workbench.action.gotoSymbol')<CR>
" Show symbols in workspace
nnoremap <silent> <leader>at :call VSCodeNotify('workbench.action.showAllSymbols')<CR>
" Show all editors by most recently used
nnoremap <silent> <leader><cr> :call VSCodeNotify('workbench.action.showAllEditorsByMostRecentlyUsed')<CR>
" Show all editors
nnoremap <silent> <leader><leader><cr> :call VSCodeNotify('workbench.action.showAllEditors')<CR>
" Open file in Vim (fullscreen)
nnoremap <silent> <leader>vv :call VSCodeNotify('multiCommand.openInVimFullscreen')<CR>
" Toggle auto hard-wrap long lines
nnoremap <silent> <leader>aw :call VSCodeNotify('rewrap.toggleAutoWrap')<CR>
" Spell checking
" Toggle for current workspace
nnoremap <silent> <leader>ssa :call VSCodeNotify('cSpell.toggleEnableSpellChecker')<CR>
" Open file explorer
nnoremap <silent> <leader>e :call VSCodeNotify('workbench.view.explorer')<CR>
" Find and replace in files
nnoremap <silent> <leader>rg :call VSCodeNotify('workbench.action.findInFiles')<CR>
nnoremap <silent> <leader>ff :call VSCodeNotify('workbench.action.findInFiles')<CR>
nnoremap <silent> <leader>fr :call VSCodeNotify('workbench.action.replaceInFiles')<CR>
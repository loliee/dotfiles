" mloliee vimrc

set nocompatible              " be iMproved, required
filetype off                  " required
set modelines=0

" -----------------------------------------------------------
" Vundle init
" -----------------------------------------------------------

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" let Vundle manage Vundle, required
Plugin 'gmarik/Vundle.vim'

" plugin on GitHub repo

Plugin 'rking/ag.vim'
Plugin 'markcornick/vim-bats'
Plugin 'ekalinin/Dockerfile.vim'
Plugin 'vim-airline/vim-airline'
Plugin 'editorconfig/editorconfig-vim'
Plugin 'tpope/vim-fugitive'
Plugin 'junegunn/fzf'
Plugin 'junegunn/goyo.vim'
Plugin 'fatih/vim-go'
Plugin 'tpope/vim-markdown'
Plugin 'scrooloose/syntastic'
Plugin 'mhinz/vim-startify'
Plugin 'mv/mv-vim-nginx'
Plugin 'ntpeters/vim-better-whitespace'
Plugin 'w0ng/vim-hybrid'

call vundle#end()            " required
filetype plugin indent on    " required

" -----------------------------------------------------------
" Global
" -----------------------------------------------------------
set antialias
set cursorline                    " Highlight current line
set encoding=utf-8
set fileencoding=utf-8
set scrolloff=3
set hidden
set cursorline
set ttyfast
set ruler
set backspace=indent,eol,start
set laststatus=2
set relativenumber
set number
set smartcase
set showmode
set showcmd
set showmatch                     " Highlight matching [{()}]
set paste
set guifont=Hack:h14
set undofile                      " Persistent undo
set undodir=~/.vim/undofiles      " Do not add ~un files everywhere I go
set wildmode=list:longest         " Complete files like a shell.
set wildmenu                      " Enhanced command line completion.
set lazyredraw                    " Redraw only when we need to.
set novisualbell
set noerrorbells
set history=1000
syntax enable

" -----------------------------------------------------------
" Style
" -----------------------------------------------------------
set background=dark
colorscheme hybrid
set hlsearch                      " Highlight search results
set incsearch                     " Makes search act like in modern browsers

" Set the terminal's title

if &term == 'screen'
  set t_ts=k
  set t_fs=\
elseif &term == 'screen' || &term == 'xterm'
  set title
endif

" Airline configuration
let g:airline#extensions#tabline#enabled = 1

" set airline theme
let g:airline_theme='base16'
let g:airline_powerline_fonts=1
let g:airline#extensions#branch#enabled=1
let g:airline#extensions#branch_prefix#enabled=1
let g:airline#extensions#syntastic#enabled=1
if !exists('g:airline_symbols')
  let g:airline_symbols = {}
endif

" unicode symbols
let g:airline_left_sep = '▶'
let g:airline_right_sep = '◀'
let g:airline_symbols.linenr = '¶'
let g:airline_symbols.branch = ''
let g:airline_symbols.paste = 'Þ'
let g:airline_symbols.whitespace = 'Ξ'
let g:airline_symbols.readonly = ''

" Goyo
let g:goyo_width = 120

" -----------------------------------------------------------
" Indent - Tabs/Spaces
" -----------------------------------------------------------
set autoindent
set nowrap                        " don't wrap lines
set tabstop=2 shiftwidth=2        " a tab is two spaces (or set this to 4)
set expandtab                     " use spaces, not tabs (optional)
set smarttab
set backspace=indent,eol,start    " backspace through everything in insert mode

set listchars=tab:▸\ ,eol:¬,trail:·,extends:>,precedes:<
let g:better_whitespace_verbosity = 1

" -----------------------------------------------------------
" Configure Explorer
" -----------------------------------------------------------
let g:netrw_banner         = 0
let g:netrw_winsize        = 15
let g:netrw_preview        = 1
let g:netrw_altv           = 1
let g:netrw_fastbrowse     = 2
let g:netrw_keepdir        = 0
let g:netrw_retmap         = 1
let g:netrw_silent         = 1
let g:netrw_special_syntax = 1

" ------------------------------------------------------------
" Configure syntastic
" ------------------------------------------------------------
":wlet g:syntastic_aggregate_errors = 1
let g:syntastic_javascript_checkers = ['jshint']
let g:syntastic_php_checkers = ['php', 'phpcs']
let g:syntastic_php_phpcs_args='--standard=PSR2 -n'

" Better syntastic symbols
let g:syntastic_error_symbol = '✗'
let g:syntastic_warning_symbol = '⚠'

" ------------------------------------------------------------
" Configure Startify
" ------------------------------------------------------------
let g:startify_list_order = ['bookmarks', 'files', 'dir', 'sessions']
let g:startify_session_dir = '~/.vim/session'
let g:startify_bookmarks = [ '~/.vimrc' ]
let g:startify_enable_special = 0

" -----------------------------------------------------------
" Bindings
" -----------------------------------------------------------

" Do things right (remove arrows nav)
nnoremap <up> <nop>
nnoremap <down> <nop>
nnoremap <left> <nop>
nnoremap <right> <nop>
inoremap <up> <nop>
inoremap <down> <nop>
inoremap <left> <nop>
inoremap <right> <nop>
nnoremap j gj
nnoremap k gk

" Define , as leader key

let mapleader = ","
nnoremap ; :

" Paste toggle
set pastetoggle=<leader>p

" FZF
nnoremap <silent> <leader>f :FZF<CR>

" Open ag.vim
nnoremap <leader>a :Ag

" Remove help
inoremap <F1> <ESC>
nnoremap <F1> <ESC>
vnoremap <F1> <ESC>

" Open on new window
nnoremap <F2> <C-w>v<C-w>l

" Open new tab
nnoremap <F1> :tabnew<CR>
inoremap <F1> <Esc>:tabnew<CR>

" Remap window moves
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Indent line
nmap <S-Tab> <<
nmap <Tab> >>
vmap <S-Tab> <gv
vmap <Tab> >gv

" Tab managment
nmap <leader>d :tabnext<CR>
nmap <leader>q :tabprevious<CR>

" Remove trailing whitespaces
nnoremap <silent> <leader>w :StripWhitespace<CR>

" Display invisible chars
nmap <leader>l :set list! <CR>

" Turn off search highlight
nnoremap <leader><space> :nohlsearch<CR>

" Syntastic check
nmap <leader>s :SyntasticCheck <CR>

" Goyo
nmap <leader>g :Goyo<CR>

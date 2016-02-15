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

Plugin 'rking/ag.vim'
Plugin 'markcornick/vim-bats'
Plugin 'ekalinin/Dockerfile.vim'
Plugin 'vim-airline/vim-airline'
Plugin 'editorconfig/editorconfig-vim'
Plugin 'tommcdo/vim-exchange'
Plugin 'tpope/vim-fugitive'
Plugin 'junegunn/fzf'
Plugin 'junegunn/goyo.vim'
Plugin 'fatih/vim-go'
Plugin 'tpope/vim-markdown'
Plugin 'scrooloose/syntastic'
Plugin 'mv/mv-vim-nginx'
Plugin 'ntpeters/vim-better-whitespace'
Plugin 'w0ng/vim-hybrid'
Plugin 'edkolev/tmuxline.vim'
Plugin 'SirVer/ultisnips'
Plugin 'terryma/vim-multiple-cursors'

call vundle#end()            " required
filetype plugin indent on    " required

" -----------------------------------------------------------
" Global
" -----------------------------------------------------------

set autowrite                     " Automatically :write before running commands
set clipboard=unnamed             " For OSX clipboard
set encoding=utf-8                " UTF-8 is the encoding you want for your files
set hidden                        " Handle multiple buffers better.
set history=1000                  " Store lots of :cmdline history
set hlsearch                      " Highlight search results
set incsearch                     " Makes search act like in modern browsers
set lazyredraw                    " Redraw only when we need to.
set laststatus=2                  " Always display the status line
set novisualbell                  "
set noerrorbells                  " No error bells
set showmode                      " Show mode -- INSERT --
set showcmd                       " Show commands
set showmatch                     " Highlight matching [{()}]
set ttimeout                      " Fast VIM
set ttimeoutlen=100
set ttyfast
set undofile                      " Persistent undo
set undodir=~/.vim/undofiles      " Do not add ~un files everywhere I go
set wildmode=list:longest         " Complete files like a shell.
set wildmenu                      " Enhanced command line completion.
syntax enable

" Store swap files in fixed location, not current directory.
"
" The '//' at the end ensure the swap file name will be built from the complete
" path to the file with all path separators substituted to percent '%' signs.
"
" This will ensure file name uniqueness in the preserve directory.
set dir=~/.vimswap//,/var/tmp//,/tmp//,.

" -----------------------------------------------------------
" Style
" -----------------------------------------------------------

colorscheme hybrid

set antialias
set background=dark               " Dark bg
set guifont=Hack:h14              " Define hack as font, powerline
set cursorline                    " Highlight current line
set ruler                         " Display ruler
set relativenumber                " Set relative number for fast dd/yy
set number                        " Display line number for current line

" Set the terminal's title
if &term == 'screen'
  set t_ts=k
  set t_fs=\
elseif &term == 'screen' || &term == 'xterm'
  set title
endif

" Let tabs display only filenames instead of fullpath
set guitablabel=\[%N\]\ %t\ %M

" Airline configuration
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tmuxline#enabled = 0

" set airline theme
let g:airline_theme='tomorrow'
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

set nowrap                        " don't wrap lines
set tabstop=2 shiftwidth=2        " a tab is two spaces (or set this to 4)
set expandtab                     " use spaces, not tabs (optional)
set smarttab
set backspace=indent,eol,start    " backspace through everything in insert mode
set autoindent                    " match indentation of previous line

set listchars=tab:▸\ ,eol:¬,trail:·,extends:>,precedes:<
let g:better_whitespace_verbosity = 1
let g:better_whitespace_filetypes_blacklist=['diff', 'gitcommit', 'unite', 'qf', 'help', 'markdown']

" -----------------------------------------------------------
" Syntax
" -----------------------------------------------------------

autocmd BufRead .aliases setlocal ft=sh
autocmd BufRead ~/.dnsmasq.d/* setlocal ft=dnsmasq

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

let g:syntastic_aggregate_errors = 1
let g:syntastic_javascript_checkers = ['jshint']
let g:syntastic_php_checkers = ['php', 'phpcs']
let g:syntastic_php_phpcs_args='--standard=PSR2 -n'

" Better syntastic symbols
let g:syntastic_error_symbol = '✗'
let g:syntastic_warning_symbol = '⚠'

" -----------------------------------------------------------
" Bindings
" -----------------------------------------------------------

" Define , as leader key
let mapleader = ","

" Escape with Ctrl-Space
inoremap <NUL> <ESC>
nnoremap <NUL> <ESC>
vnoremap <NUL> <ESC>

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

" Fast moves up/down Alt-j / Alt-k
nnoremap Ï :+3<CR>
nnoremap È :-3<CR>

" Remove help
inoremap <F1> <ESC>
nnoremap <F1> <ESC>
vnoremap <F1> <ESC>

" Open on new window
nnoremap <F2> <C-w>v<C-w>l

" Tab managment
nnoremap <F1> :tabnew<CR>
inoremap <F1> <Esc>:tabnew<CR>
nmap <leader>d :tabnext<CR>
nmap <leader>q :tabprevious<CR>
nmap <leader>c :tabclose<CR>

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

" Move visual selection with Alt-j / Alt-k
vnoremap Ï :m '>+1<CR>gv=gv
vnoremap È :m '<-2<CR>gv=gv

" Insert new empty lines
nmap œ o<Esc>k
nmap Œ O<Esc>j

" Force sudo write
cmap w!! w !sudo tee > /dev/null %

" Yank all lines
nmap <leader>ya :%y+<CR>

" Paste toggle
set pastetoggle=<leader>p

" Display invisible chars
nmap <leader>l :set list!<CR>

" Turn off search highlight
nnoremap <leader><space> :nohlsearch<CR>

" Open ag.vim
nnoremap <leader>a :Ag

" Open fzf
nnoremap <silent> <leader>f :FZF<CR>

" Remove trailing whitespaces
nnoremap <silent> <leader>w :StripWhitespace<CR>

" Syntastic check
nmap <leader>s :SyntasticCheck<CR>

" Goyo
nmap <leader>z :Goyo<CR>

" Exchange
let g:exchange_no_mappings=1
nmap cx <Plug>(Exchange)
vmap X <Plug>(Exchange)
nmap cxc <Plug>(ExchangeClear)
nmap cxx <Plug>(ExchangeLine)

" Git commands
if !exists(':Ga')
  :command Ga execute ":Silent !git a %:p"
  :command Gc execute ":Silent !git commit"
  :command Gca execute ":Silent !git ca"
  :command Gd execute ":!clear && git diff"
  :command Gdc execute ":!clear && git diff --cached"
  :command Gl execute ":Silent !git lg"
  :command Gco execute ":Silent !git co -p %:p"
  :command Gs execute ":!clear && git st"
  :command Gr execute ":Silent !git reset %:p"
  :command Gt execute ":Silent !tig -p %:p"
endif

" Open tig
nmap <leader>t :Silent !tig<CR><CR>

" -----------------------------------------------------------
" Functions
" -----------------------------------------------------------

" Command alias, redraw window
command! -nargs=1 Silent
\ | execute ':silent !clear'
\ | execute ':silent '.<q-args>
\ | execute ':redraw!'

" -----------------------------------------------------------
" Local config
" -----------------------------------------------------------

if filereadable($HOME . "/.vimrc.local")
  source ~/.vimrc.local
endif

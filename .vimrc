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
Plugin 'tpope/vim-surround'
Plugin 'scrooloose/syntastic'
Plugin 'mv/mv-vim-nginx'
Plugin 'ntpeters/vim-better-whitespace'
Plugin 'w0ng/vim-hybrid'
Plugin 'SirVer/ultisnips'
Plugin 'terryma/vim-multiple-cursors'

call vundle#end()            " required
filetype plugin indent on    " required

" -----------------------------------------------------------
" Load .vimrc.min
" -----------------------------------------------------------

if filereadable($HOME . "/.vimrc.min")
  source ~/.vimrc.min
endif

" -----------------------------------------------------------
" Style
" -----------------------------------------------------------

set cursorline                    " Highlight current line
colorscheme hybrid                " Set hybrid theme, inspired from tommorow
set guifont=Hack:h14              " Define hack as font, powerline

" Plugins
" =======

" -----------------------------------------------------------
" Airline
" -----------------------------------------------------------
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tmuxline#enabled = 0
" Show just the filename for tab
let g:airline#extensions#tabline#fnamemod = ':t'

" set airline theme
let g:airline_theme='badwolf'
let g:airline_powerline_fonts=1
let g:airline#extensions#branch#enabled=1
let g:airline#extensions#branch_prefix#enabled=1
let g:airline#extensions#syntastic#enabled=1
if !exists('g:airline_symbols')
  let g:airline_symbols = {}
endif

" unicode symbols
let g:airline_left_sep = ''
let g:airline_left_alt_sep = ''
let g:airline_right_sep = ''
let g:airline_symbols.linenr = '¶'
let g:airline_symbols.branch = ''
let g:airline_symbols.paste = 'Þ'
let g:airline_symbols.whitespace = 'Ξ'
let g:airline_symbols.readonly = ''

" ------------------------------------------------------------
" Goyo
" ------------------------------------------------------------
let g:goyo_width = 120

" -----------------------------------------------------------
" better Whitespace
" -----------------------------------------------------------

let g:better_whitespace_verbosity = 1
let g:better_whitespace_filetypes_blacklist=['diff', 'gitcommit', 'unite', 'qf', 'help', 'markdown']

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
" Bindings, command key send <NUL> value
" -----------------------------------------------------------

" Open ag.vim
nnoremap <leader>a :Ag

" Open fzf
nnoremap <silent> <leader>f :FZF<CR>

" Syntastic check
nmap <leader>s :SyntasticCheck<CR>

" Open tig
nmap <leader>t :Silent !tig<CR><CR>

" Remove trailing whitespaces
nnoremap <silent> <leader>w :StripWhitespace<CR>

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
  :command Gc execute ":Silent !git c"
  :command Gca execute ":Silent !git ca"
  :command Gd execute ":!clear && git d"
  :command Gdc execute ":!clear && git dc"
  :command Gl execute ":Silent !git lg"
  :command Gco execute ":Silent !git co -p %:p"
  :command Gst execute ":!clear && git st"
  :command Gr execute ":Silent !git r %:p"
  :command Gru execute ":Silent !git ru"
  :command Gt execute ":Silent !tig -p %:p"
  :command Gpu execute ":Silent !git pu"
  :command Gpo execute ":!clear && git po $( git rev-parse --abbrev-ref HEAD )"
  :command Gpof execute "!clear && git pof $( git rev-parse --abbrev-ref HEAD )"
endif


" -----------------------------------------------------------
" Local config
" -----------------------------------------------------------

if filereadable($HOME . "/.vimrc.local")
  source ~/.vimrc.local
endif

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
Plugin 'pearofducks/ansible-vim'
Plugin 'markcornick/vim-bats'
Plugin 'ekalinin/Dockerfile.vim'
Plugin 'vim-airline/vim-airline'
Plugin 'editorconfig/editorconfig-vim'
Plugin 'tommcdo/vim-exchange'
Plugin 'tpope/vim-fugitive'
Plugin 'airblade/vim-gitgutter'
Plugin 'junegunn/fzf'
Plugin 'junegunn/goyo.vim'
Plugin 'fatih/vim-go'
Plugin 'tpope/vim-markdown'
Plugin 'tpope/vim-surround'
Plugin 'scrooloose/syntastic'
Plugin 'mv/mv-vim-nginx'
Plugin 'ntpeters/vim-better-whitespace'
Plugin 'SirVer/ultisnips'
Plugin 'loliee/vim-patatetoy'
Plugin 'loliee/vim-snippets'
Plugin 'terryma/vim-multiple-cursors'
Plugin 'StanAngeloff/php.vim'
Plugin 'othree/html5.vim'

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
let g:patatetoy_custom_term_colors=1
colorscheme patatetoy                " Set patatetoy theme, inspired from tommorow
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
let g:airline_theme='patatetoy'
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
let g:syntastic_style_error_symbol = '✗'
let g:syntastic_style_warning_symbol = '⚠'

" -----------------------------------------------------------
" UtilSnips config
" -----------------------------------------------------------

let g:snips_author = "Maxime Loliée"
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsJumpForwardTrigger="<c-b>"
let g:UltiSnipsJumpBackwardTrigger="<c-z>"

" -----------------------------------------------------------
" Bindings, command key send <NUL> value
" -----------------------------------------------------------

" Open ag.vim
nnoremap <leader>a :Ag

" Open fzf
nnoremap <silent> <leader>f :FZF<CR>
nnoremap <silent> <leader>r :FZFA<CR>

" Syntastic check
nmap <leader>s :SyntasticCheck<CR>

" Open tig
nmap <leader>t :Silent !tig %:p<CR><CR>

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

" -----------------------------------------------------------
" COMMANDS
" -----------------------------------------------------------

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
  :command Gp execute ":Silent !git p"
  :command Gpf execute ":Silent !git pf"
endif

" Wrapper arround fzf, setup ag to not ignore files
command! -nargs=0 FZFA
      \  execute ':let $FZF_DEFAULT_COMMAND_DEFAULT=$FZF_DEFAULT_COMMAND'
      \ | execute ':let $FZF_DEFAULT_COMMAND="ag -l -a --hidden"'
      \ | execute ':FZF'
      \ | execute ':let $FZF_DEFAULT_COMMAND=$FZF_DEFAULT_COMMAND_DEFAULT'

" -----------------------------------------------------------
" Local config
" -----------------------------------------------------------

if filereadable($HOME . "/.vimrc.local")
  source ~/.vimrc.local
endif

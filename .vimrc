" mloliee vimrc

set nocompatible              " be iMproved, required
filetype off                  " required
set modelines=0

" -----------------------------------------------------------
" Plug init
" -----------------------------------------------------------
" Specify a directory for plugins
" - For Neovim: stdpath('data') . '/plugged'
" - Avoid using standard Vim directory names like 'plugin'
call plug#begin('~/.vim/plugged')

Plug 'Glench/Vim-Jinja2-Syntax'
Plug 'StanAngeloff/php.vim'
Plug 'airblade/vim-gitgutter'
Plug 'editorconfig/editorconfig-vim'
Plug 'ekalinin/Dockerfile.vim'
Plug 'hashivim/vim-hashicorp-tools'
Plug 'itchyny/lightline.vim'
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'
Plug 'junegunn/goyo.vim'
Plug 'loliee/vim-patatetoy'
Plug 'markcornick/vim-bats'
Plug 'mv/mv-vim-nginx'
Plug 'othree/html5.vim'
Plug 'pearofducks/ansible-vim'
Plug 'previm/previm'
Plug 'rust-lang/rust.vim'
Plug 'stephpy/vim-yaml'
Plug 'tommcdo/vim-exchange'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-liquid'
Plug 'tpope/vim-markdown'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-surround'
Plug 'vim-ruby/vim-ruby'
Plug 'w0rp/ale'

" Initialize plugin system
call plug#end()

filetype plugin indent on    " required

" Set patatetoy theme, inspired from tommorow
try
  let g:patatetoy_custom_term_colors=1
  colorscheme patatetoy
catch /^Vim\%((\a\+)\)\=:E185/
  " Should fail only at the first plugin install execution
endtry

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
set guifont=iosevka:h14           " Define hack as font, powerline

" Plugins
" =======

" -----------------------------------------------------------
" Ansible vim
" -----------------------------------------------------------

" Reset indent after two new lines
let g:ansible_unindent_after_newline = 1
" Ensure compatibility with stephpy/vim-yaml
let g:ansible_yamlKeyName = 'yamlKey'

" -----------------------------------------------------------
" Fugitive
" -----------------------------------------------------------

" Ensure that this plugin works well with Tim Pope's fugitive
let g:EditorConfig_exclude_patterns = ['fugitive://.\*']

" -----------------------------------------------------------
" Fzf
" -----------------------------------------------------------
let g:fzf_layout = {'window': {'width': 1, 'height': 1}}

" -----------------------------------------------------------
" Lightline
" -----------------------------------------------------------
let g:lightline = {
\  'colorscheme': 'patatetoy',
\  'active': {
\    'left': [ [ 'mode', 'paste' ],
\              [ 'gitbranch', 'readonly', 'filename', 'modified' ] ]
\  },
\  'component_function': {
\    'gitbranch': 'fugitive#head'
\  },
\  }

" Git gutter
highlight GitGutterAdd ctermfg=02
highlight GitGutterChange ctermfg=03
highlight GitGutterDelete ctermfg=09
highlight GitGutterChangeDelete ctermfg=208

" Update sign column every quarter second
set updatetime=250

" ------------------------------------------------------------
" Goyo
" ------------------------------------------------------------
let g:goyo_width = 120

" ------------------------------------------------------------
" Configure ale
" ------------------------------------------------------------

let g:ale_sign_column_always = 1
let g:ale_sign_error = '✗'
let g:ale_sign_warning = '⚠'
highlight ALEWarningSign ctermfg=03

let g:ale_fix_on_save = 1
let b:ale_warn_about_trailing_whitespace = 1
let g:ale_fixers = {
\  '*': ['remove_trailing_lines', 'trim_whitespace']
\}

" Previm
let g:previm_open_cmd = 'open -a Firefox'
nnoremap <silent> <leader><CR> :PrevimOpen<CR>

" Python mode
let g:pymode_python = 'python3'

" -----------------------------------------------------------
" Rg config
" -----------------------------------------------------------
let g:rg_command_args = '--column --line-number --no-heading --color=always --smart-case'

" -----------------------------------------------------------
" UtilSnips config
" -----------------------------------------------------------

let g:snips_author = "Maxime Loliée"
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsJumpForwardTrigger="<Down>"
let g:UltiSnipsJumpBackwardTrigger="<Up>"

" -----------------------------------------------------------
" Bindings, command key send <NUL> value
" -----------------------------------------------------------

" Fzf
nnoremap <silent> <leader>f :FZF<CR>
nnoremap <silent> <leader>a :FZFA<CR>
nnoremap <silent> <leader>h :History<CR>
nnoremap <silent> <leader>c :FZFHC<CR>
nnoremap <leader>r :Rg<Space>

" Ale fix
nmap <leader>s :ALEFix<CR>
nmap <leader>se :let g:ale_fix_on_save=1<CR>
nmap <leader>sd :let g:ale_fix_on_save=0<CR>

" Open tig
nmap <leader>t :execute ":Silent !tig ".GetSmartWd()<CR><CR>

" Enable/Disable spell checking
nnoremap <silent> <leader>g :GrammarousCheck<CR>

" Goyo
nmap <leader>z :Goyo<CR>

" Exchange
let g:exchange_no_mappings=1
nmap cx <Plug>(Exchange)
vmap X <Plug>(Exchange)
nmap cxc <Plug>(ExchangeClear)
nmap cxx <Plug>(ExchangeLine)

" ----------------------------------------------------------------------------
" <leader>S | Search it
" ----------------------------------------------------------------------------
function! s:duckduck(pat)
  let q = ''.substitute(a:pat, '["\n]', ' ', 'g')
  let q = substitute(q, '[[:punct:] ]',
       \ '\=printf("%%%02X", char2nr(submatch(0)))', 'g')
  call system(printf('open "https://www.duckduckgo.com/%s"', q))
endfunction

nnoremap <leader>S :call <SID>duckduck(expand("<cWORD>"))<cr>
xnoremap <leader>S "gy:call <SID>duckduck(@g)<cr>gv

" -----------------------------------------------------------
" COMMANDS
" -----------------------------------------------------------

" Git commands
:command! Ga execute ":Silent !git a ".GetSmartWd()
:command! Gc execute ":Silent !git c"
:command! Gca execute ":Silent !git ca"
:command! Gcop execute ":Silent !git cop ".GetSmartWd()
:command! -nargs=1 Gcf execute ":Silent !git cf "<f-args>
:command! Gd execute ":!clear && git d"
:command! Gdc execute ":!clear && git dc"
:command! Glg execute ":Silent !git lg"
:command! Gp execute ":Silent !git p"
:command! Gpf execute ":Silent !git pf"
:command! -nargs=1 Gs execute ":!clear && git show "<f-args>
:command! Gst execute ":!clear && git st"
:command! Gr execute ":Silent !git r ".GetSmartWd()
:command! -nargs=1 Gri execute ":!clear && git ri "<f-args>
:command! Gru execute ":Silent !git ru"

" Git Hub commands
:command! Hi execute ":Silent !hub browse -- issues"
:command! Hp execute ":Silent !hub browse -- pulls"
:command! Hpc execute ":Silent !hub browse -- \"pull/$(git rev-parse --abbrev-ref HEAD)\""
:command! Hpp execute ":!clear && hub pull-request"

" Rg  search with fzf and a small preview window
" Rg! search with fzf in fullscreen mode
command! -bang -nargs=* Rg
  \ call fzf#vim#grep('rg '. g:rg_command_args .' '. <q-args>, 1,
  \                   <bang>0 ? fzf#vim#with_preview('up:60%')
  \                         : fzf#vim#with_preview('right:50%', '?'),
  \                   <bang>0)

" Search in all files, temporarly modify FZF_DEFAULT_COMMAND
command! -nargs=0 FZFA
  \  execute ':let $FZF_DEFAULT_BK=$FZF_DEFAULT_COMMAND'
  \ | execute ':let $FZF_DEFAULT_COMMAND="fd --type f --hidden --follow --no-ignore --exclude .git"'
  \ | execute ':FZF' | execute ':let $FZF_DEFAULT_COMMAND=$FZF_DEFAULT_BK'

" Commande history without preview or default options
command! -nargs=0 FZFHC
  \  execute ':let $FZF_DEFAULT_BK=$FZF_DEFAULT_OPTS'
  \ | execute ':let $FZF_DEFAULT_OPTS=""'
  \ | execute ':History:' | execute ':let $FZF_DEFAULT_OPTS=$FZF_DEFAULT_BK'

" -----------------------------------------------------------
" Local config
" -----------------------------------------------------------

if filereadable($HOME . "/.vimrc.local")
  source ~/.vimrc.local
endif

" Setup vim-repeat plugin
silent! call repeat#set("\<Plug>MyWonderfulMap", v:count)
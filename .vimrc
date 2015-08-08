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
Plugin 'tpope/vim-fugitive'
Plugin 'scrooloose/syntastic'
Plugin 'mhinz/vim-startify'
Plugin 'editorconfig/editorconfig-vim'
Plugin 'flazz/vim-colorschemes'

" Git plugin not hosted on GitHub
Plugin 'git://git.wincent.com/command-t.git'
call vundle#end()            " required
filetype plugin indent on    " required

" -----------------------------------------------------------
" Global
" -----------------------------------------------------------
set encoding=utf-8
set fileencoding=utf-8
set scrolloff=3
set showmode
set showcmd
set hidden
set wildmenu
set wildmode=list:longest
set visualbell
set cursorline
set ttyfast
set ruler
set backspace=indent,eol,start
set laststatus=2
set relativenumber
set undofile
set paste
syntax enable

" -----------------------------------------------------------
" Style
" -----------------------------------------------------------
set background=dark
colorscheme badwolf

" -----------------------------------------------------------
" Indent - Tabs/Spaces
" -----------------------------------------------------------
set autoindent
set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab

set listchars=tab:▸\ ,eol:¬,trail:·,extends:>,precedes:<

function! <SID>StripTrailingWhitespaces()
    " Preparation: save last search, and cursor position.
    let _s=@/
    let l = line(".")
    let c = col(".")
    " Do the business:
    %s/\s\+$//e
    " Clean up: restore previous search history, and cursor position
    let @/=_s
    call cursor(l, c)
endfunction

" Only do this part when compiled with support for autocommands
if has("autocmd")
  " Enable file type detection
  filetype on

  " Syntax of these languages is fussy over tabs Vs spaces
  autocmd FileType make setlocal ts=8 sts=8 sw=8 noexpandtab
  autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab
  autocmd FileType markdown setlocal ts=2 sts=2 sw=2 expandtab

  " Customisations based on house-style (arbitrary)
  autocmd FileType javascript setlocal ts=4 sts=4 sw=4 noexpandtab

  " Treat .rst as markdown
  autocmd BufNewFile,BufRead *.rst setfiletype markdown
endif

" -----------------------------------------------------------
" Configure Explorer
" -----------------------------------------------------------
let g:netrw_browse_split = 4
let g:netrw_altv = 1
let g:netrw_winsize = -28
let g:netrw_banner = 0
let g:netrw_liststyle = 3
let g:netrw_sort_sequence = '[\/]$,*'

function! ToggleVExplorer()
  if exists("t:expl_buf_num")
      let expl_win_num = bufwinnr(t:expl_buf_num)
      if expl_win_num != -1
          let cur_win_nr = winnr()
          exec expl_win_num . 'wincmd w'
          close
          exec cur_win_nr . 'wincmd w'
          unlet t:expl_buf_num
      else
          unlet t:expl_buf_num
      endif
  else
      exec '1wincmd w'
      Vexplore
      let t:expl_buf_num = bufnr("%")
  endif
endfunction

" ------------------------------------------------------------
" Configure syntastic
" ------------------------------------------------------------
let g:syntastic_aggregate_errors = 1
let g:syntastic_javascript_checkers = ['jshint']
let g:syntastic_php_checkers = ['php', 'phpcs', 'phpmd']
let g:syntastic_php_phpcs_args='--standard=PSR2'

" ------------------------------------------------------------
" Configure Startify
" ------------------------------------------------------------
let g:startify_list_order = ['bookmarks', 'files', 'dir', 'sessions']
let g:startify_session_dir = '~/.vim/session'
let g:startify_bookmarks = [ '~/.vimrc' ]
let g:startify_enable_special = 0
let g:startify_custom_header =
  \ map(split(system('fortune | cowsay'), '\n'), '"  ". v:val') + ['','']


" -----------------------------------------------------------
" Bindings
" -----------------------------------------------------------
let mapleader = ","
nnoremap ; :

" Enable/Disable relative numbers
nnoremap <silent><leader>n :set relativenumber!<cr>

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

" Remove help
inoremap <F1> <ESC>
nnoremap <F1> <ESC>
vnoremap <F1> <ESC>

" Re-select
nnoremap <leader>v V`]

" Open on new window
nnoremap <F2> <C-w>v<C-w>l

" Open new tab
nnoremap <F1> :tabnew<CR>
inoremap <F1> <Esc>:tabnew<CR>

" Show explorer window
map <silent> <F3> :call ToggleVExplorer()<CR>

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

" Remove trailing whitespaces
nnoremap <silent> <leader>w :call <SID>StripTrailingWhitespaces()<CR>

" Display invisible chars
nmap <leader>l :set list! <CR>

" Syntastic check
nmap <leader>s :SyntasticCheck <CR>

" Git to last active tab
let g:lasttab = 1
nmap <Leader>tl :exe "tabn ".g:lasttab<CR>
au TabLeave * let g:lasttab = tabpagenr()

" Show syntax highlighting groups for word under cursor
nmap <C-S-P> :call <SID>SynStack()<CR>
function! <SID>SynStack()
  if !exists("*synstack")
    return
  endif
  echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
endfunc

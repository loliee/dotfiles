
if exists("did_load_gitcommit_userafter")
  finish
endif
let did_load_gitcommit_userafter = 1

setlocal spell
let b:ale_fixers = ['']
let g:ale_fix_on_save = 0

let &colorcolumn = "50,".join(range(72,999),",")

if exists("did_load_markdown_userafter")
  finish
endif
let did_load_markdown_userafter = 1

let b:ale_linters = ['mdl']
let b:ale_fixers = ['']
let g:ale_fix_on_save = 0

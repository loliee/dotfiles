if exists("did_load_sh_userafter")
  finish
endif
let did_load_sh_userafter = 1

let b:ale_linters = ['shellcheck']
let b:ale_fixers = ['shfmt']
let g:ale_fix_on_save = 1

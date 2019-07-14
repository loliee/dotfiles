if exists("did_load_javascript_userafter")
  finish
endif
let did_load_javascript_userafter = 1

let b:ale_linters = ['eslint']
let b:ale_fixers = ['prettier', 'eslint']

if exists("did_load_yaml_userafter")
  finish
endif
let did_load_yaml_userafter = 1

let b:ale_linters = ['yamllint']
let b:ale_fixers = ['prettier']

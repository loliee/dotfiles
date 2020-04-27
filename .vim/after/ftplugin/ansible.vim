if exists("did_load_ansible_yaml_userafter")
  finish
endif
let did_load_ansible_yaml_userafter = 1

let b:ale_linters = ['yamllint', 'ansible_lint']
let b:ale_fixers = ['prettier']

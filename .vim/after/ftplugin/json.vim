if exists("did_load_json_userafter")
  finish
endif
let did_load_json_userafter = 1

let b:ale_linters = ['jsonlint']
let b:ale_fixers = ['jq', 'prettier']

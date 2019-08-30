if exists("did_load_python_userafter")
  finish
endif
let did_load_python_userafter = 1

let b:ale_linters = ['flake8']
let b:ale_fixers = ['autopep8']

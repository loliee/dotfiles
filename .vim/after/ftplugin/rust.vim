if exists("did_load_rust_userafter")
  finish
endif
let did_load_rust_userafter = 1

let b:ale_linters = ['cargo']
let b:ale_fixers = ['rustfmt']

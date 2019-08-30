if exists("did_load_dockerfile_userafter")
  finish
endif
let did_load_dockerfile_userafter = 1

let b:ale_linters = ['hadolint']

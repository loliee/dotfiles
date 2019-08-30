if exists("did_load_go_userafter")
  finish
endif
let did_load_go_userafter = 1

let b:ale_linters = ['bingo', 'gobuild', 'gofmt', 'golangci-lint', 'golint', 'gometalinter', 'gopls', 'gosimple', 'gotype', 'govet', 'golangserver', 'staticcheck']
let b:ale_fixers = ['gofmt']

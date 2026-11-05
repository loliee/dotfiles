#!/usr/bin/env bats
# Tests of the print-* fish functions in .config/fish/functions

bats_require_minimum_version 1.5.0

# The caller's own CLICOLOR would change the output
setup() {
  unset CLICOLOR
}

# Without --, fish itself would read a message such as -n as one of its options
print_fn() {
  fish --no-config -c "source $BATS_TEST_DIRNAME/../.config/fish/functions/$1.fish; $1 \$argv" -- "${@:2}"
}

color() {
  fish --no-config -c "set_color $1"
}

# print-warn

@test "print-warn writes the message to stderr when CLICOLOR is unset" {
  run --separate-stderr print_fn print-warn hello
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
  [ "$stderr" = "hello" ]
}

@test "print-warn writes the message in yellow when CLICOLOR is 1" {
  CLICOLOR=1 run --separate-stderr print_fn print-warn hello
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
  [ "$stderr" = "$(color yellow)hello$(color normal)" ]
}

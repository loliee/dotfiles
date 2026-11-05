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

# print-err

@test "print-err joins its arguments with spaces" {
  run --separate-stderr print_fn print-err hello world
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
  [ "$stderr" = "hello world" ]
}

@test "print-err writes a message that starts with a dash" {
  run --separate-stderr print_fn print-err "- x"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
  [ "$stderr" = "- x" ]
}

@test "print-err writes a message that is an echo option" {
  run --separate-stderr print_fn print-err -n
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
  [ "$stderr" = "-n" ]
}

@test "print-err writes a message that starts with a dash in red when CLICOLOR is 1" {
  CLICOLOR=1 run --separate-stderr print_fn print-err "- x"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
  [ "$stderr" = "$(color red)- x$(color normal)" ]
}

# print-success

@test "print-success writes a message that starts with a dash" {
  run --separate-stderr print_fn print-success "- x"
  [ "$status" -eq 0 ]
  [ "$output" = "- x" ]
  [ "$stderr" = "" ]
}

@test "print-success writes a message that is an echo option" {
  run --separate-stderr print_fn print-success -n
  [ "$status" -eq 0 ]
  [ "$output" = "-n" ]
  [ "$stderr" = "" ]
}

@test "print-success writes a message that starts with a dash in green when CLICOLOR is 1" {
  CLICOLOR=1 run --separate-stderr print_fn print-success "- x"
  [ "$status" -eq 0 ]
  [ "$output" = "$(color green)- x$(color normal)" ]
  [ "$stderr" = "" ]
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

@test "print-warn writes a message that starts with a dash" {
  run --separate-stderr print_fn print-warn "- x"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
  [ "$stderr" = "- x" ]
}

@test "print-warn writes a message that is an echo option" {
  run --separate-stderr print_fn print-warn -n
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
  [ "$stderr" = "-n" ]
}

@test "print-warn writes a message that starts with a dash in yellow when CLICOLOR is 1" {
  CLICOLOR=1 run --separate-stderr print_fn print-warn "- x"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
  [ "$stderr" = "$(color yellow)- x$(color normal)" ]
}

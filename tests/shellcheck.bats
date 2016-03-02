#!/usr/bin/env bats

@test "shellcheck .aliases" {
  run shellcheck -s bash .aliases
    [ $status -eq 0 ]
}

@test "shellcheck .aliases.osx" {
  run shellcheck -s bash .aliases.osx
    [ $status -eq 0 ]
}

@test "shellcheck .aliases.dev" {
  run shellcheck -s bash .aliases.dev
    [ $status -eq 0 ]
}

@test "shellcheck .bashrc" {
  run shellcheck -s bash .bashrc
    [ $status -eq 0 ]
}

@test "shellcheck .brew" {
  run shellcheck -s bash .brew
    [ $status -eq 0 ]
}

@test "shellcheck .osx" {
  run shellcheck -s bash .osx
    [ $status -eq 0 ]
}

@test "shellcheck .sshrc" {
  run shellcheck -s bash .sshrc
    [ $status -eq 0 ]
}

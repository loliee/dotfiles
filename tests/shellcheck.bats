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

@test "shellcheck .install.d/Darwin/brew.sh" {
  run shellcheck -s bash .install.d/Darwin/brew.sh
    [ $status -eq 0 ]
}

@test "shellcheck .install.d/Darwin/osx.sh" {
  run shellcheck -s bash .install.d/Darwin/macos.sh
    [ $status -eq 0 ]
}

@test "shellcheck .install.d/Darwin/install.sh" {
  run shellcheck -s bash .install.d/Darwin/install.sh
    [ $status -eq 0 ]
}

@test "shellcheck .install.d/Linux/install.sh" {
  run shellcheck -s bash .install.d/Linux/install.sh
    [ $status -eq 0 ]
}

@test "shellcheck .install.d/Linux/debian.sh" {
  run shellcheck -s bash .install.d/Linux/debian.sh
    [ $status -eq 0 ]
}

@test "shellcheck .sshrc" {
  run shellcheck -s bash .sshrc
    [ $status -eq 0 ]
}

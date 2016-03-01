#!/usr/bin/env bats

@test "source .aliases" {
  run source .aliases
    [ $status -eq 0 ]
}

@test "source .aliases.osx" {
  run source .aliases.osx
    [ $status -eq 0 ]
}

@test "source .aliases.dev" {
  run source .aliases
    [ $status -eq 0 ]
}

@test "source .bashrc" {
  run source .bashrc
    [ $status -eq 0 ]
}

@test "source .sshrc" {
  run source .sshrc
    [ $status -eq 0 ]
}

@test "source .zshenv" {
  run zsh -c "source .zshenv"
    [ $status -eq 0 ]
}

@test "source .zlogin" {
  run zsh -c "source .zlogin"
    [ $status -eq 0 ]
}

@test "source .zlogout" {
  run zsh -c "source .zlogout"
    [ $status -eq 0 ]
}

@test "source .zpreztorc" {
  run zsh -c "source .zpreztorc"
    [ $status -eq 0 ]
}

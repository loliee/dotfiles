# Load shared resources with bash

__fenv "source ~/.profile"
source ~/.aliases

if test -f ~/.aliases.local
  source ~/.aliases.local
end

if test -f ~/.env.local
  __fenv "source ~/.env.local"
end
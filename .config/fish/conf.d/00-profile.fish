# Load shared resources with bash

__fenv "source ~/.profile"
source ~/.aliases

if test -f ~/.lua.env
    __fenv "source ~/.lua.env"
end

if test -f ~/.aliases.local
    source ~/.aliases.local
end

if test -f ~/.env.local
    __fenv "source ~/.env.local"
end

# Lua
if hash luarocks &>/dev/null
    set -gx LUA_PATH (luarocks path --lr-path)
    set -gx LUA_CPATH (luarocks path --lr-cpath)
end

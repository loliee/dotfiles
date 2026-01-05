status is-interactive; or exit 0

# No welcome msg
set fish_greeting

# Cursor shape
set fish_cursor_default block
set fish_cursor_insert block
set fish_cursor_external line

# Load local functions
if test -d $XDG_CONFIG_HOME/fish/functions_local
    set fish_function_path $fish_function_path $XDG_CONFIG_HOME/fish/functions_local
end

# -----------------------------------------------------------------------------------------------------------------
# Hooks
# -----------------------------------------------------------------------------------------------------------------

direnv hook fish | source
fnm env --use-on-cd | source
starship init fish | source
zoxide init fish --cmd j | source

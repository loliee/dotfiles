# Allow Ctrl-f in vi mode
function fish_user_key_bindings
    set -g fish_key_bindings fish_vi_key_bindings
    fish_default_key_bindings -M insert
    fish_vi_key_bindings --no-erase insert

    # Bind "e" key in vi normal mode to open Neovim
    bind -M default e edit_command_buffer
end

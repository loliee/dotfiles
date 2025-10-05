# Stupid replacement of sshrc
#
# Copy ~/.sshrc.d/* to remote if SSHRC_USER match remote user,
# this should prevent to override files on unexpected accounts.
#
# Use -u for upgrading remote dotfiles, useful if already copied

function sshrc
    if test -z "$SSHRC_USER"
        echo >&2 "Error: SSHRC_USER is not defined!"
        return 1
    end

    # Check for upgrade flag "-u"
    if contains -- -u $argv
        set sshrc_update 1
    else
        set sshrc_update 0
    end
    set -l filtered_args (string match -v -- "-u" $argv)

    # Init commands: install prompt, check if dotfiles already present and get remote user
    set commands "\
      if [[ ! -d .patatetoy || $sshrc_update == \"0\" ]]; then
        mkdir -p .patatetoy
        curl -s https://raw.githubusercontent.com/loliee/prompt-patatetoy/refs/heads/master/patatetoy_common.sh \
            -o ~/.patatetoy/patatetoy_common.sh
        curl -s https://raw.githubusercontent.com/loliee/prompt-patatetoy/refs/heads/master/patatetoy.sh \
            -o ~/.patatetoy/patatetoy.sh
      fi
      is_dotfiles=\$(grep mloliee .bashrc >/dev/null && echo 1 || echo 0)
      echo \"\$is_dotfiles;\$(whoami)\"
    "
    set _result (ssh -q $filtered_args printf %s\n $commands || echo "errcon;")
    set parts (string split ";" $_result)
    set is_dotfiles $parts[1]
    set remote_user $parts[2]

    if test $is_dotfiles = errcon
        echo >&2 "Error: cannot connect to server: $filtered_args[-1]"
        return 1
    else if ! string match -q "*$SSHRC_USER*" $remote_user
        echo >&2 "Error: remote user \"$remote_user\" doesn't match \"*$SSHRC_USER*\"!"
        return 1
    end

    # Copy dotfiles if needed
    if test $sshrc_update = 1; or test $is_dotfiles = 0
        pushd ~/.sshrc.d/ &>/dev/null
        scp $filtered_args[1..-2] -Cq .* $filtered_args[-1]:
        popd &>/dev/null
    end

    ssh -qt $filtered_args "tmux new-session -A -s main &>/dev/null || bash"
end

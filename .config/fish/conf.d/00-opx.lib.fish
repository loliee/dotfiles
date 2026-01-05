# 1Password Extra Fish Utilities
#
# This script fetches a configuration file from a 1Password note.
#
# To specify the config file location, set:
#   set -g OPX_CONFIG_REF "op://Private/[Entry]/notesPlain"
#
# Expandable variables in config:
#   - $OPX_RAMDISK
#   - $HOME
#   - ~
#
# The note must contain valid YAML matching the specification in __opx_check_config.
# Example configuration:
# ---
# secrets:
#   # Save a file from 1Password
#   - reference: "op://Private/FOO/file"
#     dest: "$HOME/.secrets/.foo"
#     symlinks:
#       - /Dev/1/foo
#       - /Dev/2/foo
#
#   # Save a document by its document ID
#   - reference: "jfslnfjsi827nsj"
#     dest: "$HOME/.secrets/bar.txt"
#
#   # Save a secret as a file
#   - reference: "op://Private/FOOBAR/password"
#     as_file: true
#     dest: "$HOME/.secrets/.bar"
#
#   # Add a secret as an environment variable
#   - reference: "op://Private/FOOBAR/password"
#     env_key: "FOO"
#     dest: "$HOME/.secrets/.bar"
#
# Optional command hooks:
# post_fetch_cmds: []    # Commands to run after fetching secrets
# pre_clean_cmds: []     # Commands to run before cleaning up
# post_clean_cmds: []    # Commands to run after cleaning up

set -q OPX_MAX_JOBS; or set -g OPX_MAX_JOBS 10

function __opx_configure
    if test -z "$OPX_CONFIG_REF"
        set -g OPX_CONFIG_REF op://Private/(hostname)/notesPlain
    end
    if test -z "$OPX_CONFIG_PATH"; and test -n "$OPX_RAMDISK"
        set -U OPX_CONFIG_PATH "$OPX_RAMDISK/opx/config.yml"
    else if test -z "$OPX_CONFIG_PATH"
        set -U OPX_CONFIG_PATH "$HOME/.opx/config.yml"
    end
    echo "[opx] use $OPX_CONFIG_PATH as config path."
    mkdir -p $XDG_DATA_HOME/opx
end

function __opx_check_config
    if ! test -f $OPX_CONFIG_PATH
        print-err "[opx] OPX_CONFIG_PATH doesn't exists!"
        return 1
    end
    if not command -q yamale
        print-warn "[opx] yamale not found, validation skipped…"
        return 0
    end
    set -l OPX_SCHEMA_PATH (dirname $OPX_CONFIG_PATH)/schema.yml
    echo "
---
secrets: list(str(), include('reference'))
post_fetch_cmds: list(str(), required=False)
pre_clean_cmds: list(str(), required=False)
post_clean_cmds: list(str(), required=False)
---
reference:
  reference: str()
  dest: str()
  as_file: bool(required=False)
  env_key: str(required=False)
  symlinks: list(str(), required=False)" >$OPX_SCHEMA_PATH

    if not yamale -s $OPX_SCHEMA_PATH $OPX_CONFIG_PATH
        print-err "[opx] invalid configuration!"
        print-err (cat $OPX_CONFIG_PATH)
        return 1
    end

    return 0
end

function __opx_ramdisk
    if functions -q mkramdisk
        mkramdisk OPXRamDisk
        set -U OPX_RAMDISK /Volumes/OPXRamDisk
    else
        print-warn "[opx] mkramdisk is not available!"
    end
end

function __opx_expand_str --argument-names str
    if test -z "$str"
        print-err '[opx] cannot expand empty variable'
        return 1
    end

    set str (string replace -r '\$HOME' $HOME $str)
    set str (string replace -r '~' $HOME $str)

    if string match -qr '\$OPX_RAMDISK' $OPX_RAMDIS; and test -z "$OPX_RAMDISK"
        print-err '[opx] cannot expand $OPX_RAMDISK variable because not set!'
        return 1
    else
        set str (string replace -r '\$OPX_RAMDISK' $OPX_RAMDISK $str)
    end
    echo $str
end

function __opx_fetch_config --argument-names reference file
    set dir (dirname $file)
    test -d $dir; or mkdir -p $dir
    set config_file (op read "$reference" | string collect)
    if test $status -eq 0 -a -n "$config_file"
        if echo $config_file | sed -E "s/```(yaml)?//g" | yq >/dev/null
            echo $config_file | sed -E "s/```(yaml)?//g" | yq >$file
            chmod 600 $file
        else
            print-err "[opx] invalid YAML config file!"
            return 1
        end
    else
        print-err "[opx] cannot fetch secrets config file \"$reference\""
        return 1
    end
    echo "✔  Fetching config >$OPX_CONFIG_PATH"
    __opx_check_config; or return 1
end

function __opx_append_env --argument-names file key val
    set file (__opx_expand_str $file)
    test -e $file; or touch $file
    if test (path extension $file) = ".fish"
        printf "set -x %s %s\n" $key (string escape -- $val) >>$file
    else
        printf "export %s=%s\n" $key (string escape -- $val) >>$file
    end
    chmod 600 $file
end

function __opx_fetch_one_secret --argument-names idx config
    set reference (yq -r ".secrets[$idx].reference" $config)
    set dest_raw (yq -r ".secrets[$idx].dest" $config)
    set dest (__opx_expand_str $dest_raw)
    set env_key (yq -r ".secrets[$idx].env_key" $config)
    set as_file (yq -r ".secrets[$idx].as_file" $config)
    set symlinks (yq -r ".secrets[$idx].symlinks | .[]" $config)

    for vname in reference dest
        set vval (eval echo \$$vname)
        if test "$vval" = null
            print-err "[opx][$idx] missing value: '$vname'"
            return 1
        end
    end

    set dir (dirname $dest)
    test -d $dir; or mkdir -p $dir

    if test "$env_key" = null; and test "$as_file" = null
        if not string match -qr '^op://.*' $reference; and not test -f $dest
            if op document get --force $reference -o $dest >/dev/null
                chmod 600 $dest
                echo "✔ [$idx] Save document \"$reference\" > $dest"
            else
                print-err "[opx] cannot get 1password document \"$reference\""
                return 1
            end
        else if not string match -qr '^op://.*' $reference; and test -f $dest
            print-warn "✔ [$idx] Document $reference exists in \"$dest\", skipping…"
        else if not test -f $dest
            if op read -f "$reference" -o $dest
                chmod 600 $dest
                echo "✔ [$idx] Save file \"$reference\" > $dest"
            else
                print-err "[opx] cannot get 1password secret file \"$reference\""
                return 1
            end
        else if test -f $dest
            print-warn "✔ [$idx] File exists \"$dest\", skipping…"
        end
    else if test "$as_file" != null; and test $as_file = true
        if not test -f $dest
            set value (op read "$reference"| string collect)
            if test $status -eq 0 -a -n "$value"
                echo $value >$dest
                echo "✔ [$idx] $reference as file →  ($dest)"
            else
                print-err "[opx] cannot get 1password secret \"$reference\""
                return 1
            end
        else if test -f $dest
            print-warn "✔ [$idx] Secret file exists \"$dest\", skipping…"
        end
    else if test "$env_key" != null
        if not test -f $dest; or not grep -q -E "^(export|set -x) $env_key(=|\s+)" $dest
            set value (op read "$reference")
            if test $status -eq 0 -a -n "$value"
                __opx_append_env $dest $env_key $value
                echo "✔ [$idx] $reference → env $env_key ($dest)"
            else
                print-err "[opx] cannot get 1password secret \"$reference\""
                return 1
            end
        else if grep -q -E "^export $env_key=" $dest
            print-warn "✔ [$idx] Secrets $env_key exists in \"$dest\", skipping…"
        end
    end

    if test "$symlinks" != null; and test -n "$symlinks"
        for l in $symlinks
            set flink (__opx_expand_str $l)
            if ln -sf $dest $flink
                echo "✔ [$idx] symlink $dest > $flink"
            else
                print-err "[opx] cannot symlink \"$dest\" > $flink"
                return 1
            end
        end
    end
end

function __opx-exec --argument-names entry
    set available_commands \
        clear \
        dscacheutil \
        "killall -HUP mDNSResponder" \
        echo \
        __fenv \
        brew\\s+service \
        set-dns-servers \
        set-search-domains \
        wg

    set commands_regexp (string join "|" $available_commands)
    set commands (yq eval "$entry  | .[]" $OPX_CONFIG_PATH)
    if test "$commands" != null; and test -n "$commands"
        echo "🐚 $entry commands…"
        for cmd in $commands
            if string match -qr "^(?:sudo\s+)?($commands_regexp)[-~/_\.\w+\s+\"'\$]*\$" $cmd
                string match -qr "^echo.*" $cmd; or echo $cmd
                eval $cmd
            else
                print-err "Command $cmd not allowed!"
                return 1
            end
        end
    end
end

function __opx-shred-files
    set secret_files (yq ".secrets[].dest" $OPX_CONFIG_PATH | sort -u)
    for f in $secret_files
        set fpath (__opx_expand_str $f)
        if test -f $fpath
            shred -u $fpath
            echo "✔  $fpath deleted"
        end
    end
end

function opx-fetch -d "Fetch 1password secrets"

    if test -n "$OPX_INITIALIZED"; and test $OPX_INITIALIZED = 1
        set -q OPX_CONFIG_REF; and set -e OPX_CONFIG_REF
        return 0
    end

    __opx_ramdisk
    __opx_configure; or return 1
    __opx_fetch_config $OPX_CONFIG_REF $OPX_CONFIG_PATH; or return 1

    set indices (yq -r '.secrets | keys | .[]' $OPX_CONFIG_PATH)
    set -l running 0
    for idx in $indices
        __opx_fetch_one_secret $idx $OPX_CONFIG_PATH $default_mode &
        set running (math $running + 1)
        if test $running -ge $OPX_MAX_JOBS
            wait
            set running 2
        end
    end
    wait

    set -U OPX_INITIALIZED 1

    __opx-exec .post_fetch_cmds
end

function opx-update -d "Update 1password config & secrets"
    if test -n "$OPX_INITIALIZED"; and test $OPX_INITIALIZED = 1
        set -eU OPX_INITIALIZED
    end
    __opx_configure; or return 1
    opx-fetch
end

function opx-clean -d "Cleanup 1password secrets"
    __opx_configure; or return 1
    __opx_check_config; or return 1

    __opx-exec .pre_clean_cmds
    __opx-shred-files
    __opx-exec .post_clean_cmds

    if test -n "$OPX_RAMDISK"; and test -d $OPX_RAMDISK; and test (uname) = Darwin
        if hdiutil detach $OPX_RAMDISK
            echo "✔  unmount $OPX_RAMDISK"
        else
            print-err "fail to umount: $OPX_RAMDISK"
        end
    end
    set -eU OPX_INITIALIZED OPX_RAMDISK OPX_CONFIG_PATH
end

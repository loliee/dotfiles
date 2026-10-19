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
# Edit it with `opx-edit`: the ```yaml fences are stripped for the editor, the YAML is
# validated, and the note is written back fenced.
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
#   # Save a document by its ID or title (a reference without op:// still does, with a warning)
#   - document: "jfslnfjsi827nsj"
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
#   # Use a plain value instead of a 1Password reference (needs env_key or as_file)
#   - value: "plain-text"
#     env_key: "BAR"
#     dest: "$HOME/.secrets/.bar"
#
#   # Save a secure note as a file, without its ```<type> fences when it has some
#   - note: "op://Private/FOO/notesPlain"
#     dest: "$HOME/.secrets/foo.yml"
#
#   # Tag an entry: `opx-update prd` takes the entries tagged prd or all, `opx-clean prd` shreds the ones tagged prd
#   - reference: "op://Private/FOOBAR/password"
#     env_key: "FOO"
#     dest: "$HOME/.secrets/.bar"
#     tags: [prd, stg]
#
#   # Keep a note of references on disk: never shredded by opx-clean, refreshed by `opx-update --force` only
#   - note: "op://Private/INT - .envrc.secrets/notesPlain"
#     dest: "$HOME/Dev/int/.envrc.secrets"
#     persistent: true
#
# Optional command hooks, a string for every environment or {cmd: "…", tags: [prd]}:
# post_fetch_cmds: []    # Commands to run after fetching secrets
# pre_clean_cmds: []     # Commands to run before cleaning up
# post_clean_cmds: []    # Commands to run after cleaning up
# `opx-update --no-hooks` (or -H) skips post_fetch_cmds, `opx-clean --no-hooks` skips the clean ones.
# `opx-update` without an environment takes every entry and hook, tags ignored. `opx-fetch` without one, at session
# start, takes the entries tagged all and the persistent ones, with the hooks tagged all.
# `opx-update --force` (or -f) shreds the selected entries, persistent included, before fetching them again.

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

function __opx_check_config --argument-names path
    test -n "$path"; or set path $OPX_CONFIG_PATH
    if ! test -f $path
        print-err "[opx] $path doesn't exists!"
        return 1
    end
    if not command -q yamale
        print-warn "[opx] yamale not found, validation skipped…"
        return 0
    end
    set -l OPX_SCHEMA_PATH (dirname $path)/schema.yml
    echo "
---
secrets: list(any(include('reference'), include('value'), include('note'), include('document')))
post_fetch_cmds: list(any(str(), include('cmd')), required=False)
pre_clean_cmds: list(any(str(), include('cmd')), required=False)
post_clean_cmds: list(any(str(), include('cmd')), required=False)
---
reference:
  reference: str()
  dest: str()
  as_file: bool(required=False)
  base64_decode: bool(required=False)
  env_key: str(required=False)
  symlinks: list(str(), required=False)
  tags: list(str(), required=False)
  persistent: bool(required=False)
value:
  value: str()
  dest: str()
  as_file: bool(required=False)
  base64_decode: bool(required=False)
  env_key: str(required=False)
  symlinks: list(str(), required=False)
  tags: list(str(), required=False)
  persistent: bool(required=False)
note:
  note: str()
  dest: str()
  symlinks: list(str(), required=False)
  tags: list(str(), required=False)
  persistent: bool(required=False)
document:
  document: str()
  dest: str()
  symlinks: list(str(), required=False)
  tags: list(str(), required=False)
  persistent: bool(required=False)
cmd:
  cmd: str()
  tags: list(str(), required=False)" >$OPX_SCHEMA_PATH

    if not yamale -s $OPX_SCHEMA_PATH $path
        print-err "[opx] invalid configuration!"
        print-err (cat $path)
        return 1
    end

    return 0
end

# Reads the note on stdin; a command substitution would not see the function's stdin
function __opx_normalize_config --argument-names dst
    touch $dst.tmp
    chmod 600 $dst.tmp
    if not sed -E "s/```(yaml)?//g" | yq >$dst.tmp
        print-err "[opx] invalid YAML config file!"
        rm -f $dst.tmp
        return 1
    end
    mv $dst.tmp $dst
end

function __opx_ramdisk
    if functions -q mkramdisk
        mkramdisk OPXRamDisk
        set -U OPX_RAMDISK /Volumes/OPXRamDisk
    else
        print-warn "[opx] mkramdisk is not available!"
    end
end

# Hidden from op only, the shell keeps them: set, they send op to a Connect server or a service account without the items
function __opx_op
    env -u OP_CONNECT_HOST -u OP_CONNECT_TOKEN -u OP_SERVICE_ACCOUNT_TOKEN op $argv
end

function __opx_signin
    __opx_op whoami &>/dev/null; and return 0
    echo "[opx] 1Password CLI is not signed in, signing in…"
    if not __opx_op signin
        print-err "[opx] cannot sign in: 1Password must be running, unlocked, with Settings > Developer > Integrate with 1Password CLI"
        return 1
    end
end

function __opx_expand_str --argument-names str
    if test -z "$str"
        print-err '[opx] cannot expand empty variable'
        return 1
    end

    set str (string replace -r '\$HOME' $HOME $str)
    set str (string replace -r '~' $HOME $str)

    if string match -qr '\$OPX_RAMDISK' $str; and test -z "$OPX_RAMDISK"
        print-err '[opx] cannot expand $OPX_RAMDISK variable because not set!'
        return 1
    else
        set str (string replace -r '\$OPX_RAMDISK' "$OPX_RAMDISK" $str)
    end
    echo $str
end

function __opx_fetch_config --argument-names reference file
    set dir (dirname $file)
    test -d $dir; or mkdir -p $dir
    set config_file (__opx_op read "$reference" | string collect)
    if test $status -eq 0 -a -n "$config_file"
        echo $config_file | __opx_normalize_config $file; or return 1
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

function __opx_read_secret --argument-names reference value
    if test "$value" != null
        echo $value
    else
        __opx_op read "$reference"
    end
end

# Drops an opening fence with or without a type (```yaml) and a closing one, spaces in them and blank lines around ignored
function __opx_strip_fences --argument-names text
    set -l lines (string split \n -- (string trim -c \n -- $text))
    string match -qr '^```\s*\S*\s*$' -- $lines[1]; and set -e lines[1]
    string match -qr '^```\s*$' -- $lines[-1]; and set -e lines[-1]
    string join \n -- $lines
end

# The characters a secret reference accepts (1password.dev/cli/secret-reference-syntax); an item named with others goes by its ID
function __opx_check_reference --argument-names idx reference
    set -l seg '[A-Za-z0-9._ -]+'
    string match -qr "^op://$seg/$seg/$seg(/$seg)?\$" -- $reference; and return 0
    print-err "[opx][$idx] invalid reference \"$reference\": op://<vault>/<item>/[<section>/]<field>, letters, digits, spaces, - _ . only, or the item ID"
    return 1
end

function __opx_fetch_one_secret --argument-names idx config
    set reference (yq -r ".secrets[$idx].reference" $config)
    set value (yq -r ".secrets[$idx].value" $config | string collect)
    set note (yq -r ".secrets[$idx].note" $config)
    set document (yq -r ".secrets[$idx].document" $config)
    set dest_raw (yq -r ".secrets[$idx].dest" $config)
    set dest (__opx_expand_str $dest_raw)
    set env_key (yq -r ".secrets[$idx].env_key" $config)
    set as_file (yq -r ".secrets[$idx].as_file" $config)
    set base64_decode (yq -r ".secrets[$idx].base64_decode" $config)
    set symlinks (yq -r ".secrets[$idx].symlinks | .[]" $config)

    # Older configs: a reference without op:// is a document
    if test "$reference" != null; and not string match -q 'op://*' -- $reference
        print-warn "[opx][$idx] reference \"$reference\" is not op://, read as a document: prefer 'document:'"
        set document $reference
        set reference null
    end

    if test "$dest_raw" = null
        print-err "[opx][$idx] missing value: 'dest'"
        return 1
    end
    if test "$reference" = null; and test "$value" = null; and test "$note" = null; and test "$document" = null
        print-err "[opx][$idx] missing value: 'reference', 'value', 'note' or 'document'"
        return 1
    end
    set label $reference
    test "$value" != null; and set label value
    test "$note" != null; and set label $note
    test "$document" != null; and set label $document
    if test "$note" != null
        __opx_check_reference $idx $note; or return 1
    else if string match -q 'op://*' -- $reference
        __opx_check_reference $idx $reference; or return 1
    end

    set dir (dirname $dest)
    test -d $dir; or mkdir -p $dir

    if test "$note" != null
        if not test -f $dest
            set value (__opx_op read "$note" | string collect)
            if test $status -eq 0 -a -n "$value"
                __opx_strip_fences $value >$dest
                chmod 600 $dest
                echo "✔ [$idx] Save note \"$note\" > $dest"
            else
                print-err "[opx] cannot get 1password note \"$note\""
                return 1
            end
        else
            print-warn "✔ [$idx] Note file exists \"$dest\", skipping…"
        end
    else if test "$document" != null
        if not test -f $dest
            if __opx_op document get --force $document -o $dest >/dev/null
                chmod 600 $dest
                echo "✔ [$idx] Save document \"$document\" > $dest"
            else
                print-err "[opx] cannot get 1password document \"$document\""
                return 1
            end
        else
            print-warn "✔ [$idx] Document $document exists in \"$dest\", skipping…"
        end
    else if test "$env_key" = null; and test "$as_file" = null
        if test "$value" != null
            print-err "[opx][$idx] 'value' needs 'env_key' or 'as_file: true'"
            return 1
        end
        if not test -f $dest
            if __opx_op read -f "$reference" -o $dest
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
            set value (__opx_read_secret $reference $value | string collect)
            if test $status -eq 0 -a -n "$value"
                if test "$base64_decode" != null; and test $base64_decode = true
                    echo $value | base64 -d >$dest
                else
                    echo $value >$dest
                end
                chmod 600 $dest
                echo "✔ [$idx] $label as file →  ($dest)"
            else
                print-err "[opx] cannot get 1password secret \"$label\""
                return 1
            end
        else if test -f $dest
            print-warn "✔ [$idx] Secret file exists \"$dest\", skipping…"
        end
    else if test "$env_key" != null
        if not test -f $dest; or not grep -q -E "^(export|set -x) $env_key(=|\s+)" $dest
            set value (__opx_read_secret $reference $value)
            if test $status -eq 0 -a -n "$value"
                __opx_append_env $dest $env_key $value
                echo "✔ [$idx] $label → env $env_key ($dest)"
            else
                print-err "[opx] cannot get 1password secret \"$label\""
                return 1
            end
        else if grep -q -E "^export $env_key=" $dest
            print-warn "✔ [$idx] Secrets $env_key exists in \"$dest\", skipping…"
        end
    end

    if test "$symlinks" != null; and test -n "$symlinks"
        for l in $symlinks
            set flink (__opx_expand_str $l)
            set ldir (dirname $flink)
            test -d $ldir; or mkdir -p -m 700 $ldir
            if ln -sf $dest $flink
                echo "✔ [$idx] symlink $dest > $flink"
            else
                print-err "[opx] cannot symlink \"$dest\" > $flink"
                return 1
            end
        end
    end
end

# Environment names land in a yq expression: letters, digits, - and _ only
function __opx_check_envs
    for env in $argv
        if not string match -qr '^[A-Za-z0-9_-]+$' -- $env
            print-err "[opx] invalid environment \"$env\": letters, digits, - and _ only"
            return 1
        end
    end
end

# yq predicate on a secret or a hook: tagged with one of $argv, a plain string hook counting as all; true without $argv.
# --persistent takes the persistent entries too
function __opx_tagged
    argparse p/persistent -- $argv
    if test (count $argv) -eq 0
        echo true
        return
    end
    set -l any (string join ' or ' (string replace -r '^(.*)$' '. == "$1"' -- $argv))
    # No if/then/else: yq got it in 4.54 and the shell may run an older one; a string gets all appended to its tags
    set -l match "(((.tags // []) + ([.] | map(select(tag == \"!!str\")) | map(\"all\"))) | map($any) | any)"
    set -q _flag_persistent; and set match "($match or .persistent == true)"
    echo $match
end

function __opx-exec --argument-names entry pred
    test -n "$pred"; or set pred true
    set available_commands \
        clear \
        echo \
        source \
        brew\\s+service \
        /usr/local/bin/opx-net-down
    # opx-clean runs from tmux, without root or a tty: sudo can only run the NOPASSWD opx-net-down
    if not string match -q '*_clean_cmds' $entry
        set -a available_commands \
            dscacheutil \
            gpg-lock \
            "killall -HUP mDNSResponder" \
            set-dns-servers \
            set-search-domains \
            wg
    end

    set commands_regexp (string join "|" $available_commands)
    set commands (yq -r "$entry // [] | map(select($pred)) | .[] | (.cmd // .)" $OPX_CONFIG_PATH)
    if test -n "$commands"
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

# The persistent entries stay unless $persistent is true
function __opx-shred-files --argument-names pred persistent
    test -n "$pred"; or set pred true
    set -l keep "and .persistent != true"
    test "$persistent" = true; and set keep ""
    set secret_files (yq -r ".secrets | map(select($pred $keep)) | .[].dest" $OPX_CONFIG_PATH | sort -u)
    for f in $secret_files
        set fpath (__opx_expand_str $f)
        if test -f $fpath
            shred -u $fpath
            echo "✔  $fpath deleted"
        end
    end
end

function opx-fetch -d "Fetch 1password secrets: the shared and persistent entries, the given environments, or all"
    argparse H/no-hooks f/force a/all -- $argv; or return 1
    __opx_check_envs $argv; or return 1
    # At session start, without an environment: the entries tagged all and the persistent ones
    set -l pred (__opx_tagged --persistent all)
    test (count $argv) -gt 0; and set pred (__opx_tagged $argv all)
    set -q _flag_all; and set pred (__opx_tagged)

    if test -n "$OPX_INITIALIZED"; and test $OPX_INITIALIZED = 1
        set -q OPX_CONFIG_REF; and set -e OPX_CONFIG_REF
        return 0
    end

    __opx_signin; or return 1
    __opx_ramdisk
    __opx_configure; or return 1
    __opx_fetch_config $OPX_CONFIG_REF $OPX_CONFIG_PATH; or return 1
    set -q _flag_force; and __opx-shred-files $pred true

    set indices (yq -r ".secrets | to_entries | map(select(.value | $pred)) | .[].key" $OPX_CONFIG_PATH)
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

    set -q _flag_no_hooks; or __opx-exec .post_fetch_cmds $pred
end

function opx-update -d "Update 1password config & secrets, all or of the given environments"
    argparse H/no-hooks f/force -- $argv; or return 1
    if test -n "$OPX_INITIALIZED"; and test $OPX_INITIALIZED = 1
        set -eU OPX_INITIALIZED
    end
    __opx_configure; or return 1
    set -l all --all
    test (count $argv) -gt 0; and set all
    opx-fetch $_flag_no_hooks $_flag_force $all $argv
end

function opx-edit -d "Edit the 1password config note, validated before saving"
    __opx_signin; or return 1
    __opx_configure; or return 1

    set -l parts (string split / (string replace op:// '' $OPX_CONFIG_REF))
    if test (count $parts) -ne 3
        print-err "[opx] cannot parse vault and item from \"$OPX_CONFIG_REF\""
        return 1
    end
    set -l vault $parts[1]
    set -l item $parts[2]

    set -l dir (dirname $OPX_CONFIG_PATH)
    test -d $dir; or mkdir -p $dir
    set -l note $dir/edit.yml
    set -l orig $dir/edit.orig.yml
    set -l check $dir/edit.check.yml
    touch $note $orig $check
    chmod 600 $note $orig $check
    __opx_op read $OPX_CONFIG_REF | sed -E '/^```(yaml)?$/d' >$note
    if test $pipestatus[1] -ne 0
        print-err "[opx] cannot read \"$OPX_CONFIG_REF\""
        shred -u $note $orig $check
        return 1
    end
    cp $note $orig

    set -l editor $EDITOR
    test -n "$editor"; or set editor nvim
    while true
        $editor $note
        if cmp -s $note $orig
            echo "[opx] no change"
            shred -u $note $orig $check
            return 0
        end
        if __opx_normalize_config $check <$note; and __opx_check_config $check
            break
        end
        read -l -P "[opx] invalid config, edit again? [Y/n] " answer
        if test $status -ne 0; or string match -qir '^n' -- $answer
            shred -u $note $orig $check
            return 1
        end
    end

    # The note goes through stdin: command arguments are visible to other processes
    __opx_op item get $item --vault $vault --format json \
        | jq --rawfile notes $note '(.fields[] | select(.id == "notesPlain")).value = "```yaml\n" + ($notes | rtrimstr("\n")) + "\n```\n"' \
        | __opx_op item edit $item --vault $vault >/dev/null
    set -l saved $status
    shred -u $note $orig $check
    if test $saved -ne 0
        print-err "[opx] cannot update note \"$item\""
        return 1
    end
    echo "✔  Note \"$item\" updated, run opx-update to apply"
end

function opx-clean -d "Cleanup 1password secrets, all or of the given environments"
    argparse H/no-hooks -- $argv; or return 1
    __opx_check_envs $argv; or return 1
    set -l pred (__opx_tagged $argv)
    __opx_configure; or return 1
    __opx_check_config; or return 1

    set -q _flag_no_hooks; or __opx-exec .pre_clean_cmds $pred
    __opx-shred-files $pred
    set -q _flag_no_hooks; or __opx-exec .post_clean_cmds $pred

    # The other environments stay: only a full clean drops the ramdisk and the state
    test (count $argv) -eq 0; or return 0
    if test -n "$OPX_RAMDISK"; and test -d $OPX_RAMDISK; and test (uname) = Darwin
        if hdiutil detach $OPX_RAMDISK
            echo "✔  unmount $OPX_RAMDISK"
        else
            print-err "fail to umount: $OPX_RAMDISK"
        end
    end
    set -eU OPX_INITIALIZED OPX_RAMDISK OPX_CONFIG_PATH
end

# The environments: every tag of the config but all
function __opx_envs
    test -f "$OPX_CONFIG_PATH"; or return
    yq -r '[.. | select(tag == "!!map" and has("tags")) | .tags[]] | unique | .[]' $OPX_CONFIG_PATH | string match -v all
end

complete -c opx-fetch -c opx-update -c opx-clean -c opx-edit -f
complete -c opx-fetch -c opx-update -c opx-clean -s H -l no-hooks -d "Skip the command hooks of the note"
complete -c opx-fetch -c opx-update -s f -l force -d "Shred the selected entries, persistent included, then fetch them again"
complete -c opx-fetch -s a -l all -d "Every entry, tags ignored"
complete -c opx-fetch -c opx-update -c opx-clean -a '(__opx_envs)'

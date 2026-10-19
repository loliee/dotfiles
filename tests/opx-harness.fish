# Harness for tests/opx.bats: stubs op, the editor and the print helpers, then sources the lib.
# Loaded with: fish --no-config -C "source tests/opx-harness.fish" -c "<fish code>"
# OPX_TEST_DIR (set by the bats test) holds the config, the op stub inputs and the files written.

function print-err
    echo "ERR: $argv" >&2
end

function print-warn
    echo "WARN: $argv"
end

# Every call is logged; read and item get answer with files under $OPX_TEST_DIR/op
function op
    echo "op $argv" >>$OPX_TEST_DIR/op.log
    switch "$argv[1] $argv[2]"
        case "whoami *"
            return 0
        case "read *"
            test -f $OPX_TEST_DIR/op/read; or return 1
            cat $OPX_TEST_DIR/op/read
        case "item get"
            cat $OPX_TEST_DIR/op/item.json
        case "item edit"
            cat >$OPX_TEST_DIR/op/edited.json
        case "*"
            return 1
    end
end

# Each call replaces the edited file with the next of $OPX_TEST_DIR/edits/1, 2…
set -g opx_test_edit_n 0
function fake-editor --argument-names file
    set opx_test_edit_n (math $opx_test_edit_n + 1)
    set -l next $OPX_TEST_DIR/edits/$opx_test_edit_n
    test -f $next; and cp $next $file
end

set -gx EDITOR fake-editor
# Not exported: mise shims resolve yq and jq through the real XDG_DATA_HOME
set -g XDG_DATA_HOME $OPX_TEST_DIR/data
set -g OPX_RAMDISK $OPX_TEST_DIR/ramdisk
set -g OPX_CONFIG_REF op://Private/testitem/notesPlain
set -g OPX_CONFIG_PATH $OPX_TEST_DIR/config.yml

source (status dirname)/../.config/fish/conf.d/00-opx.lib.fish

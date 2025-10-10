function print-err -d "Print error message on stderr, support CLICOLOR"
    set -l message (string join " " $argv)

    if test -n "$CLICOLOR"; and test $CLICOLOR = 1
        echo >&2 (set_color red)$message(set_color normal)
    else
        echo >&2 $message
    end
end

function print-success -d "Print message on stdout, support CLICOLOR"
    set -l message (string join " " $argv)

    if test -n "$CLICOLOR"; and test $CLICOLOR = 1
        echo (set_color green)$message(set_color normal)
    else
        echo $message
    end
end

function ensure-cmd --description "Ensure command exists"
    for c in $argv
        if not type -q $c
            print-err "Error missing command: $c"
            return 128
        end
    end
end

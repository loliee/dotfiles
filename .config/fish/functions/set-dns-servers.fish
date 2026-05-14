function set-dns-servers -d "Configure DNS servers for all interfaces (macOS only)"
    if test (uname) != Darwin
        echo >&2 "Only Darwin system is supported!"
        return 1
    end

    if test -z "$argv[1]"
        set fargv Empty
    else
        set fargv $argv
    end

    for interface in (sudo networksetup -listallnetworkservices)
        if ! string match -r "^An asterisk.*" $interface &>/dev/null
            echo "Set DNS servers $fargv for $interface"
            sudo networksetup -setdnsservers "$interface" $fargv
        end
    end

end

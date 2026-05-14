function set-hostname -d "Configure Hostname servers (macOS only)"
    if test (uname) != Darwin
        echo >&2 "Only Darwin system is supported!"
        return 1
    end

    if test -z "$argv[1]"
        echo >&2 "Missing hostname argument!"
        return 1
    end

    sudo scutil --set HostName $argv[1]
end

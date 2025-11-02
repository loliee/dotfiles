function mkramdisk -a name size_mb -d "Create a secure RAM disk with a random key for sensitive data (macOS only)"
    if test (uname) != Darwin
        echo >&2 "Only Darwin system is supported!"
        return 1
    end

    if not test "$name"
        set name SecureRAM
    end

    if not test "$size_mb"
        set size_mb 32
    end

    if test -d /Volumes/$name
        print-warn "RAM disk $name already exists at /Volumes/$name"
        return 0
    end

    set blocks (math "$size_mb * 2048")
    set device (hdiutil attach -nomount ram://$blocks | string trim)
    if test -n "$device"
        echo "Creating encrypted RAM disk $name ($size_mb MB) on $device"
        set container (diskutil apfs create $device $name | awk '/Disk from APFS operation: / {last=$NF} END {print last}')
        if test $status != 0
            print-err "Failed to create APFS volume $name on $device"
            return 1
        end
    else
        print-err "Failed to allocate RAM disk"
        return 1
    end

    if test -n "$container"
        pwgen 120 | diskutil apfs encryptVolume $container -user disk -stdinpassphrase
        if test $status != 0
            print-err "Failed to encrypt APFS volume: $container"
            return 1
        end
    end

    if not chown $USER:staff /Volumes/$name; or not chmod 700 /Volumes/$name
        print-err "Failed to set owner & permission on /Volumes/$name"
        return 1
    end
end

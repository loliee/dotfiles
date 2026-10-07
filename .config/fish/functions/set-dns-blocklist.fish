function set-dns-blocklist -d "Download DNS blocklist for CoreDNS"
    if test (uname) != Darwin
        echo >&2 "Only Darwin system is supported!"
        return 1
    end

    # A hosts list that names each subdomain, as CoreDNS hosts matches exact names; only 0.0.0.0 lines: it never redirects
    curl --fail --silent --show-error --proto =https --tlsv1.2 \
        https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts \
        | awk '$1 == "0.0.0.0" && $2 != "0.0.0.0" { print "0.0.0.0", $2 }' | sudo tee /etc/coredns/blocklist.hosts >/dev/null
    # fish has no pipefail: a failed step must not pass for success
    not string match -qv 0 $pipestatus
end

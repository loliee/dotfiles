function set-dns-blocklist -d "Download DNS blocklist for CoreDNS"
    if test (uname) != Darwin
        echo >&2 "Only Darwin system is supported!"
        return 1
    end

    # CoreDNS hosts wants "IP name" lines: wildcard patterns such as ad.* have no hosts form and are dropped
    curl --fail --silent --show-error --proto =https --tlsv1.2 \
        https://download.dnscrypt.info/blacklists/domains/mybase.txt \
        | sed -nE 's/^([[:alnum:]._-]+)$/0.0.0.0 \1/p' >/opt/homebrew/etc/coredns/blocklist.hosts
    # fish has no pipefail: a failed step must not pass for success
    not string match -qv 0 $pipestatus
end

# Audit a third-party macOS app before trusting it: who signed it, whether
# Gatekeeper and notarization vouch for it, what the sandbox and hardened
# runtime still allow, and how it updates itself.
#
# Returns 1 on a missing or broken signature, a Gatekeeper refusal or a
# failed assessment, 0 otherwise; everything else is a warning for the reader.
#
# Run it from a normal terminal: in a sandboxed shell codesign cannot read
# the certificates and spctl cannot reach its daemon, so those checks fail
# for every app.
#
# codesign(1): https://keith.github.io/xcode-man-pages/codesign.1.html
# spctl(8): https://keith.github.io/xcode-man-pages/spctl.8.html
# Gatekeeper: https://support.apple.com/guide/security/gatekeeper-and-runtime-protection-sec5599b66df/web
function app-audit --description 'Check the signature, notarization, entitlements and update channel of a macOS app'
    argparse --min-args 1 --max-args 1 -- $argv; or return 1
    ensure-cmd codesign spctl plutil; or return 1
    set -l app (string trim --right --chars / -- $argv[1])
    set -l plist $app/Contents/Info.plist
    if not test -f $plist
        print-err "Not an app bundle: $app"
        return 1
    end
    set -l failed 0

    # codesign -d writes its report on stderr, one Key=Value per line
    set -l sig (codesign -dv --verbose=4 $app 2>&1); or begin
        print-err "Not signed: $sig"
        return 1
    end
    # Authority= lines are the certificate chain, leaf first; a genuine chain ends at Apple Root CA
    # https://developer.apple.com/documentation/technotes/tn3161-inside-code-signing-certificates
    set -l authorities (string match -rg '^Authority=(.*)' -- $sig)
    set -l team (string match -rg '^TeamIdentifier=(.*)' -- $sig)
    # No Authority= line means an ad hoc signature (Signature=adhoc): nobody vouches for the code
    if test (count $authorities) -eq 0
        print-err "Ad hoc signature, no developer identity"
        set failed 1
    else
        print-success "Signed by $authorities[1], team $team"
        if test "$authorities[-1]" = "Apple Root CA"
            print-success "Certificate chain ends at Apple Root CA"
        else
            print-err "Certificate chain ends at $authorities[-1], not Apple Root CA"
            set failed 1
        end
    end
    # flags=...(runtime) is the hardened runtime, required for notarization
    # https://developer.apple.com/documentation/security/hardened-runtime
    if string match -qr 'flags=\S*runtime' -- $sig
        print-success "Hardened runtime on"
    else
        print-warn "Hardened runtime off"
    end
    # A stapled ticket lets Gatekeeper verify notarization offline
    # https://developer.apple.com/documentation/security/notarizing-macos-software-before-distribution
    if string match -q 'Notarization Ticket=stapled' -- $sig
        print-success "Notarization ticket stapled"
    else
        print-warn "No stapled notarization ticket: Gatekeeper checks online"
    end

    # --deep also verifies nested code (frameworks, helpers), --strict adds checks beyond the defaults
    if codesign --verify --deep --strict $app 2>/dev/null
        print-success "Signature valid on disk, nested code included"
    else
        print-err "Signature broken: run codesign --verify --deep --strict --verbose=2 $app"
        set failed 1
    end

    # Same verdict as a first launch; exit 3 is a refusal, any other non-zero is spctl failing
    set -l assessment (spctl --assess --type execute --verbose=4 $app 2>&1)
    set -l assessed $status
    set -l source (string match -rg '^source=(.*)' -- $assessment)
    if test $assessed -eq 0
        if contains -- "$source" "Notarized Developer ID" "Mac App Store" "Apple System"
            print-success "Gatekeeper accepts it: $source"
        else
            print-warn "Gatekeeper accepts it, but source is $source"
        end
    else if test $assessed -eq 3
        print-err "Gatekeeper rejects it: $assessment"
        set failed 1
    else
        print-err "spctl failed, no Gatekeeper verdict: $assessment"
        set failed 1
    end

    # Text format, undocumented in codesign(1): --xml fails on some system apps with "invalid entitlements blob"
    set -l entitlements (codesign -d --entitlements - $app 2>/dev/null | string collect)
    set -l granted (string match -rag '\[Key\] (\S+)\n\s*\[Value\]\n\s*\[Bool\] true' -- $entitlements)
    # https://developer.apple.com/documentation/security/app-sandbox
    if contains com.apple.security.app-sandbox $granted
        print-success "App Sandbox on"
        contains com.apple.security.network.client $granted; and echo "Sandbox allows outgoing connections"
    else
        print-warn "No App Sandbox: the app runs with all your rights"
    end
    # cs.* entitlements punch holes in the hardened runtime, get-task-allow lets a debugger attach
    # https://developer.apple.com/documentation/security/hardened-runtime
    set -l exceptions (string match -- 'com.apple.security.cs.*' $granted) (string match -- com.apple.security.get-task-allow $granted)
    if test (count $exceptions) -eq 0
        print-success "No hardened runtime exception"
    else
        print-warn "Hardened runtime exceptions: $exceptions"
    end

    # Sparkle keys: https://sparkle-project.org/documentation/customization/
    # The feed may also be set in code (SPUUpdaterDelegate feedURLStringForUpdater:), so look for the framework too
    set -l feed (plutil -extract SUFeedURL raw -o - $plist 2>/dev/null)
    if test -n "$feed"; or test -d $app/Contents/Frameworks/Sparkle.framework
        if test -z "$feed"
            echo "Sparkle present, update feed set in code"
        else if string match -q 'https://*' -- $feed
            print-success "Update feed over HTTPS: $feed"
        else
            print-warn "Update feed not over HTTPS: $feed"
        end
        # EdDSA signatures protect updates from a compromised feed host
        # https://sparkle-project.org/documentation/ section "Segue for security concerns"
        if plutil -extract SUPublicEDKey raw -o - $plist >/dev/null 2>&1
            print-success "Updates signed with EdDSA (SUPublicEDKey)"
        else
            print-warn "No SUPublicEDKey: updates are not EdDSA-signed"
        end
        # Info.plist default only: the user can flip it in the update alert
        set -l auto (plutil -extract SUAutomaticallyUpdate raw -o - $plist 2>/dev/null)
        if test "$auto" = true
            print-warn "Installs updates without asking by default"
        else
            print-success "Asks before installing updates by default"
        end
    else
        echo "No Sparkle: neither SUFeedURL nor Sparkle.framework"
    end

    # ATS binds only Foundation networking (NSURLSession); Electron or Qt apps bring their own TLS stack
    # https://developer.apple.com/documentation/bundleresources/information-property-list/nsapptransportsecurity
    set -l ats (plutil -extract NSAppTransportSecurity json -o - $plist 2>/dev/null)
    if test -n "$ats"
        print-warn "ATS exceptions: $ats"
    else
        print-success "No ATS exception"
    end

    return $failed
end

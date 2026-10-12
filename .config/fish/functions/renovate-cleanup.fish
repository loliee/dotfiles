function renovate-cleanup --description 'Delete the Renovate MRs and branches of the GitLab project behind a -dev git remote'
    argparse n/dry-run -- $argv; or return 1
    set -l remote origin-dev
    set -q argv[1]; and set remote $argv[1]
    if not string match -q -- '*-dev*' $remote
        echo "Refusing remote '$remote': its name must contain -dev" >&2
        return 1
    end

    set -l url (git remote get-url $remote); or return 1
    set -l parts (string match -rg '^(?:[a-z+]+://)?(?:[^@/]+@)?([^:/]+)(?::[0-9]+)?[:/](.+?)(?:\.git)?$' -- $url)
    if test (count $parts) -ne 2
        echo "Cannot read host and project from $url" >&2
        return 1
    end
    set -l host $parts[1]
    set -l project $parts[2]
    set -l p (string replace -a / %2F -- $project)

    echo "glab host: $host"
    echo "project:   $project (remote $remote)"

    # glab errors can echo the token: never show them
    set -l raw_mrs (glab api --hostname $host --paginate "projects/$p/merge_requests?state=all&per_page=100" 2>/dev/null); or begin
        echo "glab cannot read the MRs of $project on $host: is GITLAB_TOKEN a token of $host?" >&2
        return 1
    end
    set -l mrs (printf '%s\n' $raw_mrs | jq -r '.[] | select(.source_branch | startswith("renovate/")) | "\(.iid)\t\(.state)\t\(.title)"')
    set -l raw_branches (glab api --hostname $host --paginate "projects/$p/repository/branches?search=%5Erenovate/&per_page=100" 2>/dev/null); or begin
        echo "glab cannot read the branches of $project on $host" >&2
        return 1
    end
    set -l branches (printf '%s\n' $raw_branches | jq -r '.[].name')

    if test (count $mrs) -eq 0; and test (count $branches) -eq 0
        echo "No Renovate MR or branch on $host/$project"
        return 0
    end

    for mr in $mrs
        echo "MR !$mr"
    end
    for branch in $branches
        echo "branch $branch"
    end

    if set -q _flag_dry_run
        for mr in $mrs
            echo "would run: glab api --hostname $host -X DELETE projects/$p/merge_requests/"(string split -f1 \t -- $mr)
        end
        for branch in $branches
            echo "would run: glab api --hostname $host -X DELETE projects/$p/repository/branches/"(string replace -a / %2F -- $branch)
        end
        echo "Dry run: nothing deleted"
        return 0
    end

    read -l -P "Delete these "(count $mrs)" MRs and "(count $branches)" branches on $host/$project ($remote)? [y/N] " answer
    test "$answer" = y; or return 1

    for mr in $mrs
        set -l iid (string split -f1 \t -- $mr)
        if glab api --hostname $host -X DELETE "projects/$p/merge_requests/$iid" >/dev/null 2>&1
            echo "Deleted MR !$iid"
        else
            echo "Failed to delete MR !$iid (deleting an MR needs the Owner role)" >&2
        end
    end
    for branch in $branches
        if glab api --hostname $host -X DELETE "projects/$p/repository/branches/"(string replace -a / %2F -- $branch) >/dev/null 2>&1
            echo "Deleted branch $branch"
        else
            echo "Failed to delete branch $branch" >&2
        end
    end
end

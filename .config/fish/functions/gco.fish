# Git checkout with FZF
function gco
    set branches (git --no-pager branch --sort=-committerdate | string split0)
    set branch (echo "$branches" | FZF_DEFAULT_OPTS="" fzf +m | string trim)
    if string match -rq '^\+\s+(?<worktree_branch>.*)' $branch
        set worktrees (git worktree list --porcelain)
        if echo $worktrees | string match -r "worktree\s+(?<wdir>[\S]+) HEAD [a-f0-9]+ branch refs/heads/$worktree_branch" &>/dev/null
            set_color blue
            echo "Jumping to worktree directory…"
            cd $wdir
        else
            set_color red
            echo "Branch is already used in a workdir!" 1>&2
            set_color normal
        end
    else
        set timestamp (date +%s)
        echo -e "- cmd: git co $branch\n  when: $timestamp" >>$XDG_DATA_HOME/fish/fish_history
        history save
        history merge

        git checkout (echo "$branch" | awk '{print $1}' | sed "s/.* //")
    end
end

function mr
    vipe --suffix markdown | read -z title || return 1
    set response (glab mr create --fill --yes --title $title $argv) || return 1
    set id (string match -r "merge_requests/(\d+)" $response)[2]
    glab mr update --yes --description="-" $id
end

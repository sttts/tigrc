#!/bin/bash

program=$0
action=$1
commit=$2

function usage()
{
    echo "usage: $program fixup|squash|ascend|descend|reword|abort|edit HASH"
    exit 1
}

[ "$#" -lt 1 ] && usage

replace="gsed -i"

case $action in
    fixup|squash|ascend|descend|reword|abort|edit)
        if [ "$action" != "abort" ]; then
            if [ -z $commit ]; then
                usage
            else
                current=$(git log --pretty=format:%h "$commit" -1)
                parent=$(git log --pretty=format:%h ${current}~1 -1)
                child=$(git log --pretty=format:%h --reverse --ancestry-path ${current}..HEAD | head -n 1)
            fi
        fi

        case $action in
            fixup)
                replace="$replace -e 's/pick ${current}/fixup ${current}/'"
                GIT_SEQUENCE_EDITOR=$replace git rebase -i ${current}~2
                ;;
            edit)
                replace="$replace -e 's/pick ${current}/e ${current}/'"
                GIT_SEQUENCE_EDITOR=$replace git rebase -i ${current}~2
                PROMPT_PREFIX="<tig edit> " zsh -i
                git rebase --continue
                ;;
            squash)
                replace="$replace -e 's/pick ${current}/s ${current}/'"
                GIT_SEQUENCE_EDITOR=$replace git rebase -i ${current}~2
                ;;
            ascend)
                replace="$replace -e 's/pick ${current}/pick BUFFER/'"
                replace="$replace -e 's/pick ${child}/pick ${current}/'"
                replace="$replace -e 's/pick BUFFER/pick ${child}/'"
                GIT_SEQUENCE_EDITOR=$replace git rebase -i ${current}~1 || (printf '\a'; git rebase --abort; exit 1)
                ;;
            descend)
                replace="$replace -e 's/pick ${current}/pick BUFFER/'"
                replace="$replace -e 's/pick ${parent}/pick ${current}/'"
                replace="$replace -e 's/pick BUFFER/pick ${parent}/'"
                GIT_SEQUENCE_EDITOR=$replace git rebase -i ${current}~2 || (printf '\a'; git rebase --abort; exit 1)
                ;;
            reword)
                replace="$replace -e 's/pick ${current}/reword ${current}/'"
                GIT_SEQUENCE_EDITOR=$replace git rebase -i ${current}~1
                ;;
            abort)
                git rebase --abort
                ;;

        esac
        ;;
    *)
        usage
        ;;
esac

#!/bin/sh
export FILE=${FILE_NAME}
sleep 1

git filter-branch -f \
    --prune-empty \
    --tag-name-filter cat \
    --tree-filter 'rm -f $FILE' \
    $(git log --follow --find-renames=40% --diff-filter=A --format=%H -- $FILE)~..HEAD
git for-each-ref --format="%(refname)" refs/original/ | xargs -n 1 git update-ref -d
git reflog expire --expire=now --all && git gc --prune=now --aggressive

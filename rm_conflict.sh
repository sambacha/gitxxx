#!/bin/sh
# for rebase/merge conflicts
git rm $FILE
git commit --amend --no-edit
git reflog expire --expire=now --all && git gc --prune=now --aggressive

#!/bin/bash
echo "Git Repack and Prune starting..."

git for-each-ref --format="%(refname)" refs/original/ |
  xargs -n 1 git update-ref -d
sleep 1

git reflog expire --expire=now --all
echo ""
git repack -ad; git prune
# git repack -a -d -f --depth=250 --window=250

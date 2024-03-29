#!/usr/bin/env bash

# Created by Sindre Sorhus
# Magically retrieves a GitHub users email even though it's not publicly shown

[ "$1" = "" ] && echo "usage: $0 <GitHub username> [<repo>]" && exit 1

[ "$2" = "" ] && repo=$(curl "https://api.github.com/users/$1/repos?type=owner&sort=updated" -s | gsed -En 's|"name": "(.+)",|\1|p' | tr -d ' ' | head -n 1) || repo=$2

curl "https://api.github.com/repos/$1/$repo/commits" -s | gsed -En 's|"(email\|name)": "(.+)",?|\2|p' | tr -s ' ' | paste - - | sort -u -k 1,1

# `paste - -`      remove every other linebreak
# `sort -u -k1,1`  only show unique lines based on first column (email)

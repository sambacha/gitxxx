#!/bin/bash
set -e

echo "Please be patient this may take awhile...."
REPO=$(gh repo list $1 --json nameWithOwner -q '.[].nameWithOwner' | fzf)

if [ $? -ne 0 ];then
  echo "You need gh v2+ and fzf available in your PATH"
  exit 1
fi
sleep 1
echo "Cloning Repos..."
gh repo clone "${REPO}" "${@:2}"

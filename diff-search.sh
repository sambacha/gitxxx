#!/bin/bash
for commit in $(git rev-list --all); do 
    # search only lines starting with + or -
    if  git show "$commit" | grep "^[+|-].*search-string"; then 
        git show --no-patch --pretty=format:'%C(yellow)%h %Cred%ad %Cblue%an%Cgreen%d %Creset%s' --date=short $commit
    fi  
done

#!/usr/env/bash
# shortform git commands
alias g='git'

# push all branches to all remotes
git remote | xargs -L1 git push --all

# count lines of .js code in a repo
git ls-files | grep \\.js$ | xargs wc -l

# pretty tab'd git log
git log --graph --pretty="tformat:%h*(%ar)*<%an>*%d %s" $* | sed -Ee 's/(^[^<]*) ago\)/\1)/' | sed -Ee 's/(^[^<]*), [[:digit:]]+ .*months?\)/\1)/' | column -s '*' -t | cat

# change author of all git repos
git filter-branch -f --env-filter "GIT_AUTHOR_NAME='yourname'; GIT_AUTHOR_EMAIL='youremail@example.com'; GIT_COMMITTER_NAME='yourname'; GIT_COMMITTER_EMAIL='youremail@example.com';" HEAD;

# stage only deleted files
git ls-files --deleted | xargs git add

# scan repo for dangerous Amazon Web Service IDs
git ls-tree --full-tree -r --name-only HEAD | xargs egrep -w '[A-Z0-9]{20}'

# remove .DS_Store from the repository
find . -name .DS_Store -exec git rm --ignore-unmatch --cached {} +

# push current branch
git push origin "$(git branch|grep '\*'|tr -d '* \n')"

# git remote all remotes except origin
git remote -v | grep "(fetch)" | sed -e 's#[[:blank:]].*##g' | grep -v "origin" | xargs -n 1 git remote rm

# print all git repos for a user
curl -s https://api.github.com/users/wordpress/repos?per_page=1000 | grep git_url |awk '{print $2}'| sed 's/"\(.*\)",/\1/'

# print all git repos for a user
curl -s https://api.github.com/users/wordpress/repos?per_page=1000 | jq -r '.[].git_url'

# show GIT Remote Origin for each immediate subfolder
find . -maxdepth 1 -type d \( ! -name . \) -exec bash -c "cd '{}' && echo '{}' && git config --get remote.origin.url" \;

# find all git repositories and perform a pull operation on them.
find . -name ".git" -type d -exec bash -c "echo '{}' && cd '{}'/.. && git pull" \;

# print your list of commits this month for a repo
git log --since='last month' --author="$(git config user.name)" --oneline

# print the url for the current repo
git remote -v | sed -n '/github.com.*push/{s/^[^[:space:]]\+[[:space:]]\+//;s|git@github.com:|https://github.com/|;s/\.git.*//;p}'

# pull in remote changes for the current repository and all its submodules
git pull; git submodule foreach git pull origin master

# get a list of all commit messages for a repo
git log --pretty=format:'%s'

# pull all git repos to current version
find . -name .git -type d -execdir git pull -v

# pull all git repos to currenrt version
find $(git rev-parse --show-toplevel 2> /dev/null) -name .git -type d -execdir git pull;

# find the nearest parent branch of the current git branch
git show-branch -a | grep '\*' | grep -v `git rev-parse --abbrev-ref HEAD` | head -n1 | sed 's/.*\[\(.*\)\].*/\1/' | sed 's/[\^~].*//'

# push changes to an empty git repository for the first time
git push --set-upstream origin master

# delete first 10 branches of remote excluding master
git branch -a | grep "remotes/origin" | grep -v master | sed 's/^[ *]*//' | sed 's/remotes\/origin\///' | head -n10 | sed 's/^/git push origin :/'

# Remove + and - from start of diff lines
git diff --color | sed "s/^\([^-+ ]*\)[-+ ]/\\1/" | less -r

# clear out git hooks
find .git/hooks -type l -exec rm {} \; && find .githooks -type f -exec ln -sf ../../{} .git/hooks/ \;

# remove untracked files in a git repository
git status -su | cut -d' ' -f2- | tr '\n' '\0' | xargs -0 rm

# get most modified files and counts
git log --all -M -C --name-only --format='format:' "$@" | sort | grep -v '^$' | uniq -c | sort | awk 'BEGIN {print "count\tfile"} {print $1 "\t" $2}' | sort -g

# Locally checkout all remote branches of a repository
git branch -r | cut -d '/' -f2 | grep -Ev '( |master)' | xargs -Ibranch git checkout -b branch origin/branch

# Open current Git repository URL
open `git remote -v | awk '/fetch/{print $2}' | sed -Ee 's#(git@|git://)#http://#' -e 's@com:@com/@'`| head -n1

# Remove Git from current project
find . -name '.git' -exec rm -rf {} \;

# Remove all new files
for file in $(git status | grep "new file" | sed "s/#\tnew file://"); do git rm --cached $file; done

# Delete all remote branches
for remote_branch in $(git ls-remote); do if [[ $remote_branch =~ .*(feature/MAGENTA-([0-9|^130]).+).* ]]; then git push origin :${BASH_REMATCH[1]}; fi; done

# Removes all local branch
for branch in $(git branch | grep "feature/MAGENTA-"); do git branch -D $branch; done

# get list of followers from github username
curl -s https://api.github.com/users/username/followers | grep '\"login\"' | sed -e's/[,|"|:]//g' | awk '{print $(NF)}' | sort

# git commit random alias
git config --global alias.commit-random '!git commit -m "$(curl -s http://whatthecommit.com/index.txt)"'

usage: git commit-random

# get list of users public repos
curl "https://api.github.com/users/usernamehere/repos?type=owner&sort=updated" -s | sed -En 's|"name": "(.+)",|\1|p' | tr -d ' '

# count relevant lines of shell code in a git repo
egrep -v '^\s*($|#)' $(git grep -l '#!/bin/.*sh' *) | wc -l

# push all remotes
for i in `git remote`; do git push $i; done;

# cherry pick range of commits, starting from the tip of 'master', into 'preview' branch
git rev-list --reverse --topo-order master... | while read rev; do git checkout preview; git cherry-pick $rev || break; done

# create tracking branches for all remote branches
git branch -a | grep -v HEAD | perl -ne 'chomp($_); s|^\*?\s*||; if (m|(.+)/(.+)| && not $d{$2}) {print qq(git branch --track $2 $1/$2\n)} else {$d{$_}=1}' | csh -xfs;

# git reset newly added files
for f in `git status | grep new | awk '{print $3}'`; do git reset HEAD $f ; done

# git reset newly added files
git reset HEAD -- $(git status | awk '/new file:/{print $3}')

# pull latest of all submodules
git submodule foreach git pull origin master

# show a git log with offsets relative to HEAD
git log --oneline | nl -v0 | sed 's/^ \+/&HEAD~/'

# list offsets from HEAD with git log
o=0; git log --oneline | while read l; do printf "%+9s %s\n" "HEAD~${o}" "$l"; o=$(($o+1)); done | less

# diff the last 2 commits
git diff $(git log --pretty=format:%h -2 --reverse | tr "\n" " ")

# reset the last modified time for each file in a git repo to its last commit time
git ls-files | while read file; do echo $file; touch -d $(git log --date=local -1 --format="@%ct" "$file") "$file"; done

# get author and email of a commit 
git --no-pager show -s --format='%an <%ae> on %cd' --date=short {commithash}

# information about an author by giving it's name or email
git log -i -1 --pretty="format:%an <%ae>\n" --author="$1"

# List all files ever existed
git log --pretty=format: --name-status $@ | cut -f2- | sort -u

# commit all changes
git add -A && git commit -av

# print git commit history
git log --oneline --decorate | nl | sort -nr | nl | sort -nr | cut --fields=1,3 | sed 's/([^)]*)\s//g'

# print git commit history
git log --oneline --decorate | tac | nl | tac | sed 's/([^)]*)\s//g'

# find the date of the first commit in a repo
git log --pretty=format:'%ad' | tail -1

# delete all local git branches that have been merged
git branch --merged | grep -v "\*" | xargs -n 1 git branch -d

# delete all git branches except master
git branch | egrep -v ^master$ | sed 's/^[ *]*//' | sed 's/^/git branch -D /' | bash

# delete all git branches except master
git branch | grep -v "master" | sed 's/^[ *]*//' | sed 's/^/git branch -D /' | bash

# delete all git branches except master
git checkout master; git branch | sed -e '/master/d' -e 's/^/git branch -D /' | bash

# export current repo to zip archive
git archive -o "${PWD##*/}.zip" HEAD

# figure out what pull requests are in your current branch (staging) but not yet in master
git log HEAD...origin/master --pretty=oneline | grep pull

# remove missing files
git ls-files -d -z | xargs -0 git update-index --remove

# list authors of a repo
git shortlog -sn --all | cut -f2 | cut -f1 -d' '

# remove file from repo history
git filter-branch -f --tree-filter  'rm -rf filename.py' HEAD

# list repos by username
curl "https://api.github.com/users/username/repos?type=owner&sort=updated" -s | sed -En 's|"name": "(.+)",|\1|p' | awk '{print $1}'

# fetch all git remotes for a repo
git branch -r | awk -F'/' '{print "git fetch "$1,$2}' | xargs -I {} sh -c {}

# add a tag
git tag -a 1.2 -m "Version 1.2 Stable"

# show which branches are tracking what
git for-each-ref --format='%(refname:short)' refs/heads/* | while read b; do if r=$(git config --get branch.$b.remote); then m=$(git config --get branch.$b.merge); echo "$b -> $r/${m##*/}"; fi; done

# push tags
git push --tags

# download all files from a gist without git
curl -L https://gist.github.com/username/gistid/download | tar -xvz --strip-components=1

# delete a local branch
git branch -d branchname

# delete a remote branch
git push origin --delete branchname

# list props for repo
git log -i --grep props | egrep -io 'props (to )?[a-z0-9_\-]*' | sed 's/.* //' | sort | uniq -c | sort -k1nr

# Undo your last commit, but don't throw away your changes
git reset --soft HEAD^

# Delete all local branches that have been merged into HEAD
git branch -d `git branch --merged | grep -v '^*' | grep -v 'master' | tr -d '\n'`

# credit author on last commit
git commit --amend --author "$1 <$2>" -C HEAD

# Show the diff of everything you haven't pushed yet.
branch=$(git rev-parse --abbrev-ref HEAD) git diff origin/$branch..HEAD

# determine current branch
git branch | awk '/\*/{print $2}'

# check which branches had the latest commits
git for-each-ref --sort=-committerdate --format='%(refname:short) %(committerdate:short)'

# search all commit messages for a string
git rev-list --all | xargs git grep -F 'string'

# create a git.io short url
curl -s -F "url=http://github.com/twitter" -i http://git.io | sed -n 's/Location:.* //p'

# find the most verbs used in commit messages
git log --pretty=format:'%s' | cut -d " " -f 1 | sort | uniq -c | sort -nr

# find the most verbs used in commit messages
git log --oneline | awk '{ print $2; }' | sort | uniq -c | sort -r

# get current author and email of the repo
git log -1 --pretty="format:%an <%ae>" --author="$1"

# verify all packed objects and find the 5 biggest ones
git verify-pack -v .git/objects/pack/*.idx | sort -k 3 -n | tail -5

# delete all tags
for t in `git tag` do; git push origin :$t; git tag -d $t; done

# compress all repos
find . -path '*.git/config' -execdir git gc --aggressive \;

# remove .DS_Store from the repository you happen to staging by mistake
find . -name .DS_Store -exec git rm --ignore-unmatch --cached {} +

# Delete all local branches that have been merged into HEAD.
git branch -d `git branch --merged | grep -v '^*' | grep -v 'master' | tr -d '\n'`

# Credit an author on the last commit
git commit --amend --author "John Doe <john@doe.com>" -C HEAD

# pretty git log
git log --graph --pretty=format:'%Cred%h%Creset %an: %s - %Creset %C(yellow)%d%Creset %Cgreen(%cr)%Creset' --abbrev-commit --date=relative

# delete local files that have been removed from git repo
git status | grep deleted | awk '{\$1=\$2=\"\"; print \$0}' | perl -pe 's/^[ \t]*//' | sed 's/ /\\\\ /g' | xargs git rm

# list all files ever added to a git repo
git log --name-status --oneline --all | grep -P "^[A|M|D]\s" | awk '{print $2}' | sort | uniq

# get current branch
git branch | grep "^*" | sed 's/* //g'

# stage manually deleted files
git status | grep deleted | sed 's/deleted://g' | sed 's/[#| ]//g' | xargs git rm

# show path to the root of the repo
git rev-parse --show-toplevel

# recommit last commit
LAST_MESSAGE=`git log -1 --pretty="format:%s"`; git commit -m "$LAST_MESSAGE" --amend --date "`date`"

# Get a list of all TODO/FIXME tasks left to be done in your project
alias tasks='grep --exclude-dir=.git -rEI "TODO|FIXME" . 2>/dev/null'

# edit your gitignore from anywhere in your repo
vim $(git rev-parse --show-toplevel)/.gitignore

# simple single-lined git log
git log --pretty=oneline --abbrev-commit

# Lint Git unstaged PHP files
git status -s | grep -o ' \S*php$' | while read f; do php -l $f; done

# 100% rollback files to a specific revision
git reset --hard <commidId> && git clean -f

# Print out the contents of a Git repository (useful for broken repositories)
find .git/objects -type f -printf "%P\n" | sed s,/,, | while read object; do echo "=== $obj $(git cat-file -t $object) ==="; git cat-file -p $object; done

# Show git branches by date - useful for showing active branches
git for-each-ref --sort='-authordate' --format='%(refname)%09%(authordate)' refs/heads | sed -e 's-refs/heads/--'

# git log with color and path
alias gitlog='git log -10 --graph --date-order -C -M --pretty=format:"%C(yellow)%h%C(reset) - %C(bold green)%ad%C(reset) - %C(dim yellow)%an%C(reset) %C(bold red)>%C(reset) %C(white)%s%C(reset) %C(bold red)%d%C(reset) " --abbrev-commit --date=short'

# open (in vim) all modified files in a git repository
git status --porcelain | sed -ne 's/^ M //p' | tr '\n' '\0' | tr -d '"' | xargs -0 vim

# open (in vim) all modified files in a git repository
vim `git status --porcelain | sed -ne 's/^ M //p'`

# open (in vim) all modified files in a git repository
vim `git status | grep modified | awk '{print $3}'`

# open (in vim) all modified files in a git repository
vim -p `git --porcelain | awk {print $2}`

# stage all manually deleted files
for x in `git status | grep deleted | awk '{print $3}'`; do git rm $x; done

# generate file list modified since last commit and export to tar file
git diff-tree -z -r --no-commit-id --name-only --diff-filter=ACMRT COMMID_HASH | xargs -0 tar -rf list.tar

# export unpushed files list
git log -z origin/master..master --name-only --pretty="format:" | sort -zu | xargs -0 tar -rf list.tar

# Count the lines of each file extenion in a list of files
git ls-files | xargs wc -l | awk -F ' +|\\.|/' '{ sumlines[$NF] += $2 } END { for (ext in sumlines) print ext, sumlines[ext] }'

# Show git commit history
git reflog show | grep '}: commit' | nl | sort -nr | nl | sort -nr | cut --fields=1,3 | sed s/commit://g | sed -e 's/HEAD*@{[0-9]*}://g'

# Restore deleted file from GIT repository
git checkout $(git rev-list -n 1 HEAD -- "$file")^ -- "$file"

# Number of commits per day in a git repo
git log | grep Date | awk '{print " : "$4" "$3" "$6}' | uniq -c

# Remove git branches that do not have a rmote tracking branch anymore
git branch -r | awk '{print $1}' | egrep -v -f /dev/fd/0 <(git branch -vv | grep origin) | awk '{print $1}' | xargs git branch -d

# Remove .git dirs
find . -name ".git" -type d -exec rm -rf {} \;

# Top Ten of the most active committers in git repositories
git shortlog -s | sort -rn | head

# git -  create a local branch that tracks with the remote branch
git checkout -tb mybranch origin/mybranch

# Prints per-line contribution per author for a GIT repository
git ls-files | xargs -n1 git blame --line-porcelain | sed -n 's/^author //p' | sort -f | uniq -ic | sort -nr

# Git Tree Command with color and tag/branch name
git log --graph --oneline --all --decorate --color

# Open the current project on Github by typing gh
git remote -v | grep fetch | sed 's/\(.*github.com\)[:|/]\(.*\).git (fetch)/\2/' | awk {'print "https://github.com/" $1'} | xargs open

# Show git branches by date - useful for showing active branches
for k in $(git branch | sed /\*/d); do echo "$(git log -1 --pretty=format:"%ct" $k) $k"; done | sort -r | awk '{print $2}'

# Update (pull commits from) all submodules
git submodule foreach git pull --ff-only origin master

# commit message generator - whatthecommit.com
curl http://whatthecommit.com/index.txt

# Create tarball of files modified in git
tar czf git_mods_circa_dec23.tgz --files-from <(git ls-files -m)

# Sequential revision numbers in Git
git rev-list --reverse HEAD | awk "/$(git log -n 1 --pretty="format:%h")/ {print NR}"

# commit message generator - whatthecommit.com
curl -s 'http://whatthecommit.com/' | grep '<p>' | cut -c4-

# Show git branches by date - useful for showing active branches
for k in `git branch|sed s/^..//`;do echo -e `git log -1 --pretty=format:"%Cgreen%ci %Cblue%cr%Creset" "$k" --`\\t"$k";done|sort

# git Output remote origin from within a local repository
git config --local --get remote.origin.url

# delete local *and* remote git repos if merged into local master
git branch | cut -c3- | grep -v "^master$" | while read line; do git branch -d $line; done | grep 'Deleted branch' | awk '{print $3;}' | while read line; do git push <target_remote> :$line; done

# Using Git, stage all manually deleted files.
git add -u

# Pull git submodules in parallel using GNU parallel
parallel -j4 cd {}\; pwd\; git pull :::: <(git submodule status | awk '{print $2}')

# bash script to zip a folder while ignoring git files and copying it to dropbox
git archive HEAD | gzip > ~/Dropbox/archive.tar.gz

# Push each of your local git branches to the remote repository
git push origin --all

# Deleting a remote git branch (say, by name 'featureless')
git push origin :featureless

# git-rm for all deleted files, including those with space/quote/unprintable characters in their filename/path
git ls-files -z -d | xargs -0 git rm --

# GIT: list unpushed commits
git log --oneline <REMOTE>..<LOCAL BRANCH>

# commit message generator - whatthecommit.com
lynx -dump -nolist http://whatthecommit.com/|sed -n 2p

# commit message generator - whatthecommit.com
curl -s http://whatthecommit.com | html2text | sed '$d'

# commit message generator - whatthecommit.com
curl -s http://whatthecommit.com | sed -n '/<p>/,/<\/p>/p' | sed '$d' | sed 's/<p>//'

# telling you from where your commit come from
function where(){ COUNT=0; while [ `where_arg $1~$COUNT | wc -w` == 0 ]; do let COUNT=COUNT+1; done; echo "$1 is ahead of "; where_arg $1~$COUNT; echo "by $COUNT commits";};function where_arg(){ git log $@ --decorate -1 | head -n1 | cut -d ' ' -f3- ;}

# Show the changed files in your GIT repo
git status | perl -F'\s' -nale 'BEGIN { $a = 0 }; $a = 1 if $_ =~ /changed but not updated/i; print $F[-1] if ( $a && -f $F[-1] )'

# Search git repo for specified string
git grep "search for something" $(git log -g --pretty=format:%h -S"search for something")

# Get first Git commit hash
git log --pretty=format:%H | tail -1

# Get first Git commit hash
git log --format=%H | tail -1

# List all authors of a particular git project
git log --format='%aN <%aE>' | awk '{arr[$0]++} END{for (i in arr){print arr[i], i;}}' | sort -rn | cut -d\  -f2-

# See all the commits for which searchstring appear in the git diff
git log -p -z | perl -ln0e 'print if /[+-].*searchedstring/'

# List every file that has ever existed in a git repository
git log --all --pretty=format:" " --name-only | sort -u

# git pull all repos
find ~ -maxdepth 2 -name .git -print | while read repo; do cd $(dirname $repo); git pull; done

# Add .gitignore files to all empty directories recursively from your current directory
find . \( -type d -empty \) -and \( -not -regex ./\.git.* \) -exec touch {}/.gitignore \;

# Display condensed log  in a tree-like format.
git log --graph --pretty=oneline --decorate

# List all authors of a particular git project
git log --format='%aN' | sort -u

# List all authors of a particular git project
git shortlog -s | cut -c8-

# Show git branches by date - useful for showing active branches
for k in `git branch|sed s/^..//`;do echo -e `git log -1 --pretty=format:"%Cgreen%ci %Cblue%cr%Creset" "$k"`\\t"$k";done|sort

# Move all files untracked by git into a directory
git clean -n | sed 's/Would remove //; /Would not remove/d;' | xargs mv -t stuff/

# Prints per-line contribution per author for a GIT repository
git ls-files | while read i; do git blame $i | sed -e 's/^[^(]*(//' -e 's/^\([^[:digit:]]*\)[[:space:]]\+[[:digit:]].*/\1/'; done | sort | uniq -ic | sort -nr

# Prints per-line contribution per author for a GIT repository
git ls-files | xargs -n1 -d'\n' -i git-blame {} | perl -n -e '/\s\((.*?)\s[0-9]{4}/ && print "$1\n"' | sort -f | uniq -c -w3 | sort -r

# Makes a project directory, unless it exists; changes into the dir, and creates an empty git repository, all in one command
gitstart () { if ! [[ -d "$@" ]]; then mkdir -p "$@" && cd "$@" && git init; else cd "$@" && git init; fi }

# git Revert files with changed mode, not content
git diff --numstat | awk '{if ($1 == "0" && $2 == "0") print $3}'  | xargs git checkout HEAD

# Show changed files, ignoring permission, date and whitespace changes
git diff --numstat -w --no-abbrev | perl -a -ne '$F[0] != 0 && $F[1] !=0 && print $F[2] . "\n";'

# Show (only) list of files changed by commit
git show --relative --pretty=format:'' --name-only HASH

# Stage only portions of the changes to a file.
git add --patch <filename>

# Show log message including which files changed for a given commit in git.
git --no-pager whatchanged -1 --pretty=medium <commit_hash>

# search string in _all_ revisions
for i in `git log --all --oneline --format=%h`; do git grep SOME_STRING $i; done

# git remove files which have been deleted
git ls-files -z --deleted | xargs -0 git rm

# Show git branches by date - useful for showing active branches
for k in `git branch|perl -pe s/^..//`;do echo -e `git show --pretty=format:"%Cgreen%ci %Cblue%cr%Creset" $k|head -n 1`\\t$k;done|sort -r

# add forgotten changes to the last git commit
git commit --amend

# git remove files which have been deleted
git rm $(git ls-files --deleted)

# git diff of files that have been staged ie 'git add'ed
git diff --cached

# add untracked/changed items to a git repository before doing a commit and/or sending upstream
git status|awk '/modified:/ { printf("git add %s\n",$3) }; NF ==2 { printf("git add %s\n",$2) }'|sh

# Better git diff, word delimited and colorized
git config alias.dcolor "diff --color-words"

# Better git diff, word delimited and colorized
git diff -U10|dwdiff --diff-input -c|less -R

# Better git diff, word delimited and colorized
git diff -U10 |wdiff --diff-input -a -n -w $'\e[1;91m' -x $'\e[0m' -y $'\e[1;94m' -z $'\e[0m' |less -R

# Count git commits since specific commit
git log --pretty=oneline b56b83.. | wc -l

# Count git commits since specific commit
git log --summary 223286b.. | grep 'Author:' | wc -l

# Execute git submodule update in parallel with xargs
git submodule status | awk '{print $2}' | xargs -P5 -n1 git submodule update --init

# Incorporating a finished feature on develop
git checkout develop; git merge --no-ff myfeature

# Creating a feature branch
git checkout -b myfeature develop

# My Git Tree Command!
git log --graph --oneline --all

# show git logging
git log --stat

# Create a git archive of the latest commit with revision number as name of file
git archive HEAD --format=zip -o `git rev-parse HEAD`.zip

# List files under current directory, ignoring repository copies.
function have_here { find "${@:-.}" -type d \( -name .git -o -name .svn -o -name .bzr -o -name CVS -o -name .hg -o -name __pycache__ \) -prune -o -type f -print; }

# revert the unstaged modifications in a git working directory
git diff | git apply --reverse

#commit message generator
curl -s http://whatthecommit.com/ | tr -s '\n' ' ' | grep -so 'p>\(.*\)</p' | sed -n 's/..\(.*\)..../\1/p'

# random git commit message
git-random(){ gitRan=$(curl -L -s http://whatthecommit.com/ |grep -A 1 "\"c" |tail -1 |sed  's/<p>//'); git commit -m "$gitRan"; }

# rename a branch
git branch -m old_branch new_branch

# set upstream for existing branch
git branch --set-upstream <branch> <remote>/<branch>

# checkout remote branch
git checkout -b test origin/test

# pretty git commit log
git log --pretty=format:"%h %ad | %s%d [%an]" --graph --date=short

# make git HEAD same as origin/master
git reset --hard origin/master

# delete a remote branch
git push origin :heads/branch_name

# revert uncommited git changes
git reset --hard HEAD

# add .gitignore to enable add empty directory to git
for i in $(find . -type d -regex ``./[^.].*'' -empty); do touch $i"/.gitignore"; done;

# list files between git commits
git diff --name-only 4ce07ee 7cdf78b

# list all branches
git branch -a

# install a new git repo
function gitinstall(){ git init; git remote add origin "$@"; git config branch.master.remote origin; git config branch.master.merge refs/heads/master; git pull;}

# git recursive rm
git ls-files -d -z | xargs -0 git update-index --remove

# undo last git commit
git reset --soft HEAD^

# find deleted stashes and other lost commits in git
git fsck --no-reflog | awk '/dangling commit/ {print $3}'

# git apply patch
git format-patch -k --stdout rev1-1..rev2 | git am -k -3

# git cat
git cat-file -p $(git ls-tree $1 "$2" | cut -d " " -f 3 | cut -f 1)

# list unmerged files
git ls-files -u|awk '{print $4}'|sort -u

# list added files in the index
git diff-index HEAD|awk '{print $5 " " $6}'|sed -n -e's/^A //p'

# print number of modified files
git status --porcelain | cut -c 1-2 | grep M | wc -l | tr -d " "

# show all remote git branches
git remote show origin

# fancy git prompt

parse_git_branch() {
  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(git::\1)/'
}

export PS1="\[\033]0;\h \w \$(parse_git_branch) \007\][\[\033[01;35m\]\h \[\033[01;34m\]\w \[\033[31m\]\$(parse_git_branch)\[\033[00m\]]$ "

# Recursively remove all untracked files in the tree.
git clean -f

# throw out all of your changes to existing files, but not new ones
git reset --hard

# remove file from staging area
git rm --cached [file]

# see diff of files in staging area
git diff --staged

# see tracked files
git ls-files

# see a branch graph
git log --graph

# see all tags
git tag

# see list of deleted files
git ls-files -d

# restore all deleted files
git ls-files -d | xargs git checkout --

# view commits not yet pushed to remote
git log --branches --not --remotes

# difference between two branches
git diff --stat --color master..branch

# see a list of all objects
git rev-list --objects --all

# remove file from index
git rm --cached filename.txt
